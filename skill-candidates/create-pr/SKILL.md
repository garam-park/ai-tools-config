---
name: create-pr
description: Create or update an Innopam task pull request from a local task branch. Use when the user invokes `$create-pr TSK-3478`, asks to open a PR for a task, prepare a task branch for review, push implementation commits, write the PR body, or define merge approval criteria with an independent subagent before review. Do not use for already-open PR review comments, failing CI, or follow-up fixes; use `handle-pr` for those.
---

# Create PR

## Overview

Prepare a task branch and create or update its pull request. Stop at the point where the PR is open, merge criteria have been independently drafted by a subagent and documented, and the user has the PR URL.

## Workflow

1. Parse the first non-empty argument as the task ID. Accept `TSK-3477`, `tsk-3477`, or `3477`; normalize to display ID `TSK-3477` and unique ID number `3477`.
2. Resolve task context:
   - Read `README.md` first for project navigation.
   - Do not inspect, update, move, or create files under repository-level `tasks/` folders as part of this workflow.
   - Use the current repo, recent commits, branch name, Notion/task summary, PR metadata, and user-provided context to identify the implementation repo and expected change scope.
3. Validate branch state in the implementation repo:
   - Inspect `git status --short --branch`, `git log --oneline -5`, and the diff against `develop`.
   - Expect a task branch such as `feature/<TASK-ID>/<short-slug>` with relevant commits and no unrelated uncommitted changes.
   - If currently on `develop`, create the task branch from `develop` only when the implementation has not already been done elsewhere.
   - If the branch is tangled, stop and ask how to proceed. Tangled states include detached HEAD, unrelated branch, conflicting task branch, diverged base, uncommitted changes you did not make, multiple candidate repos, or unclear PR target.
   - Do not stash, reset, rebase, delete branches, or overwrite user work without explicit approval.
4. Verify and commit before PR:
   - If relevant implementation changes are uncommitted, run focused build/tests first when feasible, then commit with a task-scoped message.
   - Leave unrelated user changes untouched.
   - Push the branch to `origin`.
5. Create or reuse the PR:
   - Prefer `gh pr view` to detect an existing PR for the current branch.
   - If no PR exists, run `gh pr create --base develop --head <branch>`.
   - Include task ID, summary, changed behavior, verification, and residual risk in the PR body.
   - If a PR already exists, update missing body details only when it is clearly the same task PR, then stop and tell the user to use `handle-pr` for review or CI follow-up.
6. Have an independent subagent define merge approval criteria, then post them as a PR comment before review:
   - Spawn a fresh subagent dedicated only to merge criteria drafting after the PR exists and the task branch diff is available.
   - Give the subagent raw artifacts, not the main session's conclusions. Good inputs include the Notion/task summary, PR URL, branch name, `gh pr diff` or `git diff develop...HEAD`, verification commands/results, and changed documentation paths.
   - Ask the subagent for concrete, task-specific merge criteria and any missing verification or documentation requirements. Do not ask it to edit files.
   - Ensure criteria usually cover user-visible behavior required by the task, important fallback/error cases, no regression to adjacent workflows, required build/test commands, and documentation/API guide updates when backend controllers change.
   - Review the subagent output only for factual support against the raw artifacts. Remove unsupported criteria, but do not replace the independent draft with main-session assumptions.
   - If subagents are unavailable or stall, do not silently post self-authored criteria. Tell the user independent criteria drafting could not be completed and stop before claiming merge criteria are documented.
7. Finish without merging:
   - Do not run the multi-agent PR review here unless the user explicitly asks for an end-to-end create-and-review flow.
   - Do not merge the PR.
   - Final response should include the PR URL, branch, commits pushed, merge criteria status, verification, and the next recommended command, usually `$handle-pr <TASK-ID>`.

## Command Notes

- Prefer non-interactive Git and GitHub CLI commands.
- Use `gh pr diff`, `gh pr view`, `gh pr create`, `gh pr edit`, and `gh pr comment` for PR operations.
- If backend controllers are changed, update `docs/develop/API-guide/` in the same PR. If an irreversible architecture, data model, infrastructure, library, auth, or policy decision is made, add an ADR under `docs/decisions/`.
