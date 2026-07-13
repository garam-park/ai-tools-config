#!/usr/bin/env bash
# install-skills.sh
#
# 원본: ~/.local/share/skills/<name>/
# 각 도구의 개인용 스킬 경로에 심볼릭 링크를 만들어 동기화한다.
# 멱등성 보장: 여러 번 실행해도 같은 결과.
#
# 사용자가 손으로 만든 실제 파일/디렉토리는 삭제하지 않는다.
# 강제 교체가 필요하면 --force (백업 후 교체).
# 원본에서 사라진 스킬의 관리 링크는 manifest(.skills-manifest)로 추적해 안전히 정리한다.
#
# 새 머신에서:
#   1) 이 스크립트와 스킬 폴더(SKILL.md 포함)를 ~/.local/share/skills/ 아래에 둔다
#   2) chmod +x install-skills.sh && ./install-skills.sh

set -euo pipefail
shopt -s inherit_errexit 2>/dev/null || true   # bash 4.4+: command substitution도 errexit 상속
shopt -s nullglob

FORCE=0
[[ "${1:-}" == "--force" ]] && FORCE=1

# 원본 폴더 (이 스크립트가 있는 폴더)
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -d "$SRC_DIR" ]]; then
  echo "원본 폴더를 찾을 수 없습니다: $SRC_DIR" >&2
  exit 1
fi

# 원본에서 스킬 후보 수집 (하위 디렉토리만; nullglob이라 없으면 빈 배열)
candidate_dirs=( "$SRC_DIR"/*/ )
if [[ ${#candidate_dirs[@]} -eq 0 ]]; then
  echo "warning: $SRC_DIR 에 디렉토리가 없습니다. 스킬 원본 위치를 확인하세요." >&2
  exit 1
fi

# SKILL.md가 있는 디렉토리만 실제 스킬로 인정 (후행 슬래시 제거)
skill_dirs=()
for skill_dir in "${candidate_dirs[@]}"; do
  skill_dir="${skill_dir%/}"
  [[ -f "$skill_dir/SKILL.md" ]] && skill_dirs+=("$skill_dir")
done

if [[ ${#skill_dirs[@]} -eq 0 ]]; then
  echo "warning: $SRC_DIR 에 SKILL.md가 있는 스킬이 없습니다. 디렉토리 구조를 확인하세요." >&2
  exit 1
fi

# --- 관리 링크 manifest (stale 링크 정리용) ---
# 스크립트가 만든 심링크 이름을 기록해, 원본에서 사라진 스킬의 링크만 안전히 제거한다.
# 형식: 스킬 이름 한 줄에 하나. 없거나 손상돼도 다음 실행에서 자가 복구된다.
MANIFEST="$SRC_DIR/.skills-manifest"

current_names=()
for skill_dir in "${skill_dirs[@]}"; do
  current_names+=("$(basename "$skill_dir")")
done

prev_names=()
if [[ -f "$MANIFEST" ]]; then
  while IFS= read -r _line; do
    [[ -n "$_line" ]] && prev_names+=("$_line")
  done < "$MANIFEST"
fi

# 배열에 값이 있는지
_contains() {
  local needle="$1"; shift
  local item
  for item in "$@"; do
    [[ "$item" == "$needle" ]] && return 0
  done
  return 1
}

# 동기화 대상 도구들의 개인용 스킬 경로
# (Copilot VS Code의 개인 스킬 경로는 ~/.copilot/skills 로 Claude Code와 별개)
TARGETS=(
  "$HOME/.claude/skills"             # Claude Code
  "$HOME/.copilot/skills"            # GitHub Copilot (VS Code) 개인 스킬
  "$HOME/.codex/skills"              # Codex
  "$HOME/.config/opencode/skills"    # OpenCode
)

linked_count=0

# 각 대상 디렉토리 준비 + 모든 스킬에 대해 심볼릭 링크 보장
for target in "${TARGETS[@]}"; do
  if ! mkdir -p "$target"; then
    echo "error: $target 를 만들 수 없습니다 — 권한 또는 상위 경로 확인 필요" >&2
    exit 1
  fi

  # 원본에서 사라진 스킬의 관리 링크만 정리 (사용자 소유 항목은 보존)
  if [[ ${#prev_names[@]} -gt 0 ]]; then
    for _name in "${prev_names[@]}"; do
      _contains "$_name" "${current_names[@]}" && continue
      stale="$target/$_name"
      if [[ -L "$stale" ]]; then
        _tgt="$(readlink "$stale" 2>/dev/null || true)"
        # 스크립트가 만든 링크는 정확히 $SRC_DIR/<name>을 가리킨다. 그 외 사용자 링크는 보존.
        if [[ "$_tgt" == "$SRC_DIR/$_name" ]]; then
          rm -f "$stale" && echo "removed stale link: $stale"
        else
          echo "skip stale: $stale 은(는) 스크립트가 만든 링크가 아님 (→ $_tgt)" >&2
        fi
      elif [[ -e "$stale" ]]; then
        echo "skip stale: $stale 은(는) 실제 파일/디렉토리라 제거하지 않음" >&2
      fi
    done
  fi

  for skill_dir in "${skill_dirs[@]}"; do
    name="$(basename "$skill_dir")"
    link="$target/$name"

    # 기존 항목 처리: 심링크만 교체, 실제 파일/디렉토리는 보호
    if [[ -L "$link" ]]; then
      rm -f "$link" || { echo "error: 기존 링크를 제거할 수 없습니다: $link" >&2; continue; }
    elif [[ -e "$link" ]]; then
      if [[ "$FORCE" == "1" ]]; then
        backup="$link.bak.$(date +%Y%m%d%H%M%S)"
        if mv "$link" "$backup"; then
          echo "backed up: $link -> $backup"
        else
          echo "error: 백업 실패로 건너뜀: $link" >&2
          continue
        fi
      else
        echo "skip: $link 은(는) 실제 파일/디렉토리라 덮어쓰지 않음 (--force 필요)" >&2
        continue
      fi
    fi

    if ln -s "$skill_dir" "$link"; then
      echo "linked: $link -> $skill_dir"
      linked_count=$((linked_count + 1))
    else
      echo "error: 링크를 만들 수 없습니다: $link -> $skill_dir" >&2
      continue
    fi
  done
done

# manifest 갱신 (설치 성공 후 현재 스킬 목록 기록)
printf '%s\n' "${current_names[@]}" > "$MANIFEST"

echo
echo "완료 (링크 $linked_count개). 다음 도구에서 사용 가능:"
echo "  - Claude Code: ~/.claude/skills"
echo "  - GitHub Copilot (VS Code): ~/.copilot/skills"
echo "  - Codex: ~/.codex/skills"
echo "  - OpenCode: ~/.config/opencode/skills"
