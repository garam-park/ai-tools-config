---
name: lc-archive-task
description: Archive a completed local planning task (T0xx) document into planning/archive/tasks/mNNN/ and report index impact. Use when the user invokes `$lc-archive-task` or `/lc-archive-task`, asks to move a done task into the planning archive, or asks to clean up finished task documents. Only moves documents the user approves; never edits product code, candidates, or generated files.
---

# Archive Task (Local Lifecycle)

Move completed planning documents into the project's `planning/archive/` tree while preserving history. This is a document-move workflow: it never changes task content, status meaning, or product code.

## Task source

- Entry order: `docs/.agents/planning-guide.md` when present, then `planning/milestones/index.md`, then `planning/tasks/index.md`.
- Active task documents live under `planning/tasks/` (directly or in `mNNN/` subfolders); the archive lives under `planning/archive/tasks/mNNN/` grouped by milestone. Completed milestone documents live under `planning/archive/milestones/`.
- Task IDs are `T001` style and milestone IDs are `M001` style; IDs are never reused.
- Status values: `todo`, `doing`, `done`, `blocked`, recorded in frontmatter and mirrored in the index boards.

## Resolve the project root and target

1. Use the project path the user provided. If none is provided, walk up from the current directory to the first directory containing both an agent guide (`AGENTS.md` or equivalent) and `planning/`. If the planning entry points are missing, stop and say the project does not follow the local planning convention.
2. Accept a task ID (or a milestone ID for milestone-document archiving) and normalize it.
3. Locate the document and read its frontmatter, the owning milestone, and the two index boards.
4. If the document cannot be found, is ambiguous, or already lives under `planning/archive/`, report that and stop.

## Archive conditions

Archive only when all of the following hold; otherwise stop and explain which condition failed:

- The task document exists under an active path (not already archived).
- The task `status` is `done` in its frontmatter and in `planning/tasks/index.md`. Never archive a `todo`, `doing`, or `blocked` task.
- The destination directory `planning/archive/tasks/mNNN/` matches the task's owning milestone, and the destination file does not already exist.

A milestone document may be archived only when the user explicitly asks and every task of that milestone is `done` and archived (or its index rows are historical). Candidate `MC*` documents are never archived; they stay in `planning/candidates/` until promoted.

## Plan and move

1. Present the exact change plan before moving anything: source path, destination path, and every index link that will no longer resolve after the move.
2. Move approved documents with `git mv` so history is preserved as renames. Do not rewrite document content during the move.
3. Keep the historical rows in `planning/tasks/index.md` and `planning/milestones/index.md` as they are by default: the project's existing pattern preserves completed rows as history even when their links point into the archive. Do not silently rewrite or delete index rows.
4. If the user explicitly asks to fix links or remove stale rows, make only that approved edit and show the diff first.
5. After the move, verify the destination file exists, the source path is gone, and no other file was touched.

## Guardrails

- Do not archive tasks that are not `done`.
- Do not edit task or milestone document content, frontmatter, or status while archiving.
- Do not rewrite index rows, links, or history without explicit approval; report the impact instead.
- Do not touch product code, `planning/candidates/`, generated files, or any file outside the approved move.
- Do not stash, reset, rebase, delete branches, or commit/push unless the user explicitly asks; when committing is requested, follow the repository's commit message convention and do not add AI attribution trailers.
