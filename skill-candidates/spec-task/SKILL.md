---
name: spec-task
description: Refine an Innopam Notion task from the 솔루션 개발팀 작업 database into an actionable implementation specification. Use when the user invokes `$spec-task TSK-1234`, asks to 구체화, 명세화, clarify requirements, draft acceptance criteria, identify open questions, prepare a task before `$start-task`, or update a Notion/local task spec through conversation.
---

# Spec Task

## Overview

Specificate a Notion task before implementation. Fetch the task context, identify ambiguity, collaborate with the user to fill gaps, then produce an implementation-ready specification. Do not create implementation branches or edit product code.

## Task Source

- Workspace: `(주)이노팸`
- Database: `솔루션 개발팀 작업`
- Database ID: `71842431-f19c-4f43-9df7-461805cf3895`
- Data source ID, if the MCP supports it: `42e60fb3-5260-429b-8af4-ed28535f295b`
- Task ID property: `작업 ID` (`unique_id`, prefix `TSK`)
- Status property: `상태`
- Terminal statuses: `완료`, `PR완료(DEV)`, `보관됨`

## Workflow

1. Parse the first non-empty argument as the task ID. Accept `TSK-3477`, `tsk-3477`, or `3477`; normalize to display ID `TSK-3477` and unique ID number `3477`.
2. Fetch exactly one Notion page for that unique ID. Prefer the existing helper:

```bash
python3 /Users/garam/.codex/skills/start-task/scripts/notion_task.py TSK-3477 --config .codex/config.toml
```

3. Read enough properties and page blocks to understand the task. Include `작업 이름`, `작업 ID`, `상태`, `우선순위`, `태그`, `담당자`, due dates, `요약`, `Description`, links, checklist items, and meaningful body text in working context.
4. Search local task files under `tasks/backlog`, `tasks/in-progress`, and `tasks/review-ready` for the display ID, Notion page ID, or exact title. Read the local file if present, but do not move it between folders.
5. Inspect repository context only as needed to make the spec concrete. Read `README.md`, relevant `AGENTS.md`, `.claude/rules/`, existing API docs, nearby code, or product files when they clarify behavior, constraints, naming, or test expectations.
6. Produce a draft specification and explicitly separate confirmed facts from assumptions.
7. Ask concise clarification questions only for decisions that materially change scope, behavior, data shape, API contract, migration risk, or acceptance criteria. If questions are not blocking, continue with labeled assumptions.
8. After the user approves the draft, update the requested destination: Notion, the local task file, or both. Do not overwrite user-authored notes; append or replace only the clearly identified spec section.

## Specification Shape

Use this structure unless the task clearly needs a different one:

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

Keep each section implementation-oriented. Prefer observable behavior, data contracts, states, errors, permissions, and edge cases over broad product prose.

## Clarification Checklist

Check for gaps in these areas:

- User goal, target persona, and workflow entry point
- In-scope and out-of-scope behavior
- UI states, labels, validation, loading, empty, and error states
- API endpoints, request/response shape, status codes, and authorization
- Data model, persistence, defaults, uniqueness, ordering, and migration needs
- Compatibility with existing behavior and backward compatibility expectations
- Acceptance criteria that can be manually verified
- Automated test expectations and fixtures
- Deployment, configuration, rollout, or operational concerns
- Dependencies on other tasks, teams, documents, or decisions

## Update Discipline

- Default to drafting first and asking for approval before modifying Notion or local task files.
- Do not mark the task `진행 중` unless the user explicitly asks; that is `$start-task`'s responsibility.
- Do not create branches, commits, PRs, or product code changes.
- Preserve existing task history and user-authored content.
- If a task is terminal, do not reopen or rewrite it unless the user explicitly asks.
- If backend controller behavior is specified, include API-guide update requirements in the spec.
- If an irreversible architecture, data model, infrastructure, library, auth, or policy decision is required, include an ADR requirement in the spec.
