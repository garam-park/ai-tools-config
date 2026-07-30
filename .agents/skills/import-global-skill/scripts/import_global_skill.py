#!/usr/bin/env python3
"""Safely copy a global Agent Skill into this repository."""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path


NAME_RE = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")
SKIPPED_DIRS = {".git", "__pycache__"}
SKIPPED_FILES = {".DS_Store"}
SECRET_FILE_NAMES = {
    ".env",
    "credentials.json",
    "service-account.json",
    "service_account.json",
}
SECRET_SUFFIXES = {".key", ".p12", ".pfx"}


class ImportErrorWithHint(RuntimeError):
    """An expected import refusal with an actionable message."""


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Copy one global Agent Skill into a project's skills directory."
    )
    parser.add_argument("skill_name", help="global skill directory name")
    parser.add_argument(
        "--project-root",
        type=Path,
        help="destination repository root (defaults to the current git root)",
    )
    parser.add_argument(
        "--source",
        type=Path,
        help="exact source skill directory when discovery is ambiguous",
    )
    parser.add_argument(
        "--destination-name",
        help="new project skill name (defaults to skill_name)",
    )
    parser.add_argument(
        "--global-root",
        action="append",
        default=[],
        type=Path,
        help="global skills root to search; repeat to override default roots",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="validate and print the planned import without copying",
    )
    return parser.parse_args()


def validate_name(name: str, label: str) -> None:
    if len(name) > 64 or not NAME_RE.fullmatch(name):
        raise ImportErrorWithHint(
            f"{label} must be at most 64 characters using lowercase letters, "
            "digits, and hyphens."
        )


def git_root() -> Path:
    result = subprocess.run(
        ["git", "rev-parse", "--show-toplevel"],
        check=False,
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        raise ImportErrorWithHint(
            "Could not determine the project root. Run inside a git repository "
            "or pass --project-root."
        )
    return Path(result.stdout.strip()).resolve()


def resolve_project_root(explicit_root: Path | None) -> Path:
    root = explicit_root.expanduser().resolve() if explicit_root else git_root()
    if not (root / "skills").is_dir() or not (root / "install-skills.sh").is_file():
        raise ImportErrorWithHint(
            f"Destination is not an ai-tools-config project root: {root}"
        )
    return root


def default_global_roots() -> list[Path]:
    roots: list[Path] = []
    codex_home = os.environ.get("CODEX_HOME")
    if codex_home:
        roots.append(Path(codex_home).expanduser() / "skills")
    roots.extend(
        [
            Path("~/.codex/skills").expanduser(),
            Path("~/.agents/skills").expanduser(),
            Path("~/.claude/skills").expanduser(),
        ]
    )
    return deduplicate_paths(roots)


def deduplicate_paths(paths: list[Path]) -> list[Path]:
    unique: list[Path] = []
    seen: set[str] = set()
    for path in paths:
        expanded = path.expanduser().absolute()
        key = str(expanded)
        if key not in seen:
            seen.add(key)
            unique.append(expanded)
    return unique


def is_within(path: Path, parent: Path) -> bool:
    try:
        path.relative_to(parent)
        return True
    except ValueError:
        return False


def require_skill_directory(path: Path) -> Path:
    expanded = path.expanduser().absolute()
    if expanded.name == "SKILL.md":
        expanded = expanded.parent
    try:
        resolved = expanded.resolve(strict=True)
    except FileNotFoundError as exc:
        raise ImportErrorWithHint(f"Source does not exist: {expanded}") from exc
    if not resolved.is_dir() or not (resolved / "SKILL.md").is_file():
        raise ImportErrorWithHint(
            f"Source is not a skill directory containing SKILL.md: {expanded}"
        )
    return resolved


def discover_source(
    skill_name: str,
    explicit_source: Path | None,
    global_roots: list[Path],
    project_skill_roots: list[Path],
) -> tuple[Path, list[Path]]:
    if explicit_source:
        candidates = [require_skill_directory(explicit_source)]
    else:
        candidates = []
        for root in global_roots:
            candidate = root / skill_name
            if candidate.exists() or candidate.is_symlink():
                candidates.append(require_skill_directory(candidate))

    project_roots_resolved = [root.resolve() for root in project_skill_roots]
    external: list[Path] = []
    seen: set[Path] = set()
    refused_project_paths: list[Path] = []
    for candidate in candidates:
        if any(is_within(candidate, root) for root in project_roots_resolved):
            refused_project_paths.append(candidate)
            continue
        if candidate not in seen:
            seen.add(candidate)
            external.append(candidate)

    if not external:
        searched = "\n".join(f"  - {root / skill_name}" for root in global_roots)
        project_note = ""
        if refused_project_paths:
            project_note = (
                "\nFound only project-managed links resolving back into this "
                "repository; those cannot be re-imported."
            )
        raise ImportErrorWithHint(
            f"No external global skill named '{skill_name}' was found.{project_note}"
            f"\nChecked:\n{searched}"
        )
    if len(external) > 1:
        choices = "\n".join(f"  - {path}" for path in external)
        raise ImportErrorWithHint(
            f"Multiple distinct sources were found for '{skill_name}'. "
            f"Re-run with --source and one exact path:\n{choices}"
        )
    return external[0], refused_project_paths


def read_frontmatter_name(skill_md: Path) -> str:
    lines = skill_md.read_text(encoding="utf-8").splitlines()
    if not lines or lines[0].strip() != "---":
        raise ImportErrorWithHint(f"SKILL.md has no YAML frontmatter: {skill_md}")
    try:
        end = next(i for i in range(1, len(lines)) if lines[i].strip() == "---")
    except StopIteration as exc:
        raise ImportErrorWithHint(
            f"SKILL.md frontmatter is not closed: {skill_md}"
        ) from exc
    for line in lines[1:end]:
        match = re.match(r"^name:\s*(.+?)\s*$", line)
        if match:
            name = match.group(1).strip().strip("\"'")
            validate_name(name, "SKILL.md frontmatter name")
            return name
    raise ImportErrorWithHint(f"SKILL.md frontmatter has no name: {skill_md}")


def preflight_source(source: Path) -> None:
    for current_root, dir_names, file_names in os.walk(source, followlinks=False):
        current = Path(current_root)
        dir_names[:] = [name for name in dir_names if name not in SKIPPED_DIRS]
        for name in [*dir_names, *file_names]:
            candidate = current / name
            if candidate.is_symlink():
                raise ImportErrorWithHint(
                    "Source contains a symlink, so it is not self-contained: "
                    f"{candidate}"
                )
        for name in file_names:
            lower_name = name.lower()
            is_unmistakable_env = lower_name.startswith(".env.") and not lower_name.endswith(
                (".example", ".sample", ".template")
            )
            if (
                lower_name in SECRET_FILE_NAMES
                or is_unmistakable_env
                or Path(lower_name).suffix in SECRET_SUFFIXES
            ):
                raise ImportErrorWithHint(
                    "Source contains a likely secret file; remove or replace it "
                    f"before importing: {current / name}"
                )


def ignore_transient_files(_: str, names: list[str]) -> set[str]:
    ignored = {
        name
        for name in names
        if name in SKIPPED_DIRS
        or name in SKIPPED_FILES
        or name.endswith((".pyc", ".pyo"))
    }
    return ignored


def replace_skill_name(path: Path, old_name: str, new_name: str) -> None:
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines(keepends=True)
    changed_frontmatter = False
    in_frontmatter = False
    for index, line in enumerate(lines):
        if index == 0 and line.strip() == "---":
            in_frontmatter = True
            continue
        if in_frontmatter and line.strip() == "---":
            break
        if in_frontmatter and re.match(r"^name:\s*", line):
            newline = "\n" if line.endswith("\n") else ""
            lines[index] = f"name: {new_name}{newline}"
            changed_frontmatter = True
            break
    if not changed_frontmatter:
        raise ImportErrorWithHint(f"Could not update name in {path}")
    updated = "".join(lines)
    updated = updated.replace(f"${old_name}", f"${new_name}")
    updated = updated.replace(f"/{old_name}", f"/{new_name}")
    path.write_text(updated, encoding="utf-8")


def normalize_agent_metadata(stage: Path, old_name: str, new_name: str) -> None:
    agents_dir = stage / "agents"
    agents_dir.mkdir(exist_ok=True)
    openai_yaml = agents_dir / "openai.yaml"
    codex_yaml = agents_dir / "codex.yaml"
    if openai_yaml.exists() and codex_yaml.exists():
        raise ImportErrorWithHint(
            "Source contains both agents/openai.yaml and agents/codex.yaml; "
            "resolve the conflicting metadata before importing."
        )
    if openai_yaml.exists():
        openai_yaml.rename(codex_yaml)
    if not codex_yaml.exists():
        display_name = new_name.replace("-", " ").title()
        short_description = "가져온 프로젝트 스킬을 이 저장소의 워크플로에서 사용합니다"
        default_prompt = f"${new_name}를 사용해 요청한 작업을 수행해줘."
        codex_yaml.write_text(
            "interface:\n"
            f"  display_name: {json.dumps(display_name, ensure_ascii=False)}\n"
            f"  short_description: {json.dumps(short_description, ensure_ascii=False)}\n"
            f"  default_prompt: {json.dumps(default_prompt, ensure_ascii=False)}\n",
            encoding="utf-8",
        )
    elif old_name != new_name:
        text = codex_yaml.read_text(encoding="utf-8")
        text = text.replace(f"${old_name}", f"${new_name}")
        codex_yaml.write_text(text, encoding="utf-8")


def import_skill(
    source: Path,
    destination: Path,
    source_name: str,
    destination_name: str,
) -> None:
    stage_path = Path(
        tempfile.mkdtemp(
            prefix=f".import-{destination_name}-", dir=destination.parent
        )
    )
    try:
        shutil.copytree(
            source,
            stage_path,
            dirs_exist_ok=True,
            ignore=ignore_transient_files,
        )
        if source_name != destination_name:
            replace_skill_name(
                stage_path / "SKILL.md", source_name, destination_name
            )
        normalize_agent_metadata(stage_path, source_name, destination_name)
        stage_path.rename(destination)
    except Exception:
        if stage_path.exists():
            shutil.rmtree(stage_path)
        raise


def main() -> int:
    args = parse_args()
    try:
        validate_name(args.skill_name, "skill_name")
        destination_name = args.destination_name or args.skill_name
        validate_name(destination_name, "destination_name")

        project_root = resolve_project_root(args.project_root)
        project_skills = project_root / "skills"
        project_skill_roots = [
            project_skills,
            project_root / ".agents" / "skills",
        ]
        destination = project_skills / destination_name
        if destination.exists() or destination.is_symlink():
            raise ImportErrorWithHint(
                f"Destination already exists; refusing to overwrite: {destination}"
            )

        roots = (
            deduplicate_paths(args.global_root)
            if args.global_root
            else default_global_roots()
        )
        source, _ = discover_source(
            args.skill_name, args.source, roots, project_skill_roots
        )
        source_name = read_frontmatter_name(source / "SKILL.md")
        preflight_source(source)

        print(f"source: {source}")
        print(f"destination: {destination}")
        if source_name != destination_name:
            print(f"rename: {source_name} -> {destination_name}")
        if args.dry_run:
            print("dry-run: import is safe to proceed")
            return 0

        import_skill(source, destination, source_name, destination_name)
        print(f"imported: {destination}")
        return 0
    except ImportErrorWithHint as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 2
    except OSError as exc:
        print(f"error: filesystem operation failed: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
