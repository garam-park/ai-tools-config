---
name: start-task
description: Start a work item from the Innopam Notion task database by task ID. Use when the user invokes `$start-task`, asks to start a Notion task such as `TSK-3477`, or wants Codex to fetch a task from the `솔루션 개발팀 작업` database, mark it in progress, create a task branch from develop, and proceed with implementation in this repository.
---

# Start Task

## Overview

Start a Notion task from `솔루션 개발팀 작업` by `작업 ID`, create the implementation branch from `develop`, then implement the task when the Notion content is actionable.

## Task Source

- Workspace: `(주)이노팸`
- Database: `솔루션 개발팀 작업`
- Database ID: `71842431-f19c-4f43-9df7-461805cf3895`
- Data source ID, if the MCP supports it: `42e60fb3-5260-429b-8af4-ed28535f295b`
- Task ID property: `작업 ID` (`unique_id`, prefix `TSK`)
- Status property: `상태`
- In-progress status: `진행 중`
- Terminal statuses: `완료`, `PR완료(DEV)`, `보관됨`

## Workflow

1. Parse the first non-empty argument as the task ID. Accept `TSK-3477`, `tsk-3477`, or `3477`; normalize to display ID `TSK-3477` and unique ID number `3477`.
2. Fetch exactly one Notion page for that unique ID. Prefer `scripts/notion_task.py` because it handles query, token loading, terminal-status guard, and sanitized JSON output.
3. Start the task by setting `상태` to `진행 중` unless it is already terminal.
4. Read enough page blocks and properties to understand the work. Include `작업 이름`, `작업 ID`, `상태`, `우선순위`, `태그`, `담당자`, due dates, `요약`, `Description`, and meaningful body text in your working context.
5. Read `README.md` first for project navigation, then apply relevant `AGENTS.md` and `.claude/rules/` rules.
6. Prepare implementation branch before code edits:
   - Identify the Git repo that will receive implementation changes, usually one of `repos/gygo-svc3d-front-uamms`, `repos/gygo-svc3d-back-uamms`, or another repo named by the Notion body. If multiple repos require changes and the PR strategy is unclear, ask the user before branching.
   - Inspect `git status --short --branch` in the target repo.
   - Start from `develop`: switch to `develop`, then create `feature/<TASK-ID>/<short-slug>` such as `feature/TSK-3478/map-location-persistence`.
   - If the repo is already on a suitable task branch for the same task, continue there after confirming it tracks the intended base.
   - If the repo is not clean, is on an unrelated branch, has staged/unstaged changes you did not make, has an existing conflicting task branch, is detached, or appears diverged from its remote/base, stop and ask a concise question about how to proceed. Do not stash, reset, rebase, delete branches, or overwrite user work without explicit approval.
   - If branch creation needs network state that is blocked by sandboxing, request escalation for the relevant `git fetch`, `git pull`, or `git push` command.
7. Do not create or update `logs/YYYY-MM-DD.md`.
8. Implement the task end to end if the Notion content gives enough detail. Ask a concise clarification only when the task cannot be safely started.

## Script Usage

Run this from the repository root:

```bash
python3 /Users/garam/.codex/skills/start-task/scripts/notion_task.py TSK-3477 --start --config .codex/config.toml
```

If sandboxed network access blocks the script, request escalation for that command. The script reads `NOTION_TOKEN` from `.codex/config.toml` or the environment and never prints it.

The output is JSON. If `updated_status` is `false` because the task is terminal, do not override Notion status unless the user explicitly asks.

## Repository Rules

If backend controllers are changed, update `docs/develop/API-guide/` in the same turn. If an irreversible architecture, data model, infrastructure, library, auth, or policy decision is made, add an ADR under `docs/decisions/`.
