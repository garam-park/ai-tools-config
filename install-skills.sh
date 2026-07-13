#!/usr/bin/env bash
# install-skills.sh
#
# 원본: ~/.local/share/skills/<name>/
# 각 도구의 개인용 스킬 경로에 심볼릭 링크를 만들어 동기화한다.
# 멱등성 보장: 여러 번 실행해도 같은 결과.
#
# 사용자가 손으로 만든 실제 파일/디렉토리는 삭제하지 않는다.
# 강제 교체가 필요하면 --force (백업 후 교체).
#
# 새 머신에서:
#   1) 이 스크립트와 스킬 폴더(SKILL.md 포함)를 ~/.local/share/skills/ 아래에 둔다
#   2) chmod +x install-skills.sh && ./install-skills.sh

set -euo pipefail
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

echo
echo "완료 (링크 $linked_count개). 다음 도구에서 사용 가능:"
echo "  - Claude Code: ~/.claude/skills"
echo "  - GitHub Copilot (VS Code): ~/.copilot/skills"
echo "  - Codex: ~/.codex/skills"
echo "  - OpenCode: ~/.config/opencode/skills"
