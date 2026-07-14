---
name: start-task-worktree
description: Start a work item from the Innopam Notion task database by task ID and prepare an isolated git worktree for implementation. Use when the user invokes `$start-task-worktree`, asks to start a TSK task in a worktree or work.tree, or wants Codex to fetch and start the Notion task, sync the local task file, create a feature branch from develop, add a git worktree, and proceed in that worktree for the Goyang UAM project.
---

# Start Task Worktree

## Overview

Start a Notion task from `솔루션 개발팀 작업`, synchronize the local `tasks/` workflow in the main Goyang UAM workspace, create a feature branch from `develop`, then add a separate git worktree and implement from that worktree.

This is a worktree-oriented variant of `$start-task`. Prefer it when the user explicitly asks for `$start-task-worktree`, `worktree`, or `work.tree`.

## Project Scope

- Project root: `/Users/garam/ws/workspaces/ws-goyang-uam`
- Keep local task files under the main project root, not inside implementation worktrees.
- Use the canonical repos under `repos/` as control repositories for `git worktree` commands.
- Prefer the existing ignored `.worktrees/` directory for generated worktree checkouts.
- Perform implementation edits inside the created worktree path after it exists.

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
2. Fetch exactly one Notion page for that unique ID. Prefer `/Users/garam/.codex/skills/start-task/scripts/notion_task.py` because it handles query, token loading, terminal-status guard, and sanitized JSON output.
3. Start the task by setting `상태` to `진행 중` unless it is already terminal.
4. Read enough page blocks and properties to understand the work. Include `작업 이름`, `작업 ID`, `상태`, `우선순위`, `태그`, `담당자`, due dates, `요약`, `Description`, and meaningful body text in your working context.
5. Synchronize local task files in the main project root:
   - Search `tasks/backlog`, `tasks/in-progress`, and `tasks/review-ready` for the display ID, Notion page ID, or exact title.
   - If found under `tasks/backlog`, move it to `tasks/in-progress/`.
   - Update `Status` to `in-progress` and `Updated` to today's date while preserving user-authored content.
   - If not found, create `tasks/in-progress/<type>-tsk-<number>-<short-slug>.md` with Notion URL, page ID, status, priority, tags, assignee, due dates, summary, description, checklist, and notes.
6. Read `README.md` first for project navigation, then apply relevant `AGENTS.md` and `.claude/rules/` rules.
7. Identify the Git repo that will receive implementation changes, usually one of `repos/gygo-svc3d-front-uamms`, `repos/gygo-svc3d-back-uamms`, or another repo named by the Notion body. If multiple repos require changes and the PR strategy is unclear, ask the user before creating worktrees.
8. Inspect the target repo before creating the worktree:
   - Run `git status --short --branch` in the canonical target repo and note any existing user work.
   - Run `git worktree list --porcelain` in the canonical target repo and check whether the intended branch or worktree path already exists.
   - Do not require the canonical repo working tree to be clean merely to create a worktree, but do not edit files there after the worktree exists.
9. Prepare the worktree before code edits:
   - Derive the branch name as `feature/<TASK-ID>/<short-slug>`, such as `feature/TSK-3478/map-location-persistence`.
   - Derive the worktree path as `.worktrees/<repo-name>/<TASK-ID>-<short-slug>` under the main project root unless a more specific project convention is visible.
   - Create the branch from local `develop` without switching the canonical repo when possible: `git -C <target-repo> worktree add -b <branch> <worktree-path> develop`.
   - If the branch already exists and is not checked out elsewhere, attach it with `git -C <target-repo> worktree add <worktree-path> <branch>`.
   - If the branch is already checked out in a suitable worktree for the same task, continue in that worktree after confirming it is based on the intended repo.
   - If the worktree path exists but is not the intended repo and branch, stop and ask how to proceed.
   - If local `develop` is missing, stale, diverged, or branch creation needs network state blocked by sandboxing, request escalation for the relevant `git fetch`, `git pull`, or `git worktree` command.
10. After creating or selecting the worktree, run `git -C <worktree-path> status --short --branch` and perform all implementation code edits from that worktree.
11. Do not stash, reset, rebase, delete branches, remove worktrees, or overwrite user work without explicit approval.
12. Do not create or update `logs/YYYY-MM-DD.md`; keep progress in the local task file.
13. Implement the task end to end if the Notion content gives enough detail. Ask a concise clarification only when the task cannot be safely started.

## Script Usage

Run this from the main project root:

```bash
python3 /Users/garam/.codex/skills/start-task/scripts/notion_task.py TSK-3477 --start --config .codex/config.toml
```

If sandboxed network access blocks the script, request escalation for that command. The script reads `NOTION_TOKEN` from `.codex/config.toml` or the environment and never prints it.

The output is JSON. If `updated_status` is `false` because the task is terminal, do not override Notion status unless the user explicitly asks.

## Repository Rules

If backend controllers are changed, update `docs/develop/API-guide/` in the same turn. If an irreversible architecture, data model, infrastructure, library, auth, or policy decision is made, add an ADR under `docs/decisions/`.
