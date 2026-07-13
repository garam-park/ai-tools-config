#!/usr/bin/env bash
# install-skills.sh
#
# 원본: ~/.local/share/skills/<name>/
# 각 도구의 개인용 스킬 경로에 심볼릭 링크를 만들어 동기화한다.
# 멱등성 보장: 여러 번 실행해도 같은 결과.
#
# 새 머신에서:
#   1) 이 스크립트와 paced-explainer/ 폴더를 ~/.local/share/skills/ 아래에 둔다
#   2) chmod +x install-skills.sh && ./install-skills.sh

set -euo pipefail

# 원본 폴더 (이 스크립트가 있는 곳의 부모)
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -d "$SRC_DIR" ]]; then
  echo "원본 폴더를 찾을 수 없습니다: $SRC_DIR" >&2
  exit 1
fi

# 동기화 대상 도구들의 개인용 스킬 경로
TARGETS=(
  "$HOME/.claude/skills"             # Claude Code + GitHub Copilot (VS Code)
  "$HOME/.codex/skills"              # Codex
  "$HOME/.config/opencode/skills"    # OpenCode
)

# 각 대상 디렉토리 준비 + 모든 스킬에 대해 심볼릭 링크 보장
for target in "${TARGETS[@]}"; do
  mkdir -p "$target"
  for skill_dir in "$SRC_DIR"/*/; do
    [[ "$(basename "$skill_dir")" == "install-skills.sh" ]] && continue
    name="$(basename "$skill_dir")"
    link="$target/$name"

    # 기존 항목 제거 (파일/링크/디렉토리 모두)
    rm -rf "$link"
    ln -s "$skill_dir" "$link"
    echo "linked: $link -> $skill_dir"
  done
done

echo
echo "완료. 다음 도구에서 사용 가능:"
echo "  - Claude Code, GitHub Copilot (VS Code): ~/.claude/skills"
echo "  - Codex: ~/.codex/skills"
echo "  - OpenCode: ~/.config/opencode/skills"