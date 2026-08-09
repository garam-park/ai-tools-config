---
name: lc-analyze-task
description: Read and explain a local planning task (T0xx) without changing planning files, code, branches, commits, or pull requests. Use when the user invokes `$lc-analyze-task` or `/lc-analyze-task`, provides a T0xx task ID, asks what a local planning task means, or needs its purpose, scope, requirements, dependencies, risks, and recommended next workflow understood before specification, implementation, or PR work.
---

# 작업 분석 (Local Lifecycle)

Explain a task from the project's local `planning/` documents while keeping the entire workflow read-only. `lc-` skills use the local planning markdown as the task source; they never use Notion, Linear, or any external tracker.

## Task source

- Entry order: `docs/.agents/planning-guide.md` when present, then `planning/milestones/index.md`, then `planning/tasks/index.md`.
- Active task documents live under `planning/tasks/` (directly or in `mNNN/` subfolders); completed documents live under `planning/archive/tasks/mNNN/`; completed milestone documents live under `planning/archive/milestones/`; candidate milestones live under `planning/candidates/`.
- Task IDs are `T001` style, milestone IDs are `M001` style, candidate milestone IDs are `MC001` style. IDs are never reused.
- Status values: `todo`, `doing`, `done`, `blocked`. Status is recorded in each document's YAML frontmatter block and mirrored in the `index.md` boards.

## Resolve the project root

1. Use the project path the user provided. If none is provided, walk up from the current directory to the first directory containing both an agent guide (`AGENTS.md` or equivalent) and `planning/`.
2. Confirm the planning entry points exist: `planning/milestones/index.md` and `planning/tasks/index.md`. If either is missing, stop and say the project does not follow the local planning convention. Do not invent a task source or fall back to branch and PR metadata as a substitute.

## Resolve the task

1. Accept a task ID such as `T045`, a lowercase form, or a milestone-scoped reference. Normalize it to `T<digits>`.
2. Locate the task in `planning/tasks/index.md` (including historical rows for archived milestones) or in `planning/archive/tasks/mNNN/` for completed work.
3. If more than one task remains plausible, ask one short clarification before analyzing.
4. Read the task document's frontmatter (`id`, `milestone`, `status`, `depends_on`) and body sections such as 목표, 범위, 제외 범위, 완료 조건, 검증, 구현 결과.
5. Read the owning milestone document (active path or archive path) for scope context.
6. Treat `MC*` candidate milestones as candidate-only: they are deferred and are not active implementation work.

## Gather evidence

1. Separate directly supported facts from assumptions and inferences.
2. Inspect repository context (README, agent guide, conventions docs, nearby code) only when needed to explain scope after the planning documents have been read. Avoid implementation-level exploration when the task can be explained without it.
3. Note dependency state: any `depends_on` task that is not `done` blocks implementation.
4. Note whether the owning milestone is active, `done`/archived, or a candidate.

## Produce the analysis

Keep the default response concise and use the user's language. Include only useful sections:

- `작업 요약`: explain the task in one or two plain-language sentences.
- `확인된 사실`: report status, milestone, dependencies, and explicit requirements from the documents.
- `해야 할 일`: describe the likely change or investigation scope.
- `영향 범위`: identify likely packages, modules, APIs, screens, data, tests, and documentation.
- `불명확한 점`: distinguish blocking questions from non-blocking assumptions.
- `리스크`: note compatibility, migration, permissions, regression, and verification risks.
- `추천 다음 단계`: recommend `lc-spec-task`, `lc-start-task`, `lc-create-pr`, or `lc-review-pr` as appropriate.

## Guardrails

- Do not create, edit, move, or delete planning files, product code, or any other file.
- Do not change branches, commits, pull requests, or comments.
- Do not invent missing requirements. Label uncertain interpretations as assumptions.
- If the task is `done` or archived, report it and do not recommend implementation unless the user explicitly wants follow-up work.
- If the task belongs to a candidate milestone, report the candidate-only status and do not recommend starting implementation.
