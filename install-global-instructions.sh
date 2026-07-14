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
#   - 심볼릭 링크 순환 탐지 (최대 40 depth)
#   - dangling 심링크(타깃 없음)는 dest 위치에 직접 쓴다
#   - 같은 파일시스템 tmp + mv 로 원자적 교체, 실패 시 tmp 정리(trap)
#
# 사용법:
#   ./install-global-instructions.sh [install]   # 동기화 (기본)
#   ./install-global-instructions.sh doctor      # 변경 없이 동기화 상태만 검사 (문제 시 exit 1)

set -euo pipefail
shopt -s inherit_errexit 2>/dev/null || true   # bash 4.4+: command substitution도 errexit 상속

CMD="install"
case "${1:-}" in
  "") ;;
  install|doctor)
    CMD="$1"
    ;;
  *)
    echo "사용법: $0 [install|doctor]" >&2
    exit 2
    ;;
esac
if [[ $# -gt 1 ]]; then
  echo "알 수 없는 인자입니다: $2" >&2
  echo "사용법: $0 [install|doctor]" >&2
  exit 2
fi

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
  local candidate
  candidate="$original.bak.$(date +%Y%m%d%H%M%S)"
  local suffix=0

  while [[ -e "$candidate" || -L "$candidate" ]]; do
    suffix=$((suffix + 1))
    candidate="$original.bak.$(date +%Y%m%d%H%M%S).$suffix"
  done
  printf '%s\n' "$candidate"
}

# install과 doctor가 같은 결과물 정의를 공유한다.
render_expected() {
  local src_name="$1"
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

# doctor: 아무것도 변경하지 않고 동기화 상태만 검사한다.
if [[ "$CMD" == "doctor" ]]; then
  problems=0
  for entry in "${TARGETS[@]}"; do
    dest="${entry%%|*}"
    src_name="${entry##*|}"

    write_target="$dest"
    if [[ -L "$dest" ]]; then
      if resolved="$(resolve_symlink_target "$dest" 2>/dev/null)" && [[ -n "$resolved" ]]; then
        write_target="$resolved"
      else
        echo "problem: $dest — 심볼릭 링크를 해석할 수 없습니다 (순환 의심)."
        problems=$((problems + 1))
        continue
      fi
    fi

    if [[ -f "$write_target" ]]; then
      if ! grep -qF "$MARKER" "$write_target"; then
        echo "problem: $dest — 자동 생성 마커가 없습니다 (사용자 작성 파일, install 시 백업 후 교체)."
        problems=$((problems + 1))
      elif ! cmp -s <(render_expected "$src_name") "$write_target"; then
        echo "problem: $dest — 내용이 원본과 다릅니다. install을 다시 실행하세요."
        problems=$((problems + 1))
      elif [[ -f "$SRC/$src_name" ]]; then
        echo "ok: $dest (common + $src_name)"
      else
        echo "ok: $dest (common only)"
      fi
    elif [[ -e "$write_target" ]]; then
      echo "problem: $dest — 대상이 일반 파일이 아닙니다: $write_target"
      problems=$((problems + 1))
    else
      echo "problem: $dest — 파일이 없습니다. install을 실행하세요."
      problems=$((problems + 1))
    fi
  done

  echo
  if [[ "$problems" -eq 0 ]]; then
    echo "doctor: 문제 없음."
    exit 0
  fi
  echo "doctor: ${problems}개 문제 발견. ./install-global-instructions.sh 를 실행해 동기화하세요."
  exit 1
fi

for entry in "${TARGETS[@]}"; do
  dest="${entry%%|*}"
  src_name="${entry##*|}"
  mkdir -p "$(dirname "$dest")"

  write_target="$dest"
  if [[ -L "$dest" ]]; then
    # 심볼릭 링크면 링크 타깃 파일에 동기화 (사용자 링크 구조 보존)
    if resolved="$(resolve_symlink_target "$dest" 2>/dev/null)" && [[ -n "$resolved" ]]; then
      write_target="$resolved"
      echo "note: $dest 는 심볼릭 링크입니다. 링크를 보존하고 $write_target 에 동기화합니다." >&2
    else
      # dangling 심링크: 타깃이 없으면 dest 위치에 직접 쓴다
      echo "note: $dest 는 손상된(dangling) 심볼릭 링크입니다. 링크 위치에 직접 동기화합니다." >&2
      write_target="$dest"
    fi
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
  render_expected "$src_name" > "$tmp"

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
