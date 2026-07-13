#!/usr/bin/env bash
# install-skills.sh
#
# 원본: 이 스크립트가 있는 폴더의 skills/<name>/
# 각 도구의 개인용 스킬 경로에 심볼릭 링크를 만들어 동기화한다.
# 멱등성 보장: 여러 번 실행해도 같은 결과.
#
# 새 머신에서:
#   1) 이 스크립트와 skills/ 폴더를 같은 디렉토리에 둔다
#   2) chmod +x install-skills.sh && ./install-skills.sh

set -euo pipefail

# 원본 폴더 (이 스크립트가 있는 폴더)
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST="$SRC_DIR/.ai-tools-config.manifest"

if [[ ! -d "$SRC_DIR" ]]; then
  echo "원본 폴더를 찾을 수 없습니다: $SRC_DIR" >&2
  exit 1
fi

# 동기화 대상 도구들의 개인용 스킬 경로
# (Claude Code와 GitHub Copilot (VS Code)은 ~/.claude/skills 를 공유한다)
TARGETS=(
  "$HOME/.claude/skills"             # Claude Code + GitHub Copilot (VS Code)
  "$HOME/.codex/skills"              # Codex
  "$HOME/.config/opencode/skills"    # OpenCode
)

# --force: 실제 파일/디렉토리도 백업 후 교체한다 (기본값: 보호)
FORCE=0
[[ "${1:-}" == "--force" ]] && FORCE=1

# 글롭 매칭이 없으면 패턴이 그대로 남는 것을 방지 (작업 10)
shopt -s nullglob
skill_dirs=( "$SRC_DIR"/*/ )

# 빈 SRC_DIR이면 명시적 경고 후 비정상 종료 (작업 24)
if [[ ${#skill_dirs[@]} -eq 0 ]]; then
  echo "warning: $SRC_DIR 에 디렉토리가 없습니다. 스킬 원본 위치를 확인하세요." >&2
  exit 1
fi

linked_count=0
current_names=()

# 각 대상 디렉토리 준비 + 모든 스킬에 대해 심볼릭 링크 보장
for target in "${TARGETS[@]}"; do
  # mkdir 실패는 명확한 에러와 함께 전체 종료 (작업 22)
  if ! mkdir -p "$target"; then
    echo "error: cannot create $target — 권한 또는 상위 경로 확인 필요" >&2
    exit 1
  fi

  for skill_dir in "${skill_dirs[@]}"; do
    # SKILL.md 가 있는 디렉토리만 실제 스킬로 간주 (작업 14: 죽은 가드 제거 + SKILL.md 필터)
    [[ -f "$skill_dir/SKILL.md" ]] || continue

    skill_dir="${skill_dir%/}"   # 심링크 타깃 문자열의 후행 슬래시 제거 (작업 13)
    name="$(basename "$skill_dir")"
    link="$target/$name"

    if [[ -L "$link" ]]; then
      # 기존 관리 링크는 그대로 교체 (작업 01)
      if ! rm -f "$link"; then
        echo "error: cannot remove existing link $link" >&2
        continue
      fi
    elif [[ -e "$link" ]]; then
      # 실재 파일/디렉토리는 --force 일 때만 백업 후 교체 (작업 01)
      if [[ "$FORCE" == "1" ]]; then
        backup="$link.bak.$(date +%Y%m%d%H%M%S)"
        if ! mv "$link" "$backup"; then
          echo "error: cannot back up $link -> $backup" >&2
          continue
        fi
        echo "backed up: $link -> $backup"
      else
        echo "skip: $link 은(는) 실제 파일/디렉토리라 덮어쓰지 않음 (--force 필요)" >&2
        continue
      fi
    fi

    # 개별 ln 실패는 다른 스킬 진행을 막지 않는다 (작업 22)
    if ! ln -s "$skill_dir" "$link"; then
      echo "error: cannot create link $link -> $skill_dir" >&2
      continue
    fi
    echo "linked: $link -> $skill_dir"
    linked_count=$((linked_count + 1))
    current_names+=("$name")
  done
done

# 어떤 스킬도 발견되지 않으면 명시적 경고 (작업 24)
# 단, 이전 manifest가 있어 stale 정리만 하고 끝날 수 있도록 prune 후 종료한다.
warn_empty=0
if [[ $linked_count -eq 0 ]]; then
  warn_empty=1
fi

# Stale 관리 링크 정리 (작업 20: manifest 기반).
# 원본에서 삭제된 스킬의 심링크가 도구 경로에 남아 있으면 (심링크일 때만) 제거한다.
# 사용자 소유 항목(실제 파일/디렉토리)은 절대 건드리지 않는다.
previous_names=()
if [[ -f "$MANIFEST" ]]; then
  while IFS= read -r line; do
    [[ -n "$line" ]] && previous_names+=("$line")
  done < "$MANIFEST"
fi

pruned_any=0
for prev in "${previous_names[@]:-}"; do
  # 현 세션에서 다시 설치된 스킬은 stale 아니다
  skip=0
  for cur in "${current_names[@]:-}"; do
    [[ "$cur" == "$prev" ]] && { skip=1; break; }
  done
  [[ "$skip" == "1" ]] && continue

  for target in "${TARGETS[@]}"; do
    link="$target/$prev"
    # 심링크가 아니면 (사용자가 파일/디렉토리로 교체했으면) 절대 보존
    [[ -L "$link" ]] || continue
    # 타깃 문자열이 SRC_DIR 하위였는지 확인.
    # readlink -f 가 빈 값을 돌려주거나 실패해도 보수적으로 처리.
    target_str="$(readlink -- "$link" 2>/dev/null || true)"
    # 절대경로 / 상대경로 모두 SRC_DIR 기준 prefix 매칭
    case "$target_str" in
      "$SRC_DIR"/*|/*"$SRC_DIR"/*) ;;  # 관리 대상
      *) continue ;;                    # 외부 링크는 보존
    esac
    if rm -f "$link"; then
      echo "pruned stale managed link: $link"
      pruned_any=1
    fi
  done
done

# 현재 설치된 스킬 이름을 manifest 로 갱신
: > "$MANIFEST"
for n in "${current_names[@]:-}"; do
  echo "$n" >> "$MANIFEST"
done

# 빈 경고는 prune 가 한 번도 일어나지 않은 경우에만 출력 후 비정상 종료
if [[ $warn_empty == 1 && $pruned_any == 0 ]]; then
  echo "warning: $SRC_DIR 에 SKILL.md 가 있는 스킬이 없습니다. 디렉토리 구조를 확인하세요." >&2
  exit 1
fi

echo
echo "완료. 다음 도구에서 사용 가능:"
echo "  - Claude Code, GitHub Copilot (VS Code): ~/.claude/skills"
echo "  - Codex: ~/.codex/skills"
echo "  - OpenCode: ~/.config/opencode/skills"
