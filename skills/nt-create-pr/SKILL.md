---
name: nt-create-pr
description: Prepare and open a Notion task pull request from a local task branch. Use when the user invokes `$nt-create-pr` or `/nt-create-pr`, or asks to validate a TSK task branch, push its commits, open or update its initial PR, write the PR body, or document merge criteria. Stop after the PR is ready for review. Do not use for review comments, failing checks, or follow-up fixes on an already-open PR; use nt-review-pr for those.
---

# Create PR

Prepare a Notion task branch for review and open or reuse its pull request. Finish without merging.

## Resolve the task and repository

1. Accept a task ID, branch name, or current branch as input. Normalize numeric task IDs to `TSK-<number>`.
2. Read the repository README and inspect the current branch and recent commits before using external systems.
3. When task metadata is needed, first check for the project-local `notion` MCP server. If it is unavailable, look for another currently available Notion integration or the user's provided Notion page content.
4. If no Notion access path is available, report that task metadata could not be retrieved and continue only when the local branch, commits, and diff are already sufficient to prepare the PR; do not treat local files, branch context, PR metadata, or repository files as a substitute task source.
5. Confirm the implementation repository, expected base branch, and change scope. Use `develop` only when repository conventions or existing task branches establish it as the base.

## GitHub preflight

Before PR metadata, push, or PR creation work, verify that `gh` can be used from the target repository:

```bash
command -v gh
gh auth status
git remote -v
gh repo view
```

If `gh` works, use it for PR lookup, creation, checks, comments, and metadata unless a richer GitHub integration is already available. If `gh` is missing or not authenticated, explain the exact current failure and guide the user through setup in detail:

- Install: `brew install gh` on macOS, or choose the official GitHub CLI package for the OS.
- Authenticate: run `gh auth login`, select `GitHub.com`, choose HTTPS or SSH to match the repository, authenticate in the browser or with the shown device code, and grant repo access when prompted.
- Verify: run `gh auth status` and `gh repo view` in the target repository.
- Repository issues: if `gh repo view` fails, inspect `git remote -v`, explain the expected `OWNER/REPO`, and guide the user to set or fix `origin` before continuing.

Only fall back to another GitHub integration or user-provided PR URL after this preflight is understood. If no path can create or inspect the PR, stop with the setup steps still needed rather than guessing.

## Validate the branch

1. Inspect branch status, recent commits, and the diff against the expected base.
2. Require a task-scoped branch with relevant changes and no unrelated user work.
3. If implementation changes are uncommitted, run focused verification before committing them.
4. Stop and ask for direction when the repository, base branch, task, or PR target is ambiguous or the branch is detached, diverged, or mixed with unrelated changes.

Do not stash, reset, rebase, delete branches, or overwrite user work without explicit approval.

## Verify, commit, and push

1. Run the smallest relevant build, test, or lint commands supported by the repository.
2. Commit only task-related changes with a task-scoped message when a commit is still needed.
3. Push the task branch to its configured remote.
4. Record the exact verification commands and results for the PR body.

## Open or reuse the PR

1. Prefer an available GitHub integration for PR metadata and creation. Use the non-interactive `gh` CLI when no equivalent integration is available.
2. Detect an existing PR for the branch before creating one.
3. Create a PR against the confirmed base when none exists. Include the task ID, behavior change, verification, documentation, and residual risk.
4. If the same task PR already exists, update missing initial details only when clearly safe, then stop and direct follow-up work to `nt-review-pr`.

## Document merge criteria

1. Draft concrete criteria from the task context, branch diff, verification results, and changed documentation.
2. When the current tool supports independent workers or subagents, ask one fresh read-only worker to draft the criteria from raw artifacts without editing files.
3. When independent workers are unavailable, draft the criteria in the main session and state that they were not independently produced. Do not block PR creation solely because a subagent feature is unavailable.
4. Post or add the criteria to the PR only after checking that each item is supported by the artifacts.

Cover required behavior, important failure cases, adjacent regression risk, required verification, and documentation updates. When backend controllers change, check whether `docs/develop/API-guide/` requires an update. When the change makes an irreversible architecture, data, infrastructure, dependency, authentication, or policy decision, check whether an ADR is required.

## Finish

Do not merge the PR. Report:

- PR URL and base/head branches
- commits pushed
- verification performed
- merge-criteria status and whether it was independently drafted
- residual risk
- the next action, normally `nt-review-pr <task-id>`
