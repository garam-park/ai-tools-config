---
name: lc-start-task
description: Start a local planning task (T0xx), move it to doing, prepare a feature branch, and implement it in the target repository. Use when the user invokes `$lc-start-task`, asks to start or implement a planning task such as `T053`, or asks to begin the task in a separate git worktree.
---

# Start Task (Local Lifecycle)

Start a task from the project's local `planning/` documents, prepare a safe implementation branch that follows the repository's own conventions, and proceed only when the task is actionable. Use the standard branch workflow unless the user explicitly requests a worktree.

## Task source

- Entry order: `docs/.agents/planning-guide.md` when present, then `planning/milestones/index.md`, then `planning/tasks/index.md`.
- Task IDs are `T001` style; milestone IDs are `M001` style; candidate milestone IDs are `MC001` style.
- Status values: `todo`, `doing`, `done`, `blocked`. Status lives in each document's YAML frontmatter block and is mirrored in the `index.md` boards; when this skill changes a status it updates both places.
- In-progress status: `doing`. Terminal statuses: `done`, and archived documents under `planning/archive/`.

## Resolve the project root and task

1. Use the project path the user provided. If none is provided, walk up from the current directory to the first directory containing both an agent guide (`AGENTS.md` or equivalent) and `planning/`. If the planning entry points are missing, stop and say the project does not follow the local planning convention.
2. Parse the task ID. Accept `T053`, `t053`, or `53` and normalize it to `T053`.
3. Read the task document's frontmatter and body, the owning milestone document, and the two index boards.
4. If no document is found, multiple documents match, or the task does not identify the intended implementation repository, stop and ask one concise question.

## Start conditions

Start only when all of the following hold; otherwise stop and explain which condition failed:

- The task `status` is `todo` (not `doing`, `done`, `blocked`, or archived).
- The owning milestone exists and is not `done`/archived. If there is no active milestone, tell the user to register one in `planning/milestones/index.md` or promote a candidate first; never start work against a `MC*` candidate.
- Every `depends_on` task is `done` (or archived with `done` status).

Explicit invocation of this skill authorizes the `todo → doing` transition and the matching index row update, but no other planning metadata change.

## Understand the workspace

1. Read the repository README and agent guide when present.
2. Discover and follow repository guidance, including convention documents for branching, commits, pull requests, coding, and testing. Do not impose conventions from another workspace.
3. If multiple repositories require separate branches and the split is unclear, ask before branching.

## Choose the implementation mode

- Use **standard mode** by default.
- Use **worktree mode** only when the user explicitly asks for a worktree, isolated checkout, or equivalent.
- Keep planning retrieval, task understanding, and safety checks identical in both modes.

## Standard mode

1. Inspect `git status --short --branch` in the target repository.
2. Derive the branch name from the repository's own branch convention (for example `feat/<kebab-slug>` from the task title). Read the repository's branch convention document when present instead of assuming a format.
3. Start from the base branch the repository's convention names (often `develop`). If already on a suitable branch for the same task, verify its base and continue.
4. Stop before changing branches when the repository has unrelated staged or unstaged changes, a conflicting branch exists, HEAD is detached, or the intended base is missing or diverged.
5. Do not stash, reset, rebase, delete branches, or overwrite user work without explicit approval.

## Worktree mode

1. Treat the current workspace repository as the control checkout; do not hardcode a machine-specific project root.
2. Inspect `git status --short --branch` and `git worktree list --porcelain` in the target repository.
3. Derive the same feature branch as standard mode. Prefer the workspace's existing worktree convention; otherwise use `.worktrees/<repo-name>/<task-id>-<short-slug>` under the workspace root.
4. Create the branch and worktree from the intended base without switching the control checkout when possible:

   ```bash
   git -C <target-repo> worktree add -b <branch> <worktree-path> <base>
   ```

5. If the branch already exists and is not checked out elsewhere, attach it without `-b`. If it is already checked out in a suitable worktree, continue there after verification.
6. Stop if the path belongs to a different repository or branch, or if the base branch is missing or appears stale. Never remove a worktree or branch without explicit approval.
7. Perform implementation edits only inside the selected worktree.

## Implement

1. Confirm the branch or worktree status before editing.
2. Implement the task end to end when requirements are actionable.
3. Validate changes in proportion to their risk and follow the repository's own verification commands when its agent guide defines them.
4. Ask a concise clarification only when implementation cannot proceed safely.

## Guardrails

- Do not start tasks whose milestone is `done`/archived, whose dependencies are incomplete, or that belong to a `MC*` candidate.
- Do not mark a task `done`; completion and index finalization belong to the merge decision and `lc-sync-milestone`.
- Do not stash, reset, rebase, delete branches, force-push, or overwrite user work without explicit approval.
- Do not touch planning files other than the started task's `status` and its index row.
