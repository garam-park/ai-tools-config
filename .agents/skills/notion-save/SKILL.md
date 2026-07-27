---
name: notion-save
description: Save user-provided notes, summaries, links, research, tasks, or other content as a new record in Notion through the project-local `notion` MCP server. Use when the user invokes `$notion-save` or asks to save, record, archive, add, or organize content in Notion. Prefer the skill-local `NOTION_DATABASE_ID` default, allow an explicit destination to override it, and ask which database to use when neither resolves safely.
---

# Notion Save

Store the requested content in a Notion database through the project-local `notion` MCP server registered by `scripts/mcp/notion/start.sh`.

## Workflow

1. Identify the content to save and any explicit destination database from the request and conversation.
2. Resolve the destination in this order:
   - Use an explicit database URL, ID, or name from the user.
   - Otherwise read the skill-local `.env` as dotenv text and use the exact `NOTION_DATABASE_ID` value when non-empty. Do not execute or source the file, and never print its contents.
   - Otherwise ask exactly one concise blocking question: `어느 Notion 데이터베이스에 저장할까요? 데이터베이스 이름이나 URL을 알려주세요.`
3. If a supplied name matches multiple databases, show only the minimal distinguishing candidates and ask the user to choose. Do not guess the destination.
4. Resolve the destination:
   - For an explicit Notion URL or ID, extract the database ID and verify it with `API-retrieve-a-database`.
   - For a database name, use `API-post-search`, select only an unambiguous database result, then verify it with `API-retrieve-a-database`.
5. Inspect the database's returned data source with `API-retrieve-a-data-source`. Use the current MCP tool schemas rather than assuming property names.
6. Map the content to existing properties:
   - Use the database's title property for the record title.
   - Derive a short, specific title from the content when the user did not provide one.
   - Map explicit metadata such as status, date, URL, tags, or category only when compatible properties exist.
   - Preserve the user's wording and links. Do not invent missing facts.
7. Create one new record with `API-post-page`.
8. When substantial content does not fit naturally in properties, store it in the page body. Prefer `API-update-page-markdown` after page creation for Markdown content.
9. Report success only after the MCP confirms the write. Include the created title, destination database, and page URL or ID when available.

## Write Rules

- Treat an explicit request to save as authorization to create one new Notion record after the destination is resolved. Do not ask for redundant confirmation.
- Never update, move, or delete an existing page unless the user explicitly requests it.
- If a required database property cannot be derived safely, ask one focused question before writing.
- If a write times out or returns an uncertain result, search for the intended title in the destination before retrying to avoid duplicates.
- Never expose tokens, authentication responses, or environment-file contents.
- On authentication failure, state that the project Notion MCP connection needs attention without printing secret values.
