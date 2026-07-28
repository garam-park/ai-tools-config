#!/usr/bin/env python3
"""Synchronize project MCP launchers, provider configs, and the .omm manifest."""

from __future__ import annotations

import hashlib
import json
import os
import re
import tempfile
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Optional


ALL_PROVIDERS = ("codex", "claude", "vscode-copilot", "opencode")
PROVIDER_PATHS = {
    "codex": ".codex/config.toml",
    "claude": ".mcp.json",
    "vscode-copilot": ".vscode/mcp.json",
    "opencode": "opencode.json",
}
SERVER_NAME = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")


@dataclass(frozen=True)
class RegistrationPlan:
    files: dict[Path, str]


@dataclass(frozen=True)
class RemovalPlan:
    provider_files: dict[Path, str]
    manifest_path: Path
    manifest_content: str
    artifact_paths: tuple[Path, ...]
    actions: tuple[str, ...]


def parse_providers(value: str) -> tuple[str, ...]:
    if value.strip().lower() == "none":
        return ()
    providers = tuple(item.strip().lower() for item in value.split(",") if item.strip())
    unknown = sorted(set(providers) - set(ALL_PROVIDERS))
    if unknown:
        raise ValueError(
            f"unknown provider(s): {', '.join(unknown)}; "
            f"use {', '.join(ALL_PROVIDERS)}, or none"
        )
    if len(providers) != len(set(providers)):
        raise ValueError("each provider may be selected only once")
    return providers


def artifact_record(path: str, content: str, role: str) -> dict[str, str]:
    return {
        "path": path,
        "sha256": hashlib.sha256(content.encode("utf-8")).hexdigest(),
        "role": role,
    }


def _load_json(path: Path, default: dict) -> dict:
    if not path.exists():
        return default
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as error:
        raise ValueError(
            f"{path} is not strict JSON; preserve it and update it manually"
        ) from error
    if not isinstance(value, dict):
        raise ValueError(f"{path} must contain a JSON object")
    return value


def _dump_json(value: dict) -> str:
    return json.dumps(value, indent=2, ensure_ascii=False) + "\n"


def _normalize_manifest(path: Path, data: dict) -> dict:
    version = data.get("formatVersion")
    if version == 1:
        servers = data.get("servers", {})
        if not isinstance(servers, dict):
            raise ValueError(f"{path}: servers must be an object")
        for entry in servers.values():
            if isinstance(entry, dict):
                entry.setdefault("ownership", "adopted")
                entry.setdefault("artifacts", [])
        data["formatVersion"] = 2
    elif version != 2:
        raise ValueError(f"{path}: unsupported formatVersion")
    if data.get("managedBy") != "mcp-script-builder":
        raise ValueError(f"{path}: managedBy must be mcp-script-builder")
    return data


def _compatible_json_entry(
    path: Path,
    server: str,
    existing: object,
    expected_command: object,
    expected_type: str,
    require_empty_args: bool = False,
) -> None:
    compatible = (
        isinstance(existing, dict)
        and existing.get("command") == expected_command
        and existing.get("type", expected_type) == expected_type
    )
    if require_empty_args and isinstance(existing, dict):
        compatible = compatible and existing.get("args", []) == []
    if not compatible:
        raise ValueError(
            f"{path} already defines {server!r} with a different launcher; "
            "refusing to overwrite it"
        )


def _plan_claude(project_root: Path, server: str) -> tuple[Path, str]:
    path = project_root / PROVIDER_PATHS["claude"]
    data = _load_json(path, {})
    servers = data.setdefault("mcpServers", {})
    if not isinstance(servers, dict):
        raise ValueError(f"{path}: mcpServers must be an object")
    command = f"./scripts/mcp/{server}/start.sh"
    expected = {"type": "stdio", "command": command, "args": []}
    if server in servers:
        _compatible_json_entry(
            path, server, servers[server], command, "stdio", require_empty_args=True
        )
    else:
        servers[server] = expected
    return path, _dump_json(data)


def _plan_vscode(project_root: Path, server: str) -> tuple[Path, str]:
    path = project_root / PROVIDER_PATHS["vscode-copilot"]
    data = _load_json(path, {})
    servers = data.setdefault("servers", {})
    if not isinstance(servers, dict):
        raise ValueError(f"{path}: servers must be an object")
    command = f"${{workspaceFolder}}/scripts/mcp/{server}/start.sh"
    expected = {"type": "stdio", "command": command, "args": []}
    if server in servers:
        _compatible_json_entry(
            path, server, servers[server], command, "stdio", require_empty_args=True
        )
    else:
        servers[server] = expected
    return path, _dump_json(data)


def _opencode_servers(data: dict, path: Path) -> tuple[dict, bool]:
    mcp = data.setdefault("mcp", {})
    if not isinstance(mcp, dict):
        raise ValueError(f"{path}: mcp must be an object")
    if isinstance(mcp.get("servers"), dict):
        return mcp["servers"], True
    return mcp, False


def _plan_opencode(project_root: Path, server: str) -> tuple[Path, str]:
    path = project_root / PROVIDER_PATHS["opencode"]
    data = _load_json(path, {"$schema": "https://opencode.ai/config.json"})
    servers, is_v2 = _opencode_servers(data, path)
    command = [f"./scripts/mcp/{server}/start.sh"]
    expected = (
        {"type": "local", "command": command}
        if is_v2
        else {"type": "local", "command": command, "cwd": ".", "enabled": True}
    )
    if server in servers:
        _compatible_json_entry(path, server, servers[server], command, "local")
    else:
        servers[server] = expected
    return path, _dump_json(data)


def _toml_server_pattern(server: str) -> re.Pattern[str]:
    escaped = re.escape(server)
    return re.compile(
        rf'^\[mcp_servers\.(?:"{escaped}"|{escaped})\]\s*$',
        flags=re.MULTILINE,
    )


def _codex_block(
    content: str, server: str
) -> Optional[tuple[int, int, str]]:
    match = _toml_server_pattern(server).search(content)
    if not match:
        return None
    next_table = re.search(r"^\[", content[match.end() :], flags=re.MULTILINE)
    end = match.end() + next_table.start() if next_table else len(content)
    return match.start(), end, content[match.end() : end]


def _plan_codex(project_root: Path, server: str) -> tuple[Path, str]:
    path = project_root / PROVIDER_PATHS["codex"]
    content = path.read_text(encoding="utf-8") if path.exists() else ""
    command = f'command = "../scripts/mcp/{server}/start.sh"'
    cwd = 'cwd = ".."'
    block = _codex_block(content, server)
    if block:
        if command not in block[2] or cwd not in block[2]:
            raise ValueError(
                f"{path} already defines {server!r} with a different launcher; "
                "refusing to overwrite it"
            )
        return path, content

    escaped = re.escape(server)
    related = re.search(
        rf'^\[mcp_servers\.(?:"{escaped}"|{escaped})(?:\.|\])',
        content,
        flags=re.MULTILINE,
    )
    if related:
        raise ValueError(
            f"{path} already contains nested configuration for {server!r}; "
            "update it manually"
        )

    new_block = "\n".join(
        [
            f"[mcp_servers.{server}]",
            command,
            cwd,
            "enabled = true",
        ]
    )
    prefix = content.rstrip()
    updated = f"{prefix}\n\n{new_block}\n" if prefix else f"{new_block}\n"
    return path, updated


def _plan_manifest(
    project_root: Path,
    server: str,
    providers: tuple[str, ...],
    artifacts: Optional[tuple[dict[str, str], ...]],
) -> tuple[Path, str]:
    path = project_root / ".omm"
    data = _load_json(
        path,
        {
            "formatVersion": 2,
            "managedBy": "mcp-script-builder",
            "providers": dict(PROVIDER_PATHS),
            "servers": {},
        },
    )
    data = _normalize_manifest(path, data)
    manifest_servers = data.setdefault("servers", {})
    if not isinstance(manifest_servers, dict):
        raise ValueError(f"{path}: servers must be an object")
    data["providers"] = dict(PROVIDER_PATHS)

    launcher = f"scripts/mcp/{server}/start.sh"
    existing = manifest_servers.get(server)
    if existing is not None and (
        not isinstance(existing, dict) or existing.get("launcher") != launcher
    ):
        raise ValueError(f"{path} already records {server!r} with a different launcher")

    if existing is None:
        entry = {
            "transport": "stdio",
            "launcher": launcher,
            "providers": list(providers),
            "ownership": "generated" if artifacts is not None else "adopted",
            "artifacts": list(artifacts or ()),
        }
    else:
        entry = existing
        entry["transport"] = "stdio"
        entry["providers"] = list(providers)
        entry.setdefault("ownership", "adopted")
        entry.setdefault("artifacts", [])
        if artifacts is not None:
            entry["ownership"] = "generated"
            entry["artifacts"] = list(artifacts)
    manifest_servers[server] = entry
    data["servers"] = {
        key: manifest_servers[key] for key in sorted(manifest_servers)
    }
    return path, _dump_json(data)


def plan_registration(
    project_root: Path,
    servers: Iterable[str],
    providers: tuple[str, ...] = ALL_PROVIDERS,
    require_launchers: bool = True,
    artifacts: Optional[tuple[dict[str, str], ...]] = None,
) -> RegistrationPlan:
    root = project_root.expanduser().resolve()
    server_names = tuple(servers)
    if len(server_names) != 1:
        raise ValueError("register one server at a time")
    server = server_names[0]
    if not SERVER_NAME.fullmatch(server):
        raise ValueError(f"invalid server name: {server!r}")
    if require_launchers:
        launcher = root / "scripts" / "mcp" / server / "start.sh"
        if not launcher.is_file():
            raise ValueError(f"missing launcher: {launcher}")
        if not os.access(launcher, os.X_OK):
            raise ValueError(f"launcher is not executable: {launcher}")

    files: dict[Path, str] = {}
    planner_by_provider = {
        "codex": _plan_codex,
        "claude": _plan_claude,
        "vscode-copilot": _plan_vscode,
        "opencode": _plan_opencode,
    }
    for provider in providers:
        path, content = planner_by_provider[provider](root, server)
        files[path] = content
    manifest_path, manifest_content = _plan_manifest(
        root, server, providers, artifacts
    )
    files[manifest_path] = manifest_content
    return RegistrationPlan(files=files)


def _plan_remove_json(
    project_root: Path, provider: str, server: str
) -> tuple[Path, str, bool]:
    path = project_root / PROVIDER_PATHS[provider]
    if not path.exists():
        return path, "", False
    data = _load_json(path, {})
    if provider == "claude":
        servers = data.get("mcpServers", {})
        command: object = f"./scripts/mcp/{server}/start.sh"
        expected_type = "stdio"
        require_empty_args = True
    elif provider == "vscode-copilot":
        servers = data.get("servers", {})
        command = f"${{workspaceFolder}}/scripts/mcp/{server}/start.sh"
        expected_type = "stdio"
        require_empty_args = True
    else:
        servers, _ = _opencode_servers(data, path)
        command = [f"./scripts/mcp/{server}/start.sh"]
        expected_type = "local"
        require_empty_args = False
    if not isinstance(servers, dict):
        raise ValueError(f"{path}: MCP server collection must be an object")
    if server not in servers:
        return path, path.read_text(encoding="utf-8"), False
    _compatible_json_entry(
        path,
        server,
        servers[server],
        command,
        expected_type,
        require_empty_args=require_empty_args,
    )
    del servers[server]
    return path, _dump_json(data), True


def _plan_remove_codex(
    project_root: Path, server: str
) -> tuple[Path, str, bool]:
    path = project_root / PROVIDER_PATHS["codex"]
    if not path.exists():
        return path, "", False
    content = path.read_text(encoding="utf-8")
    block = _codex_block(content, server)
    if not block:
        return path, content, False
    expected_command = f'command = "../scripts/mcp/{server}/start.sh"'
    if expected_command not in block[2] or 'cwd = ".."' not in block[2]:
        raise ValueError(
            f"{path} defines {server!r} with a different launcher; "
            "refusing to remove it"
        )
    before = content[: block[0]].rstrip()
    after = content[block[1] :].lstrip()
    if before and after:
        updated = f"{before}\n\n{after}"
    elif before:
        updated = f"{before}\n"
    else:
        updated = after
    return path, updated, True


def _safe_artifact_path(
    project_root: Path, server: str, relative_path: str
) -> Path:
    relative = Path(relative_path)
    if relative.is_absolute() or ".." in relative.parts:
        raise ValueError(f"unsafe artifact path in .omm: {relative_path}")
    if relative.parts[:3] != ("scripts", "mcp", server):
        raise ValueError(
            f"artifact is outside scripts/mcp/{server}: {relative_path}"
        )
    path = (project_root / relative).resolve()
    try:
        path.relative_to(project_root)
    except ValueError as error:
        raise ValueError(f"artifact escapes project root: {relative_path}") from error
    if path.name in {".env", ".env.local"}:
        raise ValueError(f"refusing to manage secret file: {relative_path}")
    return path


def _validate_artifacts(
    project_root: Path, server: str, entry: dict, delete_generated: bool
) -> tuple[Path, ...]:
    if not delete_generated:
        return ()
    if entry.get("ownership") != "generated":
        raise ValueError("server was adopted, so generated files cannot be deleted")
    artifacts = entry.get("artifacts")
    if not isinstance(artifacts, list) or not artifacts:
        raise ValueError("no generated artifact hashes are recorded")
    paths: list[Path] = []
    for artifact in artifacts:
        if not isinstance(artifact, dict):
            raise ValueError("invalid artifact record in .omm")
        relative_path = artifact.get("path")
        expected_hash = artifact.get("sha256")
        if not isinstance(relative_path, str) or not isinstance(expected_hash, str):
            raise ValueError("invalid artifact path or hash in .omm")
        path = _safe_artifact_path(project_root, server, relative_path)
        if not path.exists():
            continue
        if not path.is_file():
            raise ValueError(f"managed artifact is not a file: {path}")
        actual_hash = hashlib.sha256(path.read_bytes()).hexdigest()
        if actual_hash != expected_hash:
            raise ValueError(f"managed artifact changed; refusing to delete: {path}")
        paths.append(path)
    return tuple(paths)


def plan_removal(
    project_root: Path, server: str, delete_generated: bool = False
) -> RemovalPlan:
    root = project_root.expanduser().resolve()
    if not SERVER_NAME.fullmatch(server):
        raise ValueError(f"invalid server name: {server!r}")
    manifest_path = root / ".omm"
    data = _normalize_manifest(manifest_path, _load_json(manifest_path, {}))
    manifest_servers = data.get("servers")
    if not isinstance(manifest_servers, dict) or server not in manifest_servers:
        raise ValueError(f"{server!r} is not managed in {manifest_path}")
    entry = manifest_servers[server]
    if not isinstance(entry, dict):
        raise ValueError(f"{manifest_path}: invalid server entry for {server!r}")
    expected_launcher = f"scripts/mcp/{server}/start.sh"
    if entry.get("launcher") != expected_launcher:
        raise ValueError(
            f"{manifest_path}: unexpected launcher for {server!r}"
        )

    providers = entry.get("providers", [])
    if not isinstance(providers, list) or any(
        provider not in ALL_PROVIDERS for provider in providers
    ):
        raise ValueError(f"{manifest_path}: invalid providers for {server!r}")

    provider_files: dict[Path, str] = {}
    actions: list[str] = []
    for provider in providers:
        if provider == "codex":
            path, content, removed = _plan_remove_codex(root, server)
        else:
            path, content, removed = _plan_remove_json(root, provider, server)
        if removed:
            provider_files[path] = content
            actions.append(f"detach provider={provider} path={path.relative_to(root)}")
        else:
            actions.append(f"already-detached provider={provider}")

    artifact_paths = _validate_artifacts(root, server, entry, delete_generated)
    if delete_generated:
        for path in artifact_paths:
            actions.append(f"delete-generated path={path.relative_to(root)}")
    else:
        actions.append(f"keep-files launcher={entry.get('launcher', '')}")

    del manifest_servers[server]
    data["servers"] = {
        key: manifest_servers[key] for key in sorted(manifest_servers)
    }
    actions.append(f"remove-manifest server={server}")
    return RemovalPlan(
        provider_files=provider_files,
        manifest_path=manifest_path,
        manifest_content=_dump_json(data),
        artifact_paths=artifact_paths,
        actions=tuple(actions),
    )


def _atomic_write(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(
        mode="w",
        encoding="utf-8",
        dir=path.parent,
        prefix=f".{path.name}.",
        delete=False,
    ) as handle:
        handle.write(content)
        temporary = Path(handle.name)
    temporary.replace(path)


def write_registration(plan: RegistrationPlan) -> None:
    for path, content in plan.files.items():
        _atomic_write(path, content)


def apply_removal(plan: RemovalPlan) -> None:
    for path, content in plan.provider_files.items():
        _atomic_write(path, content)
    for path in plan.artifact_paths:
        path.unlink()
    parents = sorted(
        {path.parent for path in plan.artifact_paths},
        key=lambda value: len(value.parts),
        reverse=True,
    )
    for parent in parents:
        try:
            parent.rmdir()
        except OSError:
            pass
    _atomic_write(plan.manifest_path, plan.manifest_content)
