#!/usr/bin/env bash
# install-global-instructions.sh
#
# 원본: ~/ai-tools-config/global-instructions/
#   - common.md (모든 도구 공통)
#   - claude.md / codex.md / opencode.md (도구별 델타, 선택)
# 각 도구의 글로벌 지침 경로에 common.md + 도구별 파일을 결합해 동기화.
# 멱등성 보장: 여러 번 실행해도 같은 결과.
#
# 안전장치:
#   - 자동 생성 마커가 없는 기존(사용자 작성) 파일은 덮어쓰기 전에 백업
#   - dest가 심볼릭 링크면 링크 타깃 파일에 동기화하고 링크 자체는 보존
#   - 같은 파일시스템 tmp + mv 로 원자적 교체, 실패 시 tmp 정리(trap)

set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$SRC_DIR/global-instructions"
COMMON="$SRC/common.md"

# 자동 생성 파일 판별용 고유 토큰 (라인 위치와 무관하게 매칭)
MARKER="AUTO-GENERATED-DO-NOT-EDIT"

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

# 중단 시 임시 파일이 남지 않도록 정리 (tmp는 루프에서 갱신됨)
tmp=""
trap 'rm -f "$tmp"' EXIT

for entry in "${TARGETS[@]}"; do
  dest="${entry%%|*}"
  src_name="${entry##*|}"

  # dest가 심볼릭 링크면 링크 타깃을 기준으로 백업·쓰기 (사용자 링크 보존)
  if [[ -L "$dest" ]]; then
    real_target="$(readlink -f -- "$dest" 2>/dev/null || true)"
    [[ -n "$real_target" ]] || real_target="$dest"
    if [[ -e "$real_target" ]]; then
      echo "note: $dest 는 심볼릭 링크 (→ $real_target). 링크 타깃 파일에 동기화합니다." >&2
    else
      echo "note: $dest 는 손상된 심볼릭 링크입니다. 타깃 경로에 새 파일을 만듭니다: $real_target" >&2
    fi
    write_to="$real_target"
  else
    write_to="$dest"
  fi

  mkdir -p "$(dirname "$write_to")"

  # 자동 생성 마커가 없는 기존 파일(사용자 작성)은 백업 후 덮어쓰기
  if [[ -f "$write_to" ]] && ! grep -qF "$MARKER" "$write_to"; then
    backup="$write_to.bak.$(date +%Y%m%d%H%M%S)"
    cp "$write_to" "$backup"
    echo "backed up: $write_to -> $backup"
  fi

  # 목적지와 같은 디렉토리에 tmp 생성 → mv가 same-filesystem rename(원자적)
  tmp="$(mktemp "$write_to.XXXXXX")"

  {
    echo "<!-- $MARKER -->"
    echo "<!-- 원본: ~/ai-tools-config/global-instructions/ · 동기화: install-global-instructions.sh — 직접 수정 시 다음 실행에 덮어써짐 -->"
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
    mv "$tmp" "$write_to"
    echo "synced: $write_to (common + $src_name)"
  else
    mv "$tmp" "$write_to"
    echo "synced: $write_to (common only)"
  fi
  tmp=""
done

echo
echo "완료. 새 세션부터 적용됩니다 (이미 실행 중인 세션은 재시작 필요)."
