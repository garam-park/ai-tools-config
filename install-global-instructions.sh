#!/usr/bin/env bash
# install-global-instructions.sh
#
# 원본: ~/ai-tools-config/global-instructions/
#   - common.md (모든 도구 공통)
#   - claude.md / codex.md / opencode.md (도구별 델타, 선택)
# 각 도구의 글로벌 지침 경로에 common.md + 도구별 파일을 결합해 동기화.
# 멱등성 보장: 여러 번 실행해도 같은 결과.

set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$SRC_DIR/global-instructions"
COMMON="$SRC/common.md"

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

  tmp="$(mktemp)"
  {
    echo "<!-- 자동 생성. 원본: ~/ai-tools-config/global-instructions/ -->"
    echo "<!-- 동기화: install-global-instructions.sh -->"
    echo "<!-- 이 파일을 직접 수정해도 다음 실행 시 덮어쓰입니다. -->"
    echo
    cat "$COMMON"
  } > "$tmp"

  if [[ -f "$SRC/$src_name" ]]; then
    {
      echo
      echo "---"
      echo
      cat "$SRC/$src_name"
    } >> "$tmp"
    mv "$tmp" "$dest"
    echo "synced: $dest (common + $src_name)"
  else
    mv "$tmp" "$dest"
    echo "synced: $dest (common only)"
  fi
done

echo
echo "완료. 새 세션부터 적용됩니다 (이미 실행 중인 세션은 재시작 필요)."