#!/usr/bin/env bash
# install-global-instructions.sh
#
# 원본: ~/ai-tools-config/global-instructions/
#   - common.md (모든 도구 공통)
#   - claude.md / codex.md / opencode.md (도구별 델타, 선택)
# 각 도구의 글로벌 지침 경로에 common.md + 도구별 파일을 결합해 동기화.
# 멱등성 보장: 여러 번 실행해도 같은 결과.

set -euo pipefail
shopt -s inherit_errexit 2>/dev/null || true

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$SRC_DIR/global-instructions"
COMMON="$SRC/common.md"
MARKER="AUTO-GENERATED-DO-NOT-EDIT"
tmp=""

cleanup() {
  [[ -z "$tmp" ]] || rm -f "$tmp"
}
trap cleanup EXIT

resolve_symlink_target() {
  local path="$1"
  local link_value
  local link_dir
  local depth=0

  while [[ -L "$path" ]]; do
    depth=$((depth + 1))
    if [[ "$depth" -gt 40 ]]; then
      echo "오류: 심볼릭 링크 순환이 의심됩니다: $1" >&2
      return 1
    fi
    link_value="$(readlink "$path")"
    if [[ "$link_value" == /* ]]; then
      path="$link_value"
    else
      link_dir="$(cd "$(dirname "$path")" && pwd -P)"
      path="$link_dir/$link_value"
    fi
  done
  printf '%s\n' "$path"
}

next_backup_path() {
  local original="$1"
  local candidate="$original.bak.$(date +%Y%m%d%H%M%S)"
  local suffix=0

  while [[ -e "$candidate" || -L "$candidate" ]]; do
    suffix=$((suffix + 1))
    candidate="$original.bak.$(date +%Y%m%d%H%M%S).$suffix"
  done
  printf '%s\n' "$candidate"
}

# 도구별 매핑: "대상 파일 경로|소스 파일 이름"
declare -a TARGETS=(
  "$HOME/.claude/CLAUDE.md|claude.md"
  "$HOME/.codex/AGENTS.md|codex.md"
  "$HOME/.config/opencode/AGENTS.md|opencode.md"
)

if [[ ! -f "$COMMON" ]]; then
  echo "오류: $COMMON 이 없습니다." >&2
  exit 1
fi

for entry in "${TARGETS[@]}"; do
  dest="${entry%%|*}"
  src_name="${entry##*|}"
  mkdir -p "$(dirname "$dest")"

  write_target="$dest"
  if [[ -L "$dest" ]]; then
    write_target="$(resolve_symlink_target "$dest")"
    echo "note: $dest 는 심볼릭 링크입니다. 링크를 보존하고 $write_target 에 동기화합니다." >&2
  fi
  mkdir -p "$(dirname "$write_target")"

  if [[ -f "$write_target" ]] && ! grep -qF "$MARKER" "$write_target"; then
    backup="$(next_backup_path "$write_target")"
    cp -p "$write_target" "$backup"
    echo "backed up: $write_target -> $backup"
  elif [[ -e "$write_target" && ! -f "$write_target" ]]; then
    echo "오류: 대상이 일반 파일이 아닙니다: $write_target" >&2
    exit 1
  fi

  tmp="$(mktemp "$write_target.XXXXXX")"
  {
    echo "<!-- $MARKER -->"
    echo "<!-- 동기화: install-global-instructions.sh — 직접 수정 시 다음 실행에 덮어써짐 -->"
    echo
    cat "$COMMON"
    if [[ -f "$SRC/$src_name" ]]; then
      echo
      echo "---"
      echo
      cat "$SRC/$src_name"
    fi
  } > "$tmp"

  mv "$tmp" "$write_target"
  tmp=""
  if [[ -f "$SRC/$src_name" ]]; then
    echo "synced: $dest (common + $src_name)"
  else
    echo "synced: $dest (common only)"
  fi
done

echo
echo "완료. 새 세션부터 적용됩니다 (이미 실행 중인 세션은 재시작 필요)."
