---
name: inp-start-task
description: Start an Innopam Notion work item by TSK ID, move it to in progress, prepare a feature branch, and implement it in the target repository. Use when the user invokes `$inp-start-task`, asks to start or implement an Innopam task such as `TSK-3477`, or asks to begin the task in a separate git worktree.
---

# Start Task

Start a task from the Innopam `솔루션 개발팀 작업` database, prepare a safe implementation branch, and proceed when the task is actionable. Use the standard branch workflow unless the user explicitly requests a worktree.

## Task source

- Database: `솔루션 개발팀 작업`
- Database ID: `71842431-f19c-4f43-9df7-461805cf3895`
- Data source ID, when required by the active Notion integration: `42e60fb3-5260-429b-8af4-ed28535f295b`
- Task ID property: `작업 ID` (`unique_id`, prefix `TSK`)
- Status property: `상태`
- In-progress status: `진행 중`
- Terminal statuses: `완료`, `PR완료(DEV)`, `보관됨`

## Fetch and start the task

1. Parse the task ID. Accept `TSK-3477`, `tsk-3477`, or `3477` and normalize it to `TSK-3477`.
2. Fetch exactly one matching Notion page with the Notion integration available in the current tool. If no integration is available, run the bundled `scripts/notion_task.py` from this skill directory; never assume a Codex-, Claude-, Copilot-, or OpenCode-specific install path.
3. Set `상태` to `진행 중` unless the current status is terminal. Explicit invocation of this skill authorizes this status transition, but not changes to other Notion fields.
4. Read the task properties and meaningful body blocks. Include the title, task ID, status, priority, tags, assignees, due dates, summary, description, and acceptance criteria in the working context.
5. If no page is found, multiple pages match, or the task does not identify the intended implementation repository, stop and ask one concise question.

## Understand the workspace

1. Read the workspace and target repository `README.md` files when present.
2. Discover and follow repository guidance supported by the current agent, including applicable `AGENTS.md` files and visible tool-specific rules.
3. Identify the repository or repositories affected by the task. If multiple repositories require separate branches or pull requests and the split is unclear, ask before branching.
4. Use project-specific task cards, API documentation, ADRs, or checklists only when the repository's own guidance requires them. Do not impose conventions from another workspace.

## Choose the implementation mode

- Use **standard mode** by default.
- Use **worktree mode** only when the user explicitly asks for a worktree, `work.tree`, isolated checkout, or equivalent.
- Keep Notion retrieval, task understanding, and safety checks identical in both modes.

## Standard mode

1. Inspect `git status --short --branch` in the target repository.
2. Derive a branch name such as `feature/TSK-3477/<short-slug>` from the task title.
3. Start from local `develop` unless repository guidance specifies another base branch. If already on a suitable branch for the same task, verify its base and continue.
4. Stop before changing branches when the repository has unrelated staged or unstaged changes, a conflicting branch exists, HEAD is detached, or the intended base is missing or diverged.
5. Do not stash, reset, rebase, delete branches, or overwrite user work without explicit approval.

## Worktree mode

1. Treat the current workspace repository as the control checkout; do not hardcode a machine-specific project root.
2. Inspect `git status --short --branch` and `git worktree list --porcelain` in the target repository.
3. Derive the same feature branch as standard mode. Prefer the workspace's existing worktree convention; otherwise use `.worktrees/<repo-name>/<TASK-ID>-<short-slug>` under the workspace root.
4. Create the branch and worktree from the intended base without switching the control checkout when possible:

   ```bash
   git -C <target-repo> worktree add -b <branch> <worktree-path> develop
   ```

5. If the branch already exists and is not checked out elsewhere, attach it without `-b`. If it is already checked out in a suitable worktree, continue there after verification.
6. Stop if the path belongs to a different repository or branch, or if the base branch is missing or appears stale. Never remove a worktree or branch without explicit approval.
7. Perform implementation edits only inside the selected worktree.
8. If the workspace already maintains task files under `tasks/backlog`, `tasks/in-progress`, or `tasks/review-ready`, move or create the matching card under `tasks/in-progress` while preserving user-authored content. Do not create a new task-card system.

## Implement

1. Confirm the branch or worktree status before editing.
2. Implement the task end to end when requirements are actionable.
3. Validate changes in proportion to their risk and follow repository-specific test instructions.
4. Ask a concise clarification only when implementation cannot proceed safely.

## Bundled script

Resolve `SKILL_DIR` as the directory containing this `SKILL.md`, then run:

```bash
python3 "$SKILL_DIR/scripts/notion_task.py" TSK-3477 --start
```

The script reads `NOTION_TOKEN` from the environment. An explicit `--config <path>` may be used for an existing local config file; do not search unrelated tool configuration directories. The script emits sanitized JSON and never prints the token.

If network access is restricted, request the permission required for this exact command. If `updated_status` is false because the task is terminal, do not override the status unless the user explicitly asks.
