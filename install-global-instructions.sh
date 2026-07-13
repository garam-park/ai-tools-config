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

# 자동 관리 파일을 식별하는 단일 토큰 (작업 25)
MARKER='AUTO-GENERATED-DO-NOT-EDIT'

if [[ ! -f "$COMMON" ]]; then
  echo "오류: $COMMON 이 없습니다." >&2
  exit 1
fi

for entry in "${TARGETS[@]}"; do
  dest="${entry%%|*}"
  src_name="${entry##*|}"

  # dest 가 심볼릭 링크면 링크 타깃 파일을 기준으로 작업한다 (작업 23).
  # dangling 심링크(타깃 없음)는 dest 위치에 직접 쓴다.
  if [[ -L "$dest" ]]; then
    if real_target="$(readlink -f -- "$dest" 2>/dev/null)" && [[ -n "$real_target" && -e "$real_target" ]]; then
      echo "note: $dest 는 심볼릭 링크 (→ $real_target). 링크 타깃 파일에 동기화합니다." >&2
      target_for_write="$real_target"
    else
      target_for_write="$dest"
    fi
  else
    target_for_write="$dest"
  fi

  mkdir -p "$(dirname "$target_for_write")"

  # 목적지와 같은 디렉토리에 tmp 를 만들어 mv 가 같은 파일시스템에서
  # 원자적으로 동작하도록 한다. 실패 시 tmp 가 남지 않도록 trap 설치 (작업 12).
  tmp="$(mktemp "$target_for_write.XXXXXX")"
  trap 'rm -f "$tmp"' EXIT

  {
    echo "<!-- $MARKER -->"
    echo "<!-- 원본: ~/ai-tools-config/global-instructions/ (install-global-instructions.sh 로 동기화) -->"
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
  fi

  # 자동 생성 마커가 없는 기존 사용자 파일은 백업 후 덮어쓴다 (작업 02).
  # 토큰이 라인 위치와 무관하게 매칭되도록 grep -qF 사용 (작업 25).
  if [[ -f "$target_for_write" ]] && ! grep -qF "$MARKER" "$target_for_write"; then
    backup="$target_for_write.bak.$(date +%Y%m%d%H%M%S)"
    cp "$target_for_write" "$backup"
    echo "backed up: $target_for_write -> $backup"
  fi

  mv "$tmp" "$target_for_write"

  if [[ -f "$SRC/$src_name" ]]; then
    echo "synced: $target_for_write (common + $src_name)"
  else
    echo "synced: $target_for_write (common only)"
  fi
done

echo
echo "완료. 새 세션부터 적용됩니다 (이미 실행 중인 세션은 재시작 필요)."
