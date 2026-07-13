#!/usr/bin/env bash
# install-skills.sh
#
# 원본: ~/.local/share/skills/<name>/
# 이 스크립트와 같은 폴더에 있는 스킬을 각 도구의 개인용 경로에 연결한다.
# 멱등성 보장: 여러 번 실행해도 같은 결과.
#
# 새 머신에서:
#   1) skills/의 내용과 이 스크립트를 ~/.local/share/skills/ 아래에 둔다
#   2) chmod +x install-skills.sh && ./install-skills.sh

set -euo pipefail
shopt -s nullglob
shopt -s inherit_errexit 2>/dev/null || true

# 원본 폴더 (이 스크립트가 있는 폴더)
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/ai-tools-config"
MANIFEST="$STATE_DIR/install-skills.manifest"

# 도구별 개인 스킬 경로. Copilot은 ~/.claude/skills도 읽지만 전용 표준 경로를 쓴다.
TARGETS=(
  "$HOME/.claude/skills"             # Claude Code
  "$HOME/.copilot/skills"            # GitHub Copilot
  "$HOME/.codex/skills"              # Codex
  "$HOME/.config/opencode/skills"    # OpenCode
)

warn() {
  echo "warning: $*" >&2
}

error() {
  echo "error: $*" >&2
}

is_known_target() {
  local candidate="$1"
  local target

  for target in "${TARGETS[@]}"; do
    [[ "$candidate" == "$target" ]] && return 0
  done
  return 1
}

if [[ ! -d "$SRC_DIR" ]]; then
  error "원본 폴더를 찾을 수 없습니다: $SRC_DIR"
  exit 1
fi

directories=("$SRC_DIR"/*/)
if [[ ${#directories[@]} -eq 0 ]]; then
  warn "$SRC_DIR 에 디렉토리가 없습니다. 스킬 원본 위치를 확인하세요."
  exit 1
fi

skill_dirs=()
for skill_dir in "${directories[@]}"; do
  skill_dir="${skill_dir%/}"
  [[ -f "$skill_dir/SKILL.md" ]] || continue
  skill_dirs+=("$skill_dir")
done

if [[ ${#skill_dirs[@]} -eq 0 ]]; then
  warn "$SRC_DIR 에 SKILL.md가 있는 스킬이 없습니다. 디렉토리 구조를 확인하세요."
  exit 1
fi

for target in "${TARGETS[@]}"; do
  if ! mkdir -p "$target"; then
    error "$target 을(를) 만들 수 없습니다. 권한 또는 상위 경로를 확인하세요."
    exit 1
  fi
done

# 이전 실행에서 관리한 링크 중 이제 원본에 없는 것만 안전하게 정리한다.
if [[ -f "$MANIFEST" ]]; then
  while IFS=$'\t' read -r old_target old_name old_source extra; do
    [[ -n "$old_target" && -n "$old_name" && -n "$old_source" && -z "${extra:-}" ]] || continue

    old_link="$old_target/$old_name"
    still_desired=0
    for skill_dir in "${skill_dirs[@]}"; do
      if is_known_target "$old_target" && [[ "$old_name" == "$(basename "$skill_dir")" ]]; then
        still_desired=1
        break
      fi
    done
    [[ "$still_desired" -eq 0 ]] || continue

    if [[ -L "$old_link" && "$(readlink "$old_link")" == "$old_source" ]]; then
      if rm -f "$old_link"; then
        echo "removed stale link: $old_link"
      else
        warn "오래된 관리 링크를 제거할 수 없습니다: $old_link"
      fi
    elif [[ -e "$old_link" || -L "$old_link" ]]; then
      warn "$old_link 이(가) 사용자 항목으로 바뀌어 오래된 링크 정리에서 제외합니다."
    fi
  done < "$MANIFEST"
fi

failures=0
for target in "${TARGETS[@]}"; do
  for skill_dir in "${skill_dirs[@]}"; do
    name="$(basename "$skill_dir")"
    link="$target/$name"

    if [[ -L "$link" ]]; then
      if ! rm -f "$link"; then
        error "기존 링크를 제거할 수 없습니다: $link"
        failures=$((failures + 1))
        continue
      fi
    elif [[ -e "$link" ]]; then
      warn "$link 은(는) 실제 파일/디렉토리라 덮어쓰지 않습니다."
      failures=$((failures + 1))
      continue
    fi

    if ! ln -s "$skill_dir" "$link"; then
      error "링크를 만들 수 없습니다: $link -> $skill_dir"
      failures=$((failures + 1))
      continue
    fi
    echo "linked: $link -> $skill_dir"
  done
done

# 실제로 원하는 원본을 가리키는 링크만 다음 실행의 관리 대상으로 기록한다.
if ! mkdir -p "$STATE_DIR"; then
  error "manifest 디렉토리를 만들 수 없습니다: $STATE_DIR"
  exit 1
fi
manifest_tmp="$(mktemp "$MANIFEST.XXXXXX")"
trap 'rm -f "${manifest_tmp:-}"' EXIT
{
  for target in "${TARGETS[@]}"; do
    for skill_dir in "${skill_dirs[@]}"; do
      name="$(basename "$skill_dir")"
      link="$target/$name"
      if [[ -L "$link" && "$(readlink "$link")" == "$skill_dir" ]]; then
        printf '%s\t%s\t%s\n' "$target" "$name" "$skill_dir"
      fi
    done
  done
} > "$manifest_tmp"
mv "$manifest_tmp" "$MANIFEST"
manifest_tmp=""

echo
echo "완료. 다음 도구에서 사용 가능:"
echo "  - Claude Code: ~/.claude/skills"
echo "  - GitHub Copilot: ~/.copilot/skills"
echo "  - Codex: ~/.codex/skills"
echo "  - OpenCode: ~/.config/opencode/skills"

if [[ "$failures" -gt 0 ]]; then
  error "$failures개 항목을 설치하지 못했습니다. 위 경고를 확인하세요."
  exit 1
fi
