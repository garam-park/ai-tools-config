---
name: lc-sync-milestone
description: Inspect and reconcile a local planning milestone (M0xx) against its tasks and the two index boards — IDs, statuses, relative links, dependencies, and cycles. Use when the user invokes `$lc-sync-milestone` or `/lc-sync-milestone`, asks for a planning sync or consistency check for a milestone, or asks whether milestone documents and indexes agree. Reports findings first and changes planning metadata only with user approval; never touches product code, candidates, or generated files.
---

# Sync Milestone (Local Lifecycle)

Reconcile one milestone's planning documents with the index boards. This is the meta step behind a project's "planning sync" task: it verifies that IDs, statuses, links, and dependencies agree, and it fixes planning metadata only with approval.

## Task source

- Entry order: `docs/.agents/planning-guide.md` when present, then `planning/milestones/index.md`, then `planning/tasks/index.md`.
- Active documents live under `planning/milestones/` and `planning/tasks/`; completed documents live under `planning/archive/`; candidates live under `planning/candidates/`.
- Milestone IDs are `M001` style, task IDs are `T001` style, candidate IDs are `MC001` style; IDs are never reused.
- Status values: `todo`, `doing`, `done`, `blocked`, recorded in frontmatter and mirrored in the index boards.

## Resolve the project root and milestone

1. Use the project path the user provided. If none is provided, walk up from the current directory to the first directory containing both an agent guide (`AGENTS.md` or equivalent) and `planning/`. If the planning entry points are missing, stop and say the project does not follow the local planning convention.
2. Accept a milestone ID and normalize it to `M<digits>`. A `MC*` candidate is not syncable as a milestone: report that it must be promoted first and stop.
3. Collect the milestone document, every task document that declares the milestone, the milestone row in `planning/milestones/index.md`, and the milestone's task rows in `planning/tasks/index.md` (including historical rows when the project keeps them).

## Inspect

Report every finding; the default run changes nothing.

1. ID integrity: IDs are unique, correctly shaped, and never reused across active and archive trees.
2. Status agreement: each task's frontmatter `status` matches its index row, and the milestone's status matches its row. Note any duplicate or contradictory historical rows instead of picking a winner.
3. Link integrity: every relative link in the milestone document and both index boards resolves to an existing file; note links that only resolve into `planning/archive/` as historical rather than broken when the project's pattern keeps them.
4. Dependency integrity: every `depends_on` entry exists, no dependency cycle exists, and no active task depends on an undone prerequisite without the user knowing.
5. Preservation: documents of other milestones, all `planning/candidates/` content, and archived content are present and unmodified.
6. Completion: list which tasks are not `done`. Do not declare the milestone complete while any task is incomplete.

## Fix (only with approval)

1. Present the findings and a concrete fix proposal per finding: exact file, exact change.
2. Apply only the fixes the user approves, and only to planning metadata: index rows, frontmatter status fields, or link targets. Show each diff before writing.
3. Never change task goals, scope, acceptance criteria, or verification content during a sync.
4. Re-run the inspection after approved fixes and report the remaining state.

## Guardrails

- Do not modify product code, `.omo/` plans, `planning/candidates/`, generated files, or anything outside the approved planning metadata fixes.
- Do not promote candidates, create milestones, or assign task IDs; those are user decisions.
- Do not declare a milestone `done` unless every task is `done` and the user approves the status change.
- Do not rewrite or delete historical index rows to make checks pass; report them instead.
- Do not stash, reset, rebase, delete branches, or commit/push unless the user explicitly asks; when committing is requested, follow the repository's commit message convention and do not add AI attribution trailers.
