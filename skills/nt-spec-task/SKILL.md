---
name: nt-spec-task
description: Refine a Notion TSK task into an implementation-ready specification without creating branches or editing product code. Use when the user invokes `$nt-spec-task` or `/nt-spec-task`, asks to clarify or concretize a TSK task, draft requirements and acceptance criteria, identify material open questions, or prepare a Notion task before implementation. Draft first and update Notion only after the user approves the specification and destination.
---

# Spec Task

Turn a Notion task into an actionable implementation specification through evidence gathering and focused clarification.

## Task source

- Config file: project-root `.env.tsk`
- Required keys: `NOTION_DATABASE_ID`, `NOTION_DATA_SOURCE_ID`
- No built-in database defaults are allowed. If either key is missing, ask the user for a Notion database or task link that the active Notion integration can inspect, then use that link to determine and persist the missing values in `.env.tsk`.
- Task ID property: prefer `작업 ID` with prefix `TSK` when present; otherwise identify the matching ID/title property from the database schema and ask if ambiguous.
- Status property: prefer `상태` when present.
- Terminal statuses: treat clearly terminal statuses such as `완료`, `PR완료(DEV)`, and `보관됨` as terminal when present.

## Notion access preflight

Before doing repository or specification work, check whether a usable Notion access path is available.

1. First check for the project-local `notion` MCP server and use it when available.
2. If the project-local MCP is unavailable, look for another currently available Notion integration or explicit Notion page content provided by the user.
3. If no Notion access path is available, tell the user first. Include the exact missing setup and do not continue with local repository context as a substitute task source.

## Resolve the task

1. Accept a TSK ID, numeric ID, or Notion URL. Normalize numeric IDs to `TSK-<number>`.
2. Read project-root `.env.tsk`. If `NOTION_DATABASE_ID` or `NOTION_DATA_SOURCE_ID` is missing, ask for a Notion database or task link, retrieve the IDs through the available Notion integration, and create or update `.env.tsk`. Do not use hardcoded fallback IDs.
3. First check for the project-local `notion` MCP server. Use it when available to fetch exactly one matching page from the configured data source. Do not mutate it during discovery.
4. If the project-local MCP is unavailable, look for another currently available Notion integration or the user's provided Notion page content. Do not use local task files, branch context, PR metadata, or repository files as a substitute for the Notion task source.
5. If no Notion access path is available, report that the Notion task could not be retrieved and provide the exact missing setup: `.env.tsk` keys, required Notion link, or Notion integration/credential access.
6. Read task properties and meaningful page content, including title, status, priority, tags, assignee, dates, summary, description, links, and checklists.

## Make the draft concrete

1. Inspect repository context only as needed. Read the README, applicable instructions, API documentation, nearby code, and product files when they clarify behavior, constraints, naming, or test expectations.
2. Separate confirmed requirements from assumptions.
3. Identify decisions and ambiguous interpretations before drafting final requirements. Treat product behavior, data shape, API contract, permissions, migration behavior, rollout, acceptance criteria, and repository ownership as decision-bearing when more than one reasonable interpretation exists.
4. Resolve decision-bearing ambiguity in the same session that invoked the skill. Ask concise questions and wait for the user's answer before proceeding when the answer materially changes scope, behavior, data shape, API contract, migration risk, rollout, repository ownership, or acceptance criteria.
5. Do not silently choose among materially different interpretations just to keep moving. If the user explicitly delegates the decision, record the chosen assumption and rationale in the draft.
6. Continue with explicitly labeled assumptions only when an unanswered question is non-blocking and does not materially change implementation or acceptance.

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
- unresolved decisions or ambiguous interpretations that must be answered in the invoking session before the specification can be treated as implementation-ready

When backend controller behavior changes, include the expected `docs/develop/API-guide/` update. When implementation requires an irreversible architecture, data, infrastructure, dependency, authentication, or policy decision, include an ADR requirement.

## Approve and update

1. Present the draft before writing to Notion.
2. Ask the user to approve the specification and the Notion update destination, or choose no write.
3. Use the available Notion integration for approved updates. If it cannot write, provide the final specification and explain the limitation instead of silently choosing another destination.
4. Preserve user-authored history. Append or replace only the clearly identified specification section.

## Guardrails

- Do not mark the task `진행 중`; implementation-start workflows own that transition.
- Do not create branches, commits, pull requests, or product-code changes.
- Do not write before the user approves the draft and destination.
- Do not reopen or rewrite a terminal task unless the user explicitly requests it.
