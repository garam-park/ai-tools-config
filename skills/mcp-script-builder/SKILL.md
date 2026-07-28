---
name: mcp-script-builder
description: Create, adapt, register, validate, detach, and safely uninstall project-local MCP launchers under scripts/mcp/{server}/; synchronize Codex, Claude Code, VS Code GitHub Copilot, and OpenCode project configuration; and track ownership plus generated-file hashes in the project .omm manifest. Use when adding, adopting, repairing, removing, reclaiming, or auditing a repository MCP server or replacing provider-specific MCP startup with a shared stdio launcher.
---

# MCP Script Builder

Keep each MCP server's startup and environment contract in one project-local launcher. Make provider configuration a thin reference to that launcher and use `.omm` as the ownership manifest for servers managed by this skill.

## Workflow

1. Read repository instructions, `.omm`, existing Provider configurations, `scripts/mcp`, ignore rules, and package-manager conventions. Do not read `.env`, `.env.local`, credentials, or keychain contents.
2. Confirm the server's current official command, required variables, transport, and exact version. Never guess package names, flags, or environment variables.
3. Prefer native `stdio`. For a remote-only server, prefer an official stdio bridge; otherwise pin a well-established bridge and explain its trust boundary.
4. Create or adapt `scripts/mcp/<server>/start.sh`. Use the scaffold script for a new conventional launcher.
5. By default, register the launcher in all four project configurations:
   - Codex: `.codex/config.toml`
   - Claude Code: `.mcp.json`
   - VS Code GitHub Copilot: `.vscode/mcp.json`
   - OpenCode: `opencode.json`
6. Record the server, ownership, and non-secret generated-file hashes in `.omm` even when the user explicitly opts out of some or all Provider configurations.
7. For removal, plan a dry run first. Detach Provider entries by default; delete generated files only when the user explicitly requests it and every recorded hash still matches.
8. Validate launcher syntax, permissions, Provider parsing or discovery, manifest consistency, secret handling, and safe failure behavior.

Do not mutate user-level or global Provider configuration unless the user explicitly requests it.

## Notion Connection Authentication

For a server named `notion`, default to a token-authenticated Notion internal integration (connection), even though Notion recommends its hosted OAuth server for most users.

- Treat requests mentioning a Notion connection, integration, existing token, or unattended authentication as intent to use the local token-authenticated server.
- Verify the current official package version at execution time, pin it exactly, and run `@notionhq/notion-mcp-server@<version>` with native `stdio`.
- Use the upstream `NOTION_TOKEN` variable. Prefer a namespaced local `MCP_NOTION_TOKEN` mapped to `NOTION_TOKEN`; accept an existing `NOTION_TOKEN` convention without reading or exposing its value.
- Do not use `https://mcp.notion.com/mcp`, `mcp-remote`, or an OAuth flow unless the user explicitly requests hosted OAuth.
- Never read token files or print authentication responses. Validate a configured token with the read-only `API-get-self` tool and report only success or failure.
- Follow an explicit user request for OAuth when it conflicts with this default.

## Create A New Launcher

Run:

```bash
python3 <skill-dir>/scripts/scaffold_project_mcp.py \
  --project-root <project-root> \
  --required-env MCP_EXAMPLE_TOKEN=UPSTREAM_TOKEN \
  example \
  -- npx -y @vendor/example-mcp@1.2.3
```

The command creates the launcher, optional environment templates, all four Provider project entries, and `.omm`. It records hashes for generated non-secret files. Use `--required-env LOCAL=UPSTREAM` and `--optional-env LOCAL=UPSTREAM` repeatedly as needed.

All Providers are selected by default. Only when the user or repository policy requires a narrower set, pass:

```bash
--providers codex,claude,vscode-copilot,opencode
```

Use `--providers none` to create no Provider entries while still recording `.omm`. The scaffold refuses to overwrite an existing server directory or conflicting Provider entry.

## Adopt Or Resynchronize An Existing Launcher

For an existing executable launcher, run:

```bash
python3 <skill-dir>/scripts/sync_project_mcp.py \
  --project-root <project-root> \
  <server>
```

Run it once per server. It preserves unrelated Provider entries, accepts an already-compatible entry, refuses a conflicting entry, and records the server in `.omm`.

## Detach Or Remove A Managed Server

Always preview first:

```bash
python3 <skill-dir>/scripts/remove_project_mcp.py \
  --project-root <project-root> \
  <server>
```

The default plan removes matching Provider entries and the `.omm` entry but keeps launcher files. Apply that detach only after reviewing the plan:

```bash
python3 <skill-dir>/scripts/remove_project_mcp.py \
  --project-root <project-root> \
  --apply \
  <server>
```

Delete generated files only when the user explicitly requests full uninstall:

```bash
python3 <skill-dir>/scripts/remove_project_mcp.py \
  --project-root <project-root> \
  --delete-generated \
  --apply \
  <server>
```

Refuse the entire plan when a Provider entry points elsewhere or a generated file hash changed. Never delete `.env` or `.env.local`; report them as retained secrets for the user to handle separately.

## `.omm` Contract

Treat the project-root `.omm` file as strict JSON owned by this skill:

```json
{
  "formatVersion": 2,
  "managedBy": "mcp-script-builder",
  "providers": {
    "codex": ".codex/config.toml",
    "claude": ".mcp.json",
    "vscode-copilot": ".vscode/mcp.json",
    "opencode": "opencode.json"
  },
  "servers": {
    "example": {
      "transport": "stdio",
      "launcher": "scripts/mcp/example/start.sh",
      "providers": ["codex", "claude", "vscode-copilot", "opencode"],
      "ownership": "generated",
      "artifacts": [
        {
          "path": "scripts/mcp/example/start.sh",
          "sha256": "<sha256>",
          "role": "launcher"
        }
      ]
    }
  }
}
```

Use `ownership: generated` only for files created by the scaffold. Use `ownership: adopted` with an empty `artifacts` list for an existing launcher. Migrate v1 entries to adopted ownership so historical files are never assumed safe to delete.

Never store credentials, environment values, absolute machine-specific paths, secret-file hashes, or generated timestamps in `.omm`. Preserve unknown top-level fields. Before removing or renaming a managed server, use `.omm` to resolve its launcher and Provider entries; remove only entries still pointing to that launcher, then update the manifest.

## Launcher Contract

- Resolve the launcher and project root from `BASH_SOURCE[0]`; run from the project root.
- Allow `MCP_<SERVER>_ENV_FILE`, defaulting to `<launcher-dir>/.env`.
- Load the environment before checking mandatory variables.
- Emit diagnostics only to stderr; reserve stdout for MCP `stdio`.
- End with `exec` so signals and exit codes reach the server.
- Pin package or bridge versions.
- Use namespaced local secrets such as `MCP_GITHUB_TOKEN`, then export exact upstream names.
- Serialize structured headers or JSON with a real serializer.
- Avoid Provider detection, Provider branches, and secret values in the launcher.

## Provider Configuration Contract

Point every selected Provider at the same launcher without duplicating server arguments or secrets:

- Resolve Codex project paths relative to `.codex/config.toml`.
- Resolve Claude Code and OpenCode commands from the project root.
- Use `${workspaceFolder}` in VS Code.
- Detect an existing OpenCode v2 `mcp.servers` object; otherwise use the stable `mcp` object.
- Preserve unrelated configuration and refuse to overwrite a same-name entry that points elsewhere.
- If a JSON configuration contains comments or is not strict JSON, preserve it and update it manually instead of stripping comments.

## Verification

Run the checks that apply:

```bash
bash -n scripts/mcp/<server>/start.sh
test -x scripts/mcp/<server>/start.sh
```

Also verify:

- `.omm` parses as JSON and matches the launcher and selected Providers.
- Generated artifact hashes match immediately after scaffolding.
- A removal dry run changes no files.
- Full uninstall refuses modified artifacts and never removes `.env` or `.env.local`.
- Codex and installed Provider CLIs discover the project entry when a read-only inspection command exists.
- Starting without a required value fails nonzero, names only the missing variable, and writes no stdout.
- `.env.example` contains placeholders only; `.env` and `.env.local` remain ignored.
- The final command uses the verified package and exact version.
- A safe smoke test reaches MCP initialization without wrapper protocol noise.

Distinguish file-format validation, Provider discovery, trust approval, authentication, and end-to-end MCP initialization in the final report.
