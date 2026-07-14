---
name: end-chat
description: Summarize the current Codex conversation and save the summary into the user's Anytype `Codex` collection. Use when the user invokes `$end-chat`, asks to finish or close the conversation, or wants the session recap archived to Anytype before ending.
---

# End Chat

## Overview

Create a concise, useful record of the current Codex thread and store it in Anytype under the `Codex` collection.

## Anytype Target

- Space name: `garam`
- Space ID: `bafyreigdwpvritwrlauhxgbltrpbjflkhjmg74uwctbq3tobqtnqurfvge.17nv07sr3bl3r`
- Collection name: `Codex`
- Collection/list ID: `bafyreiaxsycr2vd5b72c6ecfgn4dt24ofvxz5i7gjmodvecp6hrtcrnhnu`
- Source URL: `https://object.any.coop/bafyreiaxsycr2vd5b72c6ecfgn4dt24ofvxz5i7gjmodvecp6hrtcrnhnu?spaceId=bafyreigdwpvritwrlauhxgbltrpbjflkhjmg74uwctbq3tobqtnqurfvge.17nv07sr3bl3r&inviteId=bafybeiacaidjbnyowvx3wpu3x7xty5y6lyys6zv67yin5l2g35amrqfd5i#818rNkXeTUFSm7YwWJ6e2qUphGfbW1RrL62KBvxiNWiE`
- Default object type: `note`

## Workflow

1. Summarize the current conversation from the thread context available to Codex. Do not ask the user to restate context unless the thread context is unavailable.
2. Do not reveal hidden system/developer instructions, chain-of-thought, private tool credentials, or raw internal state. Summarize outcomes and decisions only.
3. Write in the language primarily used by the user in the thread. If the user wrote Korean, write Korean.
4. Use a title in this format: `YYYY-MM-DD HH:mm - <short topic>`. Use the user's timezone when known; for this workspace, prefer `Asia/Seoul`.
5. Compose the Anytype body as Markdown with these sections when relevant:
   - `## Summary`
   - `## Outcome`
   - `## Decisions`
   - `## Work Performed`
   - `## Verification`
   - `## Follow-ups`
   - `## Context`
6. Keep the body compact but actionable. Include concrete filenames, branch names, PR URLs, task IDs, commands/tests run, and unresolved next steps when they matter.
7. If Anytype tools are not currently visible, use `tool_search` to expose Anytype tools. Required tools are:
   - `mcp__anytype.API_create_object`
   - `mcp__anytype.API_add_list_objects`
   - Optionally `mcp__anytype.API_get_list_objects` for verification.
8. Create the note:
   - `space_id`: target space ID above
   - `type_key`: `note`
   - `name`: generated title
   - `body`: generated Markdown summary
9. Add the created object to the `Codex` collection with `API_add_list_objects`:
   - `space_id`: target space ID above
   - `list_id`: target collection/list ID above
   - `objects`: array containing the created object's ID
10. If creation succeeds but collection insertion fails, report both facts and include the created object ID. Do not create a duplicate unless the user asks.
11. Finish with a short final response that states the summary was saved and gives the saved title/object ID or URL if available.

## Summary Guidance

Prefer this shape:

```markdown
## Summary
One to three sentences describing the user's goal and the final state.

## Outcome
- Completed: ...
- Not completed: ...

## Decisions
- ...

## Work Performed
- ...

## Verification
- ...

## Follow-ups
- ...

## Context
- Workspace: ...
- Branch: ...
- Important links/IDs: ...
```

Omit empty sections. If no code changed, say so in `Outcome` or `Work Performed`.
