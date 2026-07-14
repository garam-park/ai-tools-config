#!/usr/bin/env python3
import argparse
import json
import os
import re
import sys
import urllib.error
import urllib.request

DATABASE_ID = "71842431-f19c-4f43-9df7-461805cf3895"
NOTION_VERSION = "2022-06-28"
IN_PROGRESS = "진행 중"
TERMINAL_STATUSES = {"완료", "PR완료(DEV)", "보관됨"}


def fail(message, code=1):
    print(json.dumps({"ok": False, "error": message}, ensure_ascii=False))
    raise SystemExit(code)


def normalize_task_id(raw):
    match = re.search(r"(?:TSK-?)?(\d+)", raw.strip(), re.IGNORECASE)
    if not match:
        fail(f"Invalid task ID: {raw}")
    number = int(match.group(1))
    return number, f"TSK-{number}"


def load_token(config_path):
    token = os.environ.get("NOTION_TOKEN")
    if token:
        return token
    try:
        with open(config_path, "r", encoding="utf-8") as f:
            text = f.read()
    except FileNotFoundError:
        fail(f"Config file not found: {config_path}")
    match = re.search(r'^\s*NOTION_TOKEN\s*=\s*"([^"]+)"', text, re.MULTILINE)
    if not match:
        fail(f"NOTION_TOKEN not found in {config_path}")
    return match.group(1)


def notion_request(method, path, token, body=None):
    data = None
    if body is not None:
        data = json.dumps(body, ensure_ascii=False).encode("utf-8")
    req = urllib.request.Request(
        f"https://api.notion.com/v1{path}",
        data=data,
        method=method,
        headers={
            "Authorization": f"Bearer {token}",
            "Notion-Version": NOTION_VERSION,
            "Content-Type": "application/json",
        },
    )
    try:
        with urllib.request.urlopen(req, timeout=30) as res:
            return json.loads(res.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        detail = e.read().decode("utf-8", errors="replace")
        fail(f"Notion API error {e.code}: {detail}")
    except urllib.error.URLError as e:
        fail(f"Network error: {e.reason}")


def plain_rich_text(items):
    return "".join(item.get("plain_text", "") for item in items or [])


def prop_text(prop):
    if not prop:
        return ""
    typ = prop.get("type")
    if typ == "title":
        return plain_rich_text(prop.get("title"))
    if typ == "rich_text":
        return plain_rich_text(prop.get("rich_text"))
    if typ == "status":
        value = prop.get("status")
        return value.get("name", "") if value else ""
    if typ == "select":
        value = prop.get("select")
        return value.get("name", "") if value else ""
    if typ == "multi_select":
        return [v.get("name", "") for v in prop.get("multi_select", [])]
    if typ == "people":
        return [v.get("name") or v.get("id", "") for v in prop.get("people", [])]
    if typ == "date":
        value = prop.get("date")
        return value if value else None
    if typ == "unique_id":
        value = prop.get("unique_id") or {}
        prefix = value.get("prefix")
        number = value.get("number")
        return f"{prefix}-{number}" if prefix and number is not None else number
    return prop.get(typ)


def summarize_page(page):
    props = page.get("properties", {})
    return {
        "page_id": page.get("id"),
        "url": page.get("url"),
        "title": prop_text(props.get("작업 이름")),
        "task_id": prop_text(props.get("작업 ID")),
        "status": prop_text(props.get("상태")),
        "priority": prop_text(props.get("우선순위")),
        "tags": prop_text(props.get("태그")),
        "assignees": prop_text(props.get("담당자")),
        "due_date": prop_text(props.get("마감일")),
        "expected_due_date": prop_text(props.get("예상 마감일")),
        "summary": prop_text(props.get("요약")),
        "description": prop_text(props.get("Description")),
    }


def block_text(block):
    typ = block.get("type")
    data = block.get(typ, {}) if typ else {}
    text = plain_rich_text(data.get("rich_text"))
    if typ == "to_do":
        checked = "[x]" if data.get("checked") else "[ ]"
        return f"{checked} {text}".strip()
    return text


def fetch_blocks(page_id, token, limit):
    blocks = []
    cursor = None
    while len(blocks) < limit:
        suffix = f"?page_size={min(100, limit - len(blocks))}"
        if cursor:
            suffix += f"&start_cursor={cursor}"
        result = notion_request("GET", f"/blocks/{page_id}/children{suffix}", token)
        for block in result.get("results", []):
            text = block_text(block)
            if text:
                blocks.append({"type": block.get("type"), "text": text})
        if not result.get("has_more"):
            break
        cursor = result.get("next_cursor")
        if not cursor:
            break
    return blocks


def query_task(number, token):
    body = {
        "filter": {
            "property": "작업 ID",
            "unique_id": {"equals": number},
        },
        "page_size": 2,
    }
    result = notion_request("POST", f"/databases/{DATABASE_ID}/query", token, body)
    pages = result.get("results", [])
    if not pages:
        fail(f"Task TSK-{number} not found", code=2)
    if len(pages) > 1:
        fail(f"Task TSK-{number} returned multiple pages", code=3)
    return pages[0]


def update_status(page_id, token):
    body = {"properties": {"상태": {"status": {"name": IN_PROGRESS}}}}
    notion_request("PATCH", f"/pages/{page_id}", token, body)


def main():
    parser = argparse.ArgumentParser(description="Fetch and optionally start an Innopam Notion task.")
    parser.add_argument("task_id", help="Task ID such as TSK-3477 or 3477")
    parser.add_argument("--config", default=".codex/config.toml", help="Path to config.toml containing NOTION_TOKEN")
    parser.add_argument("--start", action="store_true", help="Set status to 진행 중 unless terminal")
    parser.add_argument("--block-limit", type=int, default=100, help="Maximum page body blocks to return")
    args = parser.parse_args()

    number, display_id = normalize_task_id(args.task_id)
    token = load_token(args.config)
    page = query_task(number, token)
    summary = summarize_page(page)

    updated = False
    skipped = False
    status = summary.get("status") or ""
    if args.start:
        if status in TERMINAL_STATUSES:
            skipped = True
        elif status != IN_PROGRESS:
            update_status(summary["page_id"], token)
            updated = True
            summary["status"] = IN_PROGRESS

    blocks = fetch_blocks(summary["page_id"], token, max(args.block_limit, 0))
    print(json.dumps({
        "ok": True,
        "requested_task_id": display_id,
        "updated_status": updated,
        "skipped_terminal_status": skipped,
        "task": summary,
        "blocks": blocks,
    }, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
