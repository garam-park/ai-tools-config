---
name: handle-pr
description: Drive an existing Innopam task pull request through review, CI diagnosis, follow-up fixes, verification, and merge-readiness reporting. Use when the user invokes handle-pr with `$handle-pr` or `/handle-pr`, provides an existing PR, asks to address review comments or failing checks, requests focused or multi-perspective review, or wants the PR prepared for merge. Do not use to open the initial PR; use create-pr when no PR exists.
---

# Handle PR

Handle an existing task PR from review through verified follow-up. Finish without merging unless the user explicitly asks to merge.

## Resolve the PR

1. Accept a task ID, PR URL, PR number, branch name, or current branch. Normalize numeric task IDs to `TSK-<number>`.
2. Read the repository README and inspect local branch state before querying external systems.
3. Prefer an available GitHub integration for PR metadata, comments, reviews, and checks. Use the non-interactive `gh` CLI when equivalent integration coverage is unavailable.
4. Confirm that the PR, branch, repository, and task refer to the same work. If no PR exists, stop and direct the user to `create-pr` unless they explicitly requested an end-to-end flow.

## Establish the review target

1. Inspect the PR diff, review threads, comments, required checks, recent commits, and local working tree.
2. Find the documented merge criteria. If none exist, draft concrete criteria from the task and diff before judging readiness.
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
4. Do not stash, reset, rebase, delete branches, or overwrite user work without explicit approval.

## Verify and publish follow-up

1. Run focused tests, builds, or lint checks after fixes.
2. Commit only relevant changes with a task-scoped message and push the PR branch.
3. Re-run review only when behavior changed materially or a reviewer requested re-checking.
4. Reply to or resolve review threads only after the verified fix is present.
5. Post a concise PR update covering criteria, findings, fixes, exact verification commands, and residual risk.

When backend controllers change, verify whether `docs/develop/API-guide/` needs an update. When the PR introduces an irreversible architecture, data, infrastructure, dependency, authentication, or policy decision, verify that an ADR exists.

## Finish

Do not merge unless the user explicitly asks. Report:

- PR URL and base/head branches
- follow-up commits pushed
- review and required-check status
- verification performed
- unresolved findings and residual risk
- whether the PR is ready for the user's merge decision
