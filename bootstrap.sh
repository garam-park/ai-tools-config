#!/usr/bin/env bash
# bootstrap.sh
#
# 새 머신 설정을 한 번에 수행한다:
#   1) ./install-skills.sh install [--force]
#   2) ./install-global-instructions.sh install
#   3) 두 스크립트의 doctor로 설치 상태 확인 (문제 시 exit 1)
#
# 사용법:
#   ./bootstrap.sh [--force]   # --force는 install-skills.sh 에만 전달된다

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  echo "사용법: $0 [--force]" >&2
}

FORCE=0
if [[ "${1:-}" == "--force" ]]; then
  FORCE=1
  shift
fi

if [[ $# -gt 0 ]]; then
  echo "error: 알 수 없는 인자입니다: $1" >&2
  usage
  exit 2
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
