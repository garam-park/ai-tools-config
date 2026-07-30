#!/usr/bin/env python3
"""Register existing project MCP launchers with supported providers and .omm."""

from __future__ import annotations

import argparse
from pathlib import Path

from project_mcp_registry import (
    ALL_PROVIDERS,
    parse_providers,
    plan_registration,
    write_registration,
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Register existing scripts/mcp/<server>/start.sh launchers."
    )
    parser.add_argument(
        "--project-root",
        type=Path,
        default=Path.cwd(),
        help="Project root (default: current directory).",
    )
    parser.add_argument(
        "--providers",
        default=",".join(ALL_PROVIDERS),
        help="Comma-separated provider list, or none (default: all).",
    )
    parser.add_argument("server", help="Server name to register.")
    args = parser.parse_args()
    try:
        args.providers = parse_providers(args.providers)
    except ValueError as error:
        parser.error(str(error))
    return args


def main() -> int:
    args = parse_args()
    try:
        plan = plan_registration(
            args.project_root,
            (args.server,),
            providers=args.providers,
            require_launchers=True,
        )
        write_registration(plan)
    except ValueError as error:
        raise SystemExit(str(error)) from error
    print(f"registered={args.server}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
