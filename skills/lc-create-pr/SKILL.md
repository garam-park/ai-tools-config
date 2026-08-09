---
name: lc-create-pr
description: Prepare and open a pull request for a local planning task (T0xx) from its task branch. Use when the user invokes `$lc-create-pr` or `/lc-create-pr`, or asks to validate a planning task branch, push its commits, open or update its initial PR, write the PR body, or document merge criteria. Stop after the PR is ready for review. Do not use for review comments, failing checks, or follow-up fixes on an already-open PR; use lc-review-pr for those.
---

# Create PR (Local Lifecycle)

Prepare a local planning task branch for review and open or reuse its pull request. Finish without merging. Task context comes from the project's `planning/` documents; no external tracker is involved.

## Resolve the task and repository

1. Accept a task ID, branch name, or the current branch as input. Normalize numeric task IDs to `T<digits>`.
2. Read the repository README and agent guide, then inspect the current branch and recent commits.
3. When task context is needed, read the task document, the owning milestone document, and the index boards under `planning/`. If the planning entry points are missing, continue only when the local branch, commits, and diff are already sufficient to prepare the PR; do not invent task context.
4. Confirm the implementation repository, expected base branch, and change scope. Determine the base branch from the repository's own branch convention document rather than assuming one.

## GitHub CLI usage

Assume `gh` is installed, authenticated, and connected to the target repository. Do not run standalone setup checks such as `command -v gh`, `gh auth status`, or `gh repo view` before useful work solely to verify the environment.

Use `gh` directly for PR lookup, creation, checks, comments, and metadata unless a richer GitHub integration is already available. If the required `gh` command fails because `gh` is missing, not authenticated, or cannot resolve the repository, explain the exact current failure and guide the user through setup in detail:

- Install: `brew install gh` on macOS, or choose the official GitHub CLI package for the OS.
- Authenticate: run `gh auth login`, select the matching GitHub host, choose HTTPS or SSH to match the repository, and grant repo access when prompted.
- Verify: run `gh auth status` and `gh repo view` in the target repository.
- Repository issues: if `gh repo view` fails, inspect `git remote -v`, explain the expected `OWNER/REPO`, and guide the user to set or fix `origin` before continuing.

Only fall back to another GitHub integration or a user-provided PR URL after the failed `gh` command is understood. If no path can create or inspect the PR, stop with the setup steps still needed rather than guessing.

## Validate the branch

1. Inspect branch status, recent commits, and the diff against the expected base.
2. Require a task-scoped branch with relevant changes and no unrelated user work. The repository's PR convention may require separating mechanical changes from judgment changes; follow it.
3. If implementation changes are uncommitted, run focused verification before committing them. Use the repository's own verification commands when its agent guide defines them.
4. Stop and ask for direction when the repository, base branch, task, or PR target is ambiguous or the branch is detached, diverged, or mixed with unrelated changes.

Do not stash, reset, rebase, delete branches, or overwrite user work without explicit approval.

## Verify, commit, and push

1. Run the repository's relevant build, test, and lint commands before committing.
2. Commit only task-related changes. Follow the repository's commit message convention (for example Conventional Commits with the language and ending style its convention document prescribes); do not add AI attribution trailers unless the user explicitly asks.
3. Push the task branch to its configured remote.
4. Record the exact verification commands and results for the PR body.

## Open or reuse the PR

1. Prefer an available GitHub integration for PR metadata and creation. Use the non-interactive `gh` CLI when no equivalent integration is available.
2. Detect an existing PR for the branch before creating one.
3. Create a PR against the confirmed base when none exists. Give it a title that follows the repository's PR convention, and include the task ID, behavior change, verification, documentation impact, and residual risk in the body.
4. If the same task PR already exists, update missing initial details only when clearly safe, then stop and direct follow-up work to `lc-review-pr`.

## Document merge criteria

1. Draft concrete criteria from the task context, branch diff, verification results, and changed documentation.
2. When the current tool supports independent workers or subagents, ask one fresh read-only worker to draft the criteria from raw artifacts without editing files.
3. When independent workers are unavailable, draft the criteria in the main session and state that they were not independently produced. Do not block PR creation solely because a subagent feature is unavailable.
4. Post or add the criteria to the PR only after checking that each item is supported by the artifacts.

Cover required behavior, important failure cases, adjacent regression risk, required verification, and documentation updates.

## Finish

Do not merge the PR. Report:

- PR URL and base/head branches
- commits pushed
- verification performed
- merge-criteria status and whether it was independently drafted
- residual risk
- the next action, normally `lc-review-pr` for this task
