---
name: ntn-analyze-task
description: Read and explain a Notion TSK task without changing Notion, files, code, branches, commits, or pull requests. Use when the user invokes `$ntn-analyze-task` or `/ntn-analyze-task`, provides a TSK task ID or Notion task URL, asks what a Notion task means, or needs its purpose, scope, requirements, risks, affected repositories, open questions, and recommended next workflow understood before specification, implementation, or PR work.
---

# 작업 분석

Explain a Notion task from available evidence while keeping the entire workflow read-only.

## Task source

- Config file: project-root `.env.tsk`
- Required keys: `NOTION_DATABASE_ID`, `NOTION_DATA_SOURCE_ID`
- Template: `skills/ntn-start-task/references/env.tsk.example` in this skill's source repository
- No built-in database defaults are allowed. If either key is missing, ask the user for a Notion database or task link that the active Notion integration can inspect, then use that link to determine and persist the missing values in `.env.tsk`.
- Task ID property: prefer `작업 ID` with prefix `TSK` when present; otherwise identify the matching ID/title property from the database schema and ask if ambiguous.
- Status property: prefer `상태` when present.
- Terminal statuses: treat clearly terminal statuses such as `완료`, `PR완료(DEV)`, and `보관됨` as terminal when present.

## Notion CLI usage

Assume `ntn` is installed, authenticated, and able to access the intended Notion workspace. Do not run standalone setup checks such as `command -v ntn`, `ntn --version`, or `ntn doctor` before useful work solely to verify the environment.

When a Notion task read is needed, run the specific `ntn` command for that work first. If that command fails because `ntn` is missing, not authenticated, outdated, or unable to access the workspace, explain the exact current failure and guide setup in detail:

- Install: run `curl -fsSL https://ntn.dev | bash`, or `npm install --global ntn` when Node.js 22+ and npm 10+ are available.
- Authenticate: run `ntn login` and choose the Notion workspace that contains the task database.
- Verify: run `ntn doctor`, then retry the exact `ntn` command that failed.
- Access issues: confirm the signed-in Notion user can open the database or page in Notion, and confirm `.env.tsk` points to the intended database and data source.

When the current tool can install CLI dependencies only with user approval, request approval after a real `ntn` command has failed for a setup reason. Only fall back to another currently available Notion integration or explicit Notion page content after the failed `ntn` command is understood. If no Notion access path is available, tell the user first. Include the exact missing setup and do not continue with local repository context as a substitute task source.

## Resolve the task

1. Accept a task ID such as `TSK-3477`, a numeric ID, or a Notion URL.
2. Normalize numeric IDs to `TSK-<number>`.
3. If more than one task remains plausible, ask one short clarification before querying or analyzing.
4. Read project-root `.env.tsk`. If `NOTION_DATABASE_ID` or `NOTION_DATA_SOURCE_ID` is missing, ask for a Notion database or task link, retrieve the IDs through `ntn datasources resolve <database-id>` or another available Notion access path, and create or update `.env.tsk`. Do not use hardcoded fallback IDs.
5. Use `ntn datasources query <data-source-id>` to find the matching page, then `ntn pages get <page-id>` to fetch the page and its content. Query only the configured Notion data source and do not mutate the page.
6. If the required `ntn` command fails for a setup or access reason, look for another currently available Notion integration or the user's provided Notion page content only after explaining the failure. Do not use local task files, branch context, PR metadata, or repository files as a substitute for the Notion task source.
7. If no Notion access path is available, report that the Notion task could not be retrieved and provide the exact missing setup: `ntn` installation/login, `.env.tsk` keys, required Notion link, or Notion workspace access.

## Gather evidence

1. Read task properties and meaningful page content, including title, ID, status, priority, tags, assignee, due date, summary, description, links, and checklists when available.
2. Inspect repository context only when needed to understand scope after the Notion task has been retrieved:
   - Read the repository README for navigation.
   - Read relevant agent instructions, API documentation, and nearby code only when the task names a module, endpoint, screen, or workflow.
   - Avoid implementation-level exploration when the task can be explained without it.
3. Separate directly supported facts from assumptions and inferences.

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
- Do not create, edit, move, or delete local files or product code.
- Do not change branches, commits, pull requests, or GitHub comments.
- Do not invent missing requirements. Label uncertain interpretations as assumptions.
- If the task is in a terminal status, report it and do not recommend implementation unless the user explicitly wants to resume or perform follow-up work.
