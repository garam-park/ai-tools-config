---
name: ntn-start-task
description: Start a Notion TSK task, move it to in progress, prepare a feature branch, and implement it in the target repository. Use when the user invokes `$ntn-start-task`, asks to start or implement a TSK task such as `TSK-3477`, or asks to begin the task in a separate git worktree.
---

# Start Task

Start a task from the configured Notion task data source, prepare a safe implementation branch, and proceed when the task is actionable. Use the standard branch workflow unless the user explicitly requests a worktree.

## Task source

- Config file: project-root `.env.tsk`
- Required keys: `NOTION_DATABASE_ID`, `NOTION_DATA_SOURCE_ID`
- No built-in database defaults are allowed. If either key is missing, ask the user for a Notion database or task link that the active Notion integration can inspect, then use that link to determine and persist the missing values in `.env.tsk`.
- Task ID property: prefer `작업 ID` (`unique_id`, prefix `TSK`) when present; otherwise identify the matching ID/title property from the database schema and ask if ambiguous.
- Status property: prefer `상태` when present.
- In-progress status: `진행 중`
- Terminal statuses: `완료`, `PR완료(DEV)`, `보관됨`

## Notion CLI usage

Assume `ntn` is installed, authenticated, and able to access the intended Notion workspace. Do not run standalone setup checks such as `command -v ntn`, `ntn --version`, or `ntn doctor` before useful work solely to verify the environment.

When a Notion task read or status update is needed, run the specific `ntn` command for that work first. If that command fails because `ntn` is missing, not authenticated, outdated, or unable to access the workspace, explain the exact current failure and guide setup in detail:

- Install: run `curl -fsSL https://ntn.dev | bash`, or `npm install --global ntn` when Node.js 22+ and npm 10+ are available.
- Authenticate: run `ntn login` and choose the Notion workspace that contains the task database.
- Verify: run `ntn doctor`, then retry the exact `ntn` command that failed.
- Access issues: confirm the signed-in Notion user can open the database or page in Notion, and confirm `.env.tsk` points to the intended database and data source.

When the current tool can install CLI dependencies only with user approval, request approval after a real `ntn` command has failed for a setup reason. Only fall back to another currently available Notion integration or explicit Notion page content after the failed `ntn` command is understood. If no Notion access path is available, tell the user first. Include the exact missing setup and do not continue with local repository context as a substitute task source.

## Fetch and start the task

1. Parse the task ID. Accept `TSK-3477`, `tsk-3477`, or `3477` and normalize it to `TSK-3477`.
2. Read project-root `.env.tsk`. If `NOTION_DATABASE_ID` or `NOTION_DATA_SOURCE_ID` is missing, ask for a Notion database or task link, use `ntn datasources resolve <database-id>` or another available Notion access path to determine the missing IDs, and create or update `.env.tsk`. Do not use hardcoded fallback IDs.
3. Use `ntn datasources query <data-source-id>` to fetch exactly one matching Notion page from the configured data source, then `ntn pages get <page-id>` to read the page.
4. If the required `ntn` command fails for a setup or access reason, look for another currently available Notion integration or the user's provided Notion page content only after explaining the failure.
5. If no Notion access path is available, report that the Notion task could not be retrieved and provide the exact missing setup: `ntn` installation/login, `.env.tsk` keys, a usable Notion link, or Notion workspace access. Do not use local task files, branch context, PR metadata, or repository files as a substitute for the Notion task source.
6. Set `상태` to `진행 중` using `ntn pages update <page-id>` unless the current status is terminal. Explicit invocation of this skill authorizes this status transition, but not changes to other Notion fields.
7. Read the task properties and meaningful body blocks. Include the title, task ID, status, priority, tags, assignees, due dates, summary, description, and acceptance criteria in the working context.
8. If no page is found, multiple pages match, or the task does not identify the intended implementation repository, stop and ask one concise question.

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

## Implement

1. Confirm the branch or worktree status before editing.
2. Implement the task end to end when requirements are actionable.
3. Validate changes in proportion to their risk and follow repository-specific test instructions.
4. Ask a concise clarification only when implementation cannot proceed safely.

## Notion access failure

Do not use a bundled REST fallback script or the project-local `notion` MCP as the default path. If `ntn` and no other Notion integration can inspect the task or database link, stop with concrete setup guidance:

- how to install and authenticate `ntn`
- which `.env.tsk` keys are missing
- what Notion database or task link is needed
- which Notion workspace access needs to be granted
- whether the user can paste the task page content as a temporary read-only fallback

If the task is terminal, do not override the status unless the user explicitly asks.
