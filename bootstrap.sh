#!/usr/bin/env bash
# bootstrap.sh
#
# 새 머신 설정을 한 번에 수행한다:
#   install:
#     1) ./install-skills.sh install [--force]
#     2) ./install-global-instructions.sh install
#     3) 두 스크립트의 doctor로 설치 상태 확인 (문제 시 exit 1)
#   uninstall:
#     1) ./install-skills.sh uninstall
#     2) ./install-global-instructions.sh uninstall
#
# 사용법:
#   ./bootstrap.sh [install] [--force]   # --force는 install-skills.sh 에만 전달된다
#   ./bootstrap.sh uninstall

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  echo "사용법: $0 [install [--force] | uninstall]" >&2
}

CMD="install"
case "${1:-}" in
  "") ;;
  install|uninstall)
    CMD="$1"
    shift
    ;;
esac

FORCE=0
if [[ "${1:-}" == "--force" ]]; then
  if [[ "$CMD" != "install" ]]; then
    echo "error: --force는 install에서만 사용할 수 있습니다." >&2
    usage
    exit 2
  fi
  FORCE=1
  shift
fi

if [[ $# -gt 0 ]]; then
  echo "error: 알 수 없는 인자입니다: $1" >&2
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

if [[ "$FORCE" == "1" ]]; then
  bash "$DIR/install-skills.sh" install --force
else
  bash "$DIR/install-skills.sh" install
fi
bash "$DIR/install-global-instructions.sh" install
bash "$DIR/install-skills.sh" doctor
bash "$DIR/install-global-instructions.sh" doctor

echo
echo "bootstrap 완료: 설치와 doctor 검사를 모두 통과했습니다."
