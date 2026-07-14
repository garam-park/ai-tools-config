---
name: handle-pr
description: Handle an existing Innopam task pull request after it has been opened. Use when the user invokes `$handle-pr TSK-3478`, asks to review a PR, run multi-agent PR review, address GitHub review comments, fix failing PR checks, push follow-up commits, update PR comments, decide whether approval criteria are met, or prepare the user to merge. Do not use to create the initial PR; use `create-pr` for unopened task branches.
---

# Handle PR

## Overview

Drive an already-open task PR from review through fix verification. Use this for review comments, CI failures, approval criteria checks, and final merge-readiness reporting.

## Workflow

1. Resolve the target PR:
   - Accept a task ID, PR URL, PR number, or current branch.
   - Normalize task IDs such as `TSK-3477`, `tsk-3477`, or `3477` when provided.
   - Read `README.md` first for project navigation when starting from a task ID.
   - Do not inspect, update, move, or create files under repository-level `tasks/` folders as part of this workflow.
   - Use `gh pr view`, PR metadata, branch name, recent commits, Notion/task summary, and user-provided context to confirm the PR matches the task.
   - If no PR exists, stop and tell the user to run `create-pr` first unless they explicitly asked for an end-to-end create-and-handle workflow.
2. Establish the review target:
   - Inspect `git status --short --branch`, `gh pr view`, `gh pr diff`, and the latest PR comments/checks.
   - Identify merge approval criteria from the PR body/comments. If none exist, draft concrete criteria and post them before judging readiness.
   - Keep unrelated local changes untouched.
3. Run or inspect review:
   - If the user asked for multi-agent review or merge readiness, spawn two or more focused review agents when available.
   - Give each agent a bounded scope and ask for findings first, with severity and file/line references.
   - Good scopes include lifecycle/behavior correctness, storage/error handling, test coverage, backend/API documentation, or UI regression risk.
   - If the task is specifically about GitHub review comments or CI failures, first inspect those concrete signals and avoid unnecessary broad review.
   - If an agent stalls, close it, mention the limitation, and proceed with completed reviews plus local judgment.
4. Implement required fixes:
   - Address blocking/high findings, unresolved review comments, and failing required checks first.
   - Keep edits tightly scoped to the PR and approval criteria.
   - Do not ask agents to edit files unless assigning a clearly disjoint implementation subtask.
   - Do not stash, reset, rebase, delete branches, or overwrite user work without explicit approval.
5. Verify and push:
   - Run focused tests/builds after fixes.
   - Commit follow-up changes with a task-scoped message.
   - Push the branch to `origin`.
   - Repeat review only when the fix materially changes behavior or when a reviewer asked for re-check.
6. Comment on the PR:
   - Post a concise PR comment summarizing approval criteria, review findings, fixes, verification commands, and residual risk.
   - Include exact commands run, such as `npm run build`, and note warnings if they are existing/non-blocking.
   - Resolve or reply to review threads only when the fix is actually present and verified.
7. Finish without merging unless explicitly requested:
   - Do not merge the PR unless the user explicitly asks.
   - Final response should include the PR URL, branch, commits pushed, review status, verification, residual risk, and a direct merge request to the user when ready.

## Command Notes

- Prefer non-interactive Git and GitHub CLI commands.
- Use `gh pr view`, `gh pr diff`, `gh pr checks`, `gh pr comment`, and `gh pr review` for PR operations.
- Use GitHub app tools when available for repository, PR, issue, and review metadata. Use `gh` when thread-level review state, Actions logs, or connector coverage requires it.
- If backend controllers are changed, ensure `docs/develop/API-guide/` is updated in the same PR. If an irreversible architecture, data model, infrastructure, library, auth, or policy decision is made, ensure an ADR exists under `docs/decisions/`.
