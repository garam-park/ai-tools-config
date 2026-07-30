---
name: ntn-review-pr
description: Drive an existing Notion task pull request through review, CI diagnosis, follow-up fixes, verification, and merge-readiness reporting. Use when the user invokes `$ntn-review-pr` or `/ntn-review-pr`, provides an existing task PR, asks to address review comments or failing checks, requests focused or multi-perspective review, or wants the PR prepared for merge. Do not use to open the initial PR; use ntn-create-pr when no PR exists.
---

# Review PR

Handle an existing task PR from review through verified follow-up. Finish without merging unless the user explicitly asks to merge.

## Notion CLI usage

Assume `ntn` is installed, authenticated, and able to access the intended Notion workspace. Do not run standalone setup checks such as `command -v ntn`, `ntn --version`, or `ntn doctor` before useful work solely to verify the environment.

When task metadata is needed, run the specific `ntn` command for that work first. If that command fails because `ntn` is missing, not authenticated, outdated, or unable to access the workspace, explain the exact current failure and guide setup in detail:

- Install: run `curl -fsSL https://ntn.dev | bash`, or `npm install --global ntn` when Node.js 22+ and npm 10+ are available.
- Authenticate: run `ntn login` and choose the Notion workspace that contains the task database.
- Verify: run `ntn doctor`, then retry the exact `ntn` command that failed.
- Access issues: confirm the signed-in Notion user can open the database or page in Notion, and confirm `.env.tsk` points to the intended database and data source.

When the current tool can install CLI dependencies only with user approval, request approval after a real `ntn` command has failed for a setup reason. Only fall back to another currently available Notion integration or explicit Notion page content after the failed `ntn` command is understood. If no Notion access path is available, tell the user first. Continue only when the PR, branch, commits, and diff are already sufficient for the requested review work; do not use local repository context as a substitute task source.

## Resolve the PR

1. Accept a task ID, PR URL, PR number, branch name, or current branch. Normalize numeric task IDs to `TSK-<number>`.
2. Read the repository README and inspect local branch state before querying external systems.
3. Prefer an available GitHub integration for PR metadata, comments, reviews, and checks. Use the non-interactive `gh` CLI when equivalent integration coverage is unavailable.
4. When task metadata is needed, use `ntn datasources query <data-source-id>` and `ntn pages get <page-id>` first. If the required `ntn` command fails for a setup or access reason, look for another currently available Notion integration or the user's provided Notion page content only after explaining the failure.
5. If no Notion access path is available, report that task metadata could not be retrieved and continue only when the PR, branch, commits, and diff are already sufficient for the requested review work; do not treat local files, branch context, PR metadata, or repository files as a substitute task source.
6. Confirm that the PR, branch, repository, and task refer to the same work. If no PR exists, stop and direct the user to `ntn-create-pr` unless they explicitly requested an end-to-end flow.

## GitHub CLI usage

Assume `gh` is installed, authenticated, and connected to the target repository. Do not run standalone setup checks such as `command -v gh`, `gh auth status`, or `gh repo view` before useful work solely to verify the environment.

Use `gh` directly for PR lookup, diffs, checks, comments, and metadata unless a richer GitHub integration is already available. If the required `gh` command fails because `gh` is missing, not authenticated, or cannot resolve the repository, explain the exact current failure and guide the user through setup in detail:

- Install: `brew install gh` on macOS, or choose the official GitHub CLI package for the OS.
- Authenticate: run `gh auth login`, select `GitHub.com`, choose HTTPS or SSH to match the repository, authenticate in the browser or with the shown device code, and grant repo access when prompted.
- Verify: run `gh auth status` and `gh repo view` in the target repository.
- Repository issues: if `gh repo view` fails, inspect `git remote -v`, explain the expected `OWNER/REPO`, and guide the user to set or fix `origin` before continuing.

Only fall back to another GitHub integration or user-provided PR URL after the failed `gh` command is understood. If no path can inspect the PR, stop with the setup steps still needed rather than guessing.

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
