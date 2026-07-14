---
name: pr-review
description: Compatibility router for the old Innopam PR workflow. Use only when the user explicitly invokes `$pr-review TSK-3478` or asks for the legacy combined PR review flow. Prefer `create-pr` when opening a new PR, and prefer `handle-pr` when a PR already exists, review feedback exists, CI is failing, or follow-up fixes are needed.
---

# PR Review

## Overview

Route legacy `$pr-review` requests to the narrower PR skills. Keep this skill thin so PR creation and PR handling stay separate.

## Routing

1. Parse the first non-empty argument as the task ID when present. Accept `TSK-3477`, `tsk-3477`, or `3477`; normalize to display ID `TSK-3477` and unique ID number `3477`.
2. Resolve enough context to know whether a PR already exists:
   - Read `README.md` first for project navigation when in an implementation workspace.
   - Search local task files and inspect the current branch.
   - Use `gh pr view` for the current branch or task branch when available.
3. If no PR exists, follow the `create-pr` workflow:
   - Validate the task branch.
   - Run focused verification.
   - Commit and push relevant changes.
   - Create the PR and post merge approval criteria.
   - Stop after reporting the PR URL unless the user explicitly requested review handling too.
4. If a PR exists, follow the `handle-pr` workflow:
   - Inspect PR diff, comments, checks, and approval criteria.
   - Run focused or multi-agent review when requested.
   - Implement required fixes.
   - Verify, commit, push, and comment on the PR.
5. If the user explicitly asks for the old end-to-end behavior, run `create-pr` first when needed, then continue with `handle-pr`.

## Guardrails

- Do not merge the PR unless the user explicitly asks.
- Do not stash, reset, rebase, delete branches, or overwrite user work without explicit approval.
- If the branch, task, repository, or PR target is ambiguous, stop and ask how to proceed.
