---
name: lc-review-pr
description: Drive an existing pull request for a local planning task (T0xx) through review, CI diagnosis, follow-up fixes, verification, and merge-readiness reporting. Use when the user invokes `$lc-review-pr` or `/lc-review-pr`, provides an existing task PR, asks to address review comments or failing checks, requests focused or multi-perspective review, or wants the PR prepared for merge. Do not use to open the initial PR; use lc-create-pr when no PR exists.
---

# Review PR (Local Lifecycle)

Handle an existing task PR from review through verified follow-up. Finish without merging unless the user explicitly asks to merge. Task context comes from the project's `planning/` documents; no external tracker is involved.

## Resolve the PR

1. Accept a task ID, PR URL, PR number, branch name, or the current branch. Normalize numeric task IDs to `T<digits>`.
2. Read the repository README and agent guide, then inspect the local branch state.
3. Prefer an available GitHub integration for PR metadata, comments, reviews, and checks. Use the non-interactive `gh` CLI when equivalent integration coverage is unavailable.
4. When task context is needed, read the task document, the owning milestone document, and the index boards under `planning/`. If the planning entry points are missing, continue only when the PR, branch, commits, and diff are already sufficient for the requested review work; do not invent task context.
5. Confirm that the PR, branch, repository, and task refer to the same work. If no PR exists, stop and direct the user to `lc-create-pr` unless they explicitly requested an end-to-end flow.

## GitHub CLI usage

Assume `gh` is installed, authenticated, and connected to the target repository. Do not run standalone setup checks such as `command -v gh`, `gh auth status`, or `gh repo view` before useful work solely to verify the environment.

Use `gh` directly for PR lookup, diffs, checks, comments, and metadata unless a richer GitHub integration is already available. If the required `gh` command fails because `gh` is missing, not authenticated, or cannot resolve the repository, explain the exact current failure and guide the user through setup in detail:

- Install: `brew install gh` on macOS, or choose the official GitHub CLI package for the OS.
- Authenticate: run `gh auth login`, select the matching GitHub host, choose HTTPS or SSH to match the repository, and grant repo access when prompted.
- Verify: run `gh auth status` and `gh repo view` in the target repository.
- Repository issues: if `gh repo view` fails, inspect `git remote -v`, explain the expected `OWNER/REPO`, and guide the user to set or fix `origin` before continuing.

Only fall back to another GitHub integration or a user-provided PR URL after the failed `gh` command is understood. If no path can inspect the PR, stop with the setup steps still needed rather than guessing.

## Establish the review target

1. Inspect the PR diff, review threads, comments, required checks, recent commits, and the local working tree.
2. Find the documented merge criteria. If none exist, draft concrete criteria from the task documents and diff before judging readiness.
3. Keep unrelated local changes untouched.
4. Prioritize concrete external signals such as unresolved comments and failing checks before running a broad review.

## Review and diagnose

Choose only the work the PR currently needs:

- For review feedback, inspect unresolved threads and map each actionable comment to the affected code.
- For CI failures, inspect failed checks and logs, reproduce the failure locally when practical, and distinguish new failures from unrelated existing warnings.
- For merge readiness, compare the implementation and verification against every merge criterion.
- For a requested broad review, inspect behavior, regression risk, error handling, tests, and required documentation.

Use a focused review-comment or CI capability when the current tool provides one. When independent workers or subagents are available and the user requested multi-perspective review, assign bounded read-only review scopes and require findings with severity and file/line evidence. When they are unavailable, continue with a focused main-session review and state the limitation.

## Implement required fixes

1. Address blocking findings, actionable unresolved comments, and failing required checks first.
2. Keep changes within the PR scope and merge criteria.
3. Do not let workers edit files unless they own a clearly disjoint implementation task.
4. Do not stash, reset, rebase, delete branches, force-push, or overwrite user work without explicit approval.

## Verify and publish follow-up

1. Run the repository's relevant build, test, and lint checks after fixes.
2. Commit only relevant changes, following the repository's commit message convention; do not add AI attribution trailers unless the user explicitly asks. Push the PR branch.
3. Re-run review only when behavior changed materially or a reviewer requested re-checking.
4. Reply to or resolve review threads only after the verified fix is present.
5. Post a concise PR update covering criteria, findings, fixes, exact verification commands, and residual risk.

## Finish

Do not merge unless the user explicitly asks. Do not mark the planning task `done` here; the merge decision and planning finalization belong to the user and `lc-sync-milestone`. Report:

- PR URL and base/head branches
- follow-up commits pushed
- review and required-check status
- verification performed
- unresolved findings and residual risk
- whether the PR is ready for the user's merge decision
