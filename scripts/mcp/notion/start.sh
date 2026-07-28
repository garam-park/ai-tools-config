#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
ENV_FILE="${MCP_NOTION_ENV_FILE:-"$SCRIPT_DIR/.env"}"

if [[ -f "$ENV_FILE" ]]; then
    set -a
    # shellcheck disable=SC1090
    source "$ENV_FILE"
    set +a
fi

if [[ -z "${MCP_NOTION_TOKEN:-}" ]]; then
    echo "Missing MCP_NOTION_TOKEN in $ENV_FILE" >&2
    exit 65
fi

export NOTION_TOKEN="${MCP_NOTION_TOKEN}"

cd "$PROJECT_ROOT"
exec npx -y @notionhq/notion-mcp-server@2.5.1
