---
name: lc-spec-task
description: Refine a local planning task (T0xx) or candidate milestone into an implementation-ready specification without creating branches or editing product code. Use when the user invokes `$lc-spec-task` or `/lc-spec-task`, asks to clarify or concretize a planning task, draft goals, scope, acceptance criteria, and verification steps, or prepare a planning document before implementation. Draft first and write planning files only after the user approves the specification and destination.
---

# Spec Task (Local Lifecycle)

Turn a local planning task into an actionable implementation specification through evidence gathering and focused clarification. The task source is the project's `planning/` documents, not an external tracker.

## Task source

- Entry order: `docs/.agents/planning-guide.md` when present, then `planning/milestones/index.md`, then `planning/tasks/index.md`.
- Task IDs are `T001` style, milestone IDs are `M001` style, candidate milestone IDs are `MC001` style. IDs are never reused; a new task takes the next unused `T` number from `planning/tasks/index.md`.
- Status values: `todo`, `doing`, `done`, `blocked`. Status lives in each document's YAML frontmatter block and is mirrored in the `index.md` boards.

## Resolve the project root and task

1. Use the project path the user provided. If none is provided, walk up from the current directory to the first directory containing both an agent guide (`AGENTS.md` or equivalent) and `planning/`. If the planning entry points are missing, stop and say the project does not follow the local planning convention.
2. Accept a task ID, a milestone ID, or a candidate ID. Normalize task IDs to `T<digits>`.
3. Read the target document's frontmatter and body, the owning milestone document, and the two index boards.
4. If more than one target remains plausible, ask one short clarification before drafting.
5. A `MC*` candidate may be specified, but label the result as a candidate-stage specification: it must not be treated as active implementation work until the candidate is promoted to a real milestone by the user.

## Make the draft concrete

1. Inspect repository context only as needed: README, agent guide, conventions docs under `docs/conventions/`, nearby code, and existing contracts when they clarify behavior, constraints, naming, or test expectations.
2. Separate confirmed requirements from assumptions.
3. Identify decisions and ambiguous interpretations before drafting. Treat product behavior, data shape, API contract, permissions, migration behavior, and acceptance criteria as decision-bearing when more than one reasonable interpretation exists.
4. Resolve decision-bearing ambiguity in the same session. Ask concise questions and wait for the user's answer when the answer materially changes scope, behavior, data shape, or acceptance criteria. Do not silently choose among materially different interpretations just to keep moving.
5. Continue with explicitly labeled assumptions only when an unanswered question is non-blocking.

Use the project's task document shape unless the task clearly needs another structure:

```markdown
---
id: T0xx
milestone: M0xx
status: todo
depends_on: []
---

## 목표
## 범위
## 제외 범위
## 완료 조건
## 검증
```

Prefer observable behavior, data contracts, states, errors, permissions, and edge cases over broad product prose. `검증` must name the exact commands to run and the expected outcome, following the project's own verification rules when its agent guide defines them.

## Check specification completeness

Check relevant gaps in:

- user goal, actor, and workflow entry point
- in-scope and out-of-scope behavior
- UI loading, empty, validation, success, and error states when a screen is involved
- API contracts, status codes, and authorization when an endpoint is involved
- persistence, defaults, uniqueness, ordering, and migrations when data is involved
- backward compatibility and adjacent regression risk
- manually verifiable acceptance criteria and automated tests
- unresolved decisions that must be answered before the specification is implementation-ready

## Approve and write

1. Present the draft before writing any file.
2. Ask the user to approve the specification and the destination file, or choose no write.
3. For an existing task, preserve user-authored history: update only the sections the user approved.
4. For a new task, create the document at the location the project's planning guide prescribes, register the row in `planning/tasks/index.md`, and keep `status: todo`. Assigning `doing` belongs to `lc-start-task`, not this skill.

## Guardrails

- Do not set any task `status` to `doing`; implementation-start workflows own that transition.
- Do not create branches, commits, pull requests, or product-code changes.
- Do not write planning files before the user approves the draft and destination.
- Do not promote a `MC*` candidate to an active milestone; that is the user's decision.
- Do not reopen or rewrite a `done` or archived task unless the user explicitly requests it.
