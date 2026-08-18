#!/usr/bin/env bash
# bootstrap.sh
#
# 새 머신 설정을 한 번에 수행한다:
#   install:
#     1) ./install-skills.sh install [--force] [--all] [스킬...]
#     2) ./install-global-instructions.sh install
#     3) 두 스크립트의 doctor로 설치 상태 확인 (문제 시 exit 1)
#   uninstall:
#     1) ./install-skills.sh uninstall
#     2) ./install-global-instructions.sh uninstall
#
# 사용법:
#   ./bootstrap.sh [install] [--force] [--all] [스킬...]
#     --force, --all, 스킬 이름은 install-skills.sh 에만 전달된다.
#     스킬 이름을 주면 그 스킬만 설치하고, 선택은 다음 실행에서도 유지된다.
#   ./bootstrap.sh uninstall

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  echo "사용법: $0 [install [--force] [--all] [스킬...] | uninstall]" >&2
}

CMD="install"
case "${1:-}" in
  "") ;;
  install|uninstall)
    CMD="$1"
    shift
    ;;
esac

# --force, --all, 스킬 이름은 해석하지 않고 install-skills.sh 로 넘긴다.
skill_args=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --force|--all)
      skill_args+=("$1")
      ;;
    -*)
      echo "error: 알 수 없는 인자입니다: $1" >&2
      usage
      exit 2
      ;;
    *)
      skill_args+=("$1")
      ;;
  esac
  shift
done

if [[ "$CMD" != "install" && ${#skill_args[@]} -gt 0 ]]; then
  echo "error: uninstall에는 --force, --all, 스킬 이름을 쓸 수 없습니다." >&2
  usage
  exit 2
fi

if [[ "$CMD" == "uninstall" ]]; then
  bash "$DIR/install-skills.sh" uninstall
  bash "$DIR/install-global-instructions.sh" uninstall
  echo
  echo "bootstrap uninstall 완료: 관리 항목 삭제를 마쳤습니다."
  exit 0
fi

bash "$DIR/install-skills.sh" install ${skill_args[@]+"${skill_args[@]}"}
bash "$DIR/install-global-instructions.sh" install
# doctor는 인자 없이 실행한다. 설치기가 기록한 선택 상태를 그대로 읽어 판정한다.
bash "$DIR/install-skills.sh" doctor
bash "$DIR/install-global-instructions.sh" doctor

echo
echo "bootstrap 완료: 설치와 doctor 검사를 모두 통과했습니다."
