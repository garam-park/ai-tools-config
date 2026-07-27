#!/usr/bin/env python3
"""Create a provider-neutral project-local MCP stdio launcher."""

from __future__ import annotations

import argparse
import re
import shlex
import stat
from dataclasses import dataclass
from pathlib import Path

from project_mcp_registry import (
    ALL_PROVIDERS,
    artifact_record,
    parse_providers,
    plan_registration,
    write_registration,
)


ENV_NAME = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*$")
SERVER_NAME = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")


@dataclass(frozen=True)
class EnvMapping:
    local: str
    upstream: str


def parse_mapping(value: str) -> EnvMapping:
    local, separator, upstream = value.partition("=")
    if not separator:
        upstream = local
    if not ENV_NAME.fullmatch(local) or not ENV_NAME.fullmatch(upstream):
        raise argparse.ArgumentTypeError(
            f"invalid environment mapping {value!r}; use LOCAL=UPSTREAM"
        )
    return EnvMapping(local=local, upstream=upstream)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Scaffold scripts/mcp/<server>/start.sh without overwriting files."
    )
    parser.add_argument(
        "--project-root",
        type=Path,
        default=Path.cwd(),
        help="Project root that will contain scripts/mcp (default: current directory).",
    )
    parser.add_argument(
        "--required-env",
        action="append",
        default=[],
        type=parse_mapping,
        metavar="LOCAL=UPSTREAM",
        help="Required local variable and the variable exported to the server.",
    )
    parser.add_argument(
        "--optional-env",
        action="append",
        default=[],
        type=parse_mapping,
        metavar="LOCAL=UPSTREAM",
        help="Optional local variable and the variable exported to the server.",
    )
    parser.add_argument(
        "--providers",
        default=",".join(ALL_PROVIDERS),
        help="Comma-separated provider list, or none (default: all).",
    )
    parser.add_argument("server", help="Lowercase kebab-case server name.")
    parser.add_argument(
        "command",
        nargs=argparse.REMAINDER,
        help="Pinned server command, placed after --.",
    )
    args = parser.parse_args()
    if not SERVER_NAME.fullmatch(args.server):
        parser.error("server must use lowercase kebab-case")
    if not args.command:
        parser.error("provide the server command after --")
    if args.command[0] == "--":
        args.command = args.command[1:]
    if not args.command:
        parser.error("provide the server command after --")

    local_names = [item.local for item in args.required_env + args.optional_env]
    upstream_names = [item.upstream for item in args.required_env + args.optional_env]
    if len(local_names) != len(set(local_names)):
        parser.error("each local environment variable may be mapped only once")
    if len(upstream_names) != len(set(upstream_names)):
        parser.error("each upstream environment variable may be mapped only once")
    try:
        args.providers = parse_providers(args.providers)
    except ValueError as error:
        parser.error(str(error))
    return args


def shell_assignment(mapping: EnvMapping, required: bool) -> list[str]:
    if required:
        return [f'export {mapping.upstream}="${{{mapping.local}}}"']
    return [
        f'if [[ -n "${{{mapping.local}:-}}" ]]; then',
        f'    export {mapping.upstream}="${{{mapping.local}}}"',
        "fi",
    ]


def render_launcher(args: argparse.Namespace) -> str:
    env_override = f"MCP_{args.server.upper().replace('-', '_')}_ENV_FILE"
    lines = [
        "#!/usr/bin/env bash",
        "set -euo pipefail",
        "",
        'SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"',
        'PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"',
        f'ENV_FILE="${{{env_override}:-"$SCRIPT_DIR/.env"}}"',
        "",
        'if [[ -f "$ENV_FILE" ]]; then',
        "    set -a",
        "    # shellcheck disable=SC1090",
        '    source "$ENV_FILE"',
        "    set +a",
        "fi",
    ]
    for mapping in args.required_env:
        lines.extend(
            [
                "",
                f'if [[ -z "${{{mapping.local}:-}}" ]]; then',
                f'    echo "Missing {mapping.local} in $ENV_FILE" >&2',
                "    exit 65",
                "fi",
            ]
        )
    for mapping in args.required_env:
        lines.extend(["", *shell_assignment(mapping, required=True)])
    for mapping in args.optional_env:
        lines.extend(["", *shell_assignment(mapping, required=False)])

    command = " ".join(shlex.quote(token) for token in args.command)
    lines.extend(["", 'cd "$PROJECT_ROOT"', f"exec {command}", ""])
    return "\n".join(lines)


def render_env_example(args: argparse.Namespace) -> str:
    lines: list[str] = []
    for mapping in args.required_env:
        lines.append(f"{mapping.local}=")
    for mapping in args.optional_env:
        lines.append(f"# {mapping.local}=")
    return "\n".join(lines) + "\n"


def main() -> int:
    args = parse_args()
    project_root = args.project_root.expanduser().resolve()
    target = project_root / "scripts" / "mcp" / args.server
    if target.exists():
        raise SystemExit(f"Refusing to overwrite existing directory: {target}")
    launcher_content = render_launcher(args)
    env_example_content = (
        render_env_example(args) if args.required_env or args.optional_env else None
    )
    gitignore_content = ".env\n.env.local\n" if env_example_content is not None else None
    artifact_prefix = f"scripts/mcp/{args.server}"
    artifacts = [
        artifact_record(f"{artifact_prefix}/start.sh", launcher_content, "launcher")
    ]
    if env_example_content is not None and gitignore_content is not None:
        artifacts.extend(
            [
                artifact_record(
                    f"{artifact_prefix}/.env.example",
                    env_example_content,
                    "environment-template",
                ),
                artifact_record(
                    f"{artifact_prefix}/.gitignore",
                    gitignore_content,
                    "secret-ignore-rules",
                ),
            ]
        )
    try:
        registration = plan_registration(
            project_root,
            (args.server,),
            providers=args.providers,
            require_launchers=False,
            artifacts=tuple(artifacts),
        )
    except ValueError as error:
        raise SystemExit(str(error)) from error

    target.mkdir(parents=True)
    launcher = target / "start.sh"
    launcher.write_text(launcher_content, encoding="utf-8")
    launcher.chmod(launcher.stat().st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)

    if env_example_content is not None and gitignore_content is not None:
        (target / ".env.example").write_text(env_example_content, encoding="utf-8")
        (target / ".gitignore").write_text(gitignore_content, encoding="utf-8")

    write_registration(registration)
    print(target)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
