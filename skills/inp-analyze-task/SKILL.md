---
name: inp-analyze-task
description: Read and explain an Innopam `솔루션 개발팀 작업` item without changing Notion, files, code, branches, commits, or pull requests. Use when the user invokes `$inp-analyze-task` or `/inp-analyze-task`, provides an Innopam TSK task ID or task URL, asks what an Innopam task means, or needs its purpose, scope, requirements, risks, affected repositories, open questions, and recommended next workflow understood before specification, implementation, or PR work.
---

# 작업 분석

Explain an Innopam task from available evidence while keeping the entire workflow read-only.

## Task source

- Workspace: `(주)이노팸`
- Database: `솔루션 개발팀 작업`
- Database ID: `71842431-f19c-4f43-9df7-461805cf3895`
- Data source ID, when supported: `42e60fb3-5260-429b-8af4-ed28535f295b`
- Task ID property: `작업 ID` with prefix `TSK`
- Status property: `상태`
- Terminal statuses: `완료`, `PR완료(DEV)`, `보관됨`

## Resolve the task

1. Accept a task ID such as `TSK-3477`, a numeric ID, a Notion URL, a local task file, or an ID clearly present in the current branch name.
2. Normalize numeric IDs to `TSK-<number>`.
3. If more than one task remains plausible, ask one short clarification before querying or analyzing.
4. Use a currently available Notion integration to fetch the matching page and its content. Query only the configured Innopam database and do not mutate the page.
5. If Notion is unavailable, continue from local task files, branch context, PR metadata, and user-provided information. State which source could not be retrieved.

## Gather evidence

1. Read task properties and meaningful page content, including title, ID, status, priority, tags, assignee, due date, summary, description, links, and checklists when available.
2. Search existing local task directories for the exact task ID and title. Treat local files as supporting context, not as authority over the current Notion page.
3. Inspect repository context only when needed to understand scope:
   - Read the repository README for navigation.
   - Read relevant agent instructions, API documentation, and nearby code only when the task names a module, endpoint, screen, or workflow.
   - Avoid implementation-level exploration when the task can be explained without it.
4. Separate directly supported facts from assumptions and inferences.

## Produce the analysis

Keep the default response concise and use the user's language. Include only useful sections:

- `작업 요약`: explain the task in one or two plain-language sentences.
- `확인된 사실`: report status, priority, ownership, dates, links, and explicit requirements.
- `해야 할 일`: describe the likely change or investigation scope.
- `영향 범위`: identify likely repositories, modules, APIs, screens, data, tests, and documentation.
- `불명확한 점`: distinguish blocking questions from non-blocking assumptions.
- `리스크`: note compatibility, migration, permissions, regression, deployment, and verification risks.
- `추천 다음 단계`: recommend specification, implementation, isolated-worktree implementation, PR creation, or existing-PR handling as appropriate.

## Guardrails

- Do not change Notion status or content.
- Do not create, edit, move, or delete local task files or product code.
- Do not change branches, commits, pull requests, or GitHub comments.
- Do not invent missing requirements. Label uncertain interpretations as assumptions.
- If the task is in a terminal status, report it and do not recommend implementation unless the user explicitly wants to resume or perform follow-up work.
