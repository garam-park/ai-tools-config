---
name: spec-task
description: Refine an Innopam `솔루션 개발팀 작업` item into an implementation-ready specification without creating branches or editing product code. Use when the user invokes spec-task with `$spec-task` or `/spec-task`, asks to clarify or concretize a TSK task, draft requirements and acceptance criteria, identify material open questions, or prepare a task before implementation. Draft first and update Notion or a local task file only after the user approves the specification and destination.
---

# Spec Task

Turn an Innopam task into an actionable implementation specification through evidence gathering and focused clarification.

## Task source

- Workspace: `(주)이노팸`
- Database: `솔루션 개발팀 작업`
- Database ID: `71842431-f19c-4f43-9df7-461805cf3895`
- Data source ID, when supported: `42e60fb3-5260-429b-8af4-ed28535f295b`
- Task ID property: `작업 ID` with prefix `TSK`
- Status property: `상태`
- Terminal statuses: `완료`, `PR완료(DEV)`, `보관됨`

## Resolve the task

1. Accept a TSK ID, numeric ID, Notion URL, local task file, or clearly matching current branch. Normalize numeric IDs to `TSK-<number>`.
2. Use a currently available Notion integration to fetch exactly one matching page from the configured database. Do not mutate it during discovery.
3. If Notion is unavailable, continue from local task files and user-provided context. State which source is unavailable before presenting the draft.
4. Read task properties and meaningful page content, including title, status, priority, tags, assignee, dates, summary, description, links, and checklists.
5. Search local task directories for the exact ID and title. Read matching files without moving or modifying them.

## Make the draft concrete

1. Inspect repository context only as needed. Read the README, applicable instructions, API documentation, nearby code, and product files when they clarify behavior, constraints, naming, or test expectations.
2. Separate confirmed requirements from assumptions.
3. Ask concise questions only when the answer materially changes scope, behavior, data shape, API contract, migration risk, or acceptance criteria.
4. Continue with explicitly labeled assumptions when an unanswered question is non-blocking.

Use this shape unless the task clearly needs another structure:

```markdown
## Problem
## Goal
## Non-goals
## Requirements
## Acceptance Criteria
## Technical Notes
## Test Plan
## Open Questions
## Assumptions
```

Prefer observable behavior, data contracts, states, errors, permissions, and edge cases over broad product prose.

## Check specification completeness

Check relevant gaps in:

- user goal, actor, and workflow entry point
- in-scope and out-of-scope behavior
- UI loading, empty, validation, success, and error states
- API contracts, status codes, and authorization
- persistence, defaults, uniqueness, ordering, and migrations
- backward compatibility and adjacent regression risk
- manually verifiable acceptance criteria and automated tests
- configuration, rollout, operations, dependencies, and documentation

When backend controller behavior changes, include the expected `docs/develop/API-guide/` update. When implementation requires an irreversible architecture, data, infrastructure, dependency, authentication, or policy decision, include an ADR requirement.

## Approve and update

1. Present the draft before writing to Notion or local files.
2. Ask the user to approve both the specification and the destination: Notion, a named local task file, both, or no write.
3. Use the available Notion integration for approved updates. If it cannot write, provide the final specification and explain the limitation instead of silently choosing another destination.
4. Preserve user-authored history. Append or replace only the clearly identified specification section.

## Guardrails

- Do not mark the task `진행 중`; implementation-start workflows own that transition.
- Do not create branches, commits, pull requests, or product-code changes.
- Do not write before the user approves the draft and destination.
- Do not reopen or rewrite a terminal task unless the user explicitly requests it.
