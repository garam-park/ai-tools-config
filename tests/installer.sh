#!/usr/bin/env bash
# tests/installer.sh
#
# install-skills.sh + install-global-instructions.sh 동작을 검증하는
# 순수 bash 테스트 러너. bats 같은 외부 의존 없이 실행 가능하다.
#
# 사용법:
#   bash tests/installer.sh
#
# 종료 코드: 모든 테스트 통과 시 0, 하나라도 실패 시 1.

set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"

# 원본 스크립트의 set -e 가 테스트 환경에서도 안전하도록 격리
PASS=0
FAIL=0
FAIL_NAMES=()

ok() { echo "  ok  - $*"; PASS=$((PASS + 1)); }
ko() { echo "  not ok - $*"; FAIL=$((FAIL + 1)); FAIL_NAMES+=("$*"); }

# 임시 홈/원본 디렉토리를 만들어 실제 사용자 $HOME 을 건드리지 않는다
make_workspace() {
  local tmp
  tmp="$(mktemp -d)"
  mkdir -p "$tmp/home" "$tmp/src"
  # install-skills.sh expects SRC_DIR/*/SKILL.md (script + skills at the
  # same level — the original documented flow). Place the real skill dir
  # next to install-skills.sh so SRC_DIR == repo root sees it directly.
  cp -r "$ROOT/skills/paced-explainer" "$tmp/src/paced-explainer"
  cp -r "$ROOT/global-instructions" "$tmp/src/global-instructions"
  cp "$ROOT/install-skills.sh" "$tmp/src/install-skills.sh"
  cp "$ROOT/install-global-instructions.sh" "$tmp/src/install-global-instructions.sh"
  echo "$tmp"
}

cleanup_workspace() {
  local ws="$1"
  [[ -n "$ws" && -d "$ws" ]] && rm -rf "$ws"
}

run_skills() {
  local ws="$1"
  ( cd "$ws/src" && HOME="$ws/home" bash "$ws/src/install-skills.sh" ) \
    >/dev/null 2>&1
  echo $?
}

run_global() {
  local ws="$1"
  ( cd "$ws/src" && HOME="$ws/home" bash "$ws/src/install-global-instructions.sh" ) \
    >/dev/null 2>&1
  echo $?
}

section() { echo; echo "==> $*"; }

# -----------------------------
# install-skills.sh 테스트
# -----------------------------
section "install-skills.sh"

# T01: 정상 설치 (멱등)
ws=$(make_workspace)
run_skills "$ws" >/dev/null
expected_link="$ws/home/.claude/skills/paced-explainer"
if [[ -L "$expected_link" ]] && readlink "$expected_link" | grep -q paced-explainer; then
  ok "정상 설치: 3개 TARGET 모두에 paced-explainer 심링크 생성"
else
  ko "정상 설치 실패 ($expected_link)"
fi
# 멱등성
run_skills "$ws" >/dev/null
if [[ -L "$expected_link" ]]; then
  ok "멱등성: 두 번째 실행 후에도 링크 유지"
else
  ko "멱등성 실패"
fi
cleanup_workspace "$ws"

# T02: 실제 디렉토리 보호 (작업 01)
ws=$(make_workspace)
mkdir -p "$ws/home/.claude/skills/paced-explainer"
touch "$ws/home/.claude/skills/paced-explainer/LOCAL_ONLY"
HOME="$ws/home" bash "$ws/src/install-skills.sh" >/dev/null 2>&1 || true
if [[ -f "$ws/home/.claude/skills/paced-explainer/LOCAL_ONLY" ]]; then
  ok "보호: 실제 디렉토리 안의 사용자 파일 보존 (LOCAL_ONLY)"
else
  ko "보호 실패: LOCAL_ONLY 가 삭제됨"
fi
if [[ ! -L "$ws/home/.claude/skills/paced-explainer" ]]; then
  ok "보호: 실제 디렉토리가 심링크로 교체되지 않음"
else
  ko "보호 실패: 실제 디렉토리가 심링크로 교체됨"
fi
cleanup_workspace "$ws"

# T03: --force 시 백업 후 교체
ws=$(make_workspace)
mkdir -p "$ws/home/.claude/skills/paced-explainer"
touch "$ws/home/.claude/skills/paced-explainer/LOCAL_ONLY"
HOME="$ws/home" bash "$ws/src/install-skills.sh" --force >/dev/null 2>&1 || true
if [[ -L "$ws/home/.claude/skills/paced-explainer" ]]; then
  ok "--force: 심링크로 교체됨"
else
  ko "--force 가 적용되지 않음"
fi
if compgen -G "$ws/home/.claude/skills/paced-explainer.bak.*" >/dev/null; then
  ok "--force: 백업 디렉토리 생성됨"
else
  ko "--force: 백업이 생성되지 않음"
fi
cleanup_workspace "$ws"

# T04: 빈 SRC_DIR 경고 (작업 24)
ws=$(make_workspace)
rm -rf "$ws/src/paced-explainer"
code=$(HOME="$ws/home" bash "$ws/src/install-skills.sh" 2>/dev/null; echo $?)
if [[ "$code" == "1" ]]; then
  ok "빈 SRC_DIR: exit 1 로 종료"
else
  ko "빈 SRC_DIR: 정상 종료 ($code)"
fi
cleanup_workspace "$ws"

# T05: SKILL.md 없는 디렉토리는 무시 (작업 14)
ws=$(make_workspace)
mkdir -p "$ws/src/random-dir"
touch "$ws/src/random.md"
HOME="$ws/home" bash "$ws/src/install-skills.sh" >/dev/null 2>&1 || true
if [[ -L "$ws/home/.claude/skills/paced-explainer" ]] \
   && [[ ! -e "$ws/home/.claude/skills/random-dir" ]]; then
  ok "필터: SKILL.md 없는 디렉토리는 무시됨"
else
  ko "필터 실패"
fi
cleanup_workspace "$ws"

# -----------------------------
# install-global-instructions.sh 테스트
# -----------------------------
section "install-global-instructions.sh"

# T10: 첫 실행 (신규 파일 생성)
ws=$(make_workspace)
run_global "$ws" >/dev/null
dest="$ws/home/.claude/CLAUDE.md"
if [[ -f "$dest" ]] && head -1 "$dest" | grep -q "AUTO-GENERATED-DO-NOT-EDIT"; then
  ok "신규: AUTO-GENERATED-DO-NOT-EDIT 마커로 시작"
else
  ko "신규 파일 마커 없음"
fi
if grep -q "common" "$dest" && grep -q "트리거" "$dest"; then
  ok "신규: common + claude 델타 결합"
else
  ko "결합 실패"
fi
cleanup_workspace "$ws"

# T11: 사용자 파일 백업 (작업 02)
ws=$(make_workspace)
mkdir -p "$ws/home/.claude"
echo "내 손수 작성한 지침" > "$ws/home/.claude/CLAUDE.md"
run_global "$ws" >/dev/null
if compgen -G "$ws/home/.claude/CLAUDE.md.bak.*" >/dev/null; then
  ok "백업: 사용자 파일 .bak.<ts> 생성"
else
  ko "백업 실패"
fi
if head -1 "$ws/home/.claude/CLAUDE.md" | grep -q "AUTO-GENERATED-DO-NOT-EDIT"; then
  ok "백업 후 덮어쓰기: 새 파일은 AUTO-GENERATED 마커 보유"
else
  ko "백업 후 마커 미부여"
fi
cleanup_workspace "$ws"

# T12: 자동 관리 파일은 백업 없이 갱신 (작업 02)
ws=$(make_workspace)
run_global "$ws" >/dev/null
before_lines=$(wc -l <"$ws/home/.claude/CLAUDE.md")
# 자동 생성된 파일을 다시 동기화해도 백업이 안 만들어져야 함
backup_count_before=$(compgen -G "$ws/home/.claude/CLAUDE.md.bak.*" | wc -l)
run_global "$ws" >/dev/null
backup_count_after=$(compgen -G "$ws/home/.claude/CLAUDE.md.bak.*" | wc -l)
if [[ "$backup_count_before" == "0" && "$backup_count_after" == "0" ]]; then
  ok "자동 관리 파일은 재실행 시 백업 미생성"
else
  ko "자동 관리 파일에서 불필요한 백업이 생성됨 (before=$backup_count_before after=$backup_count_after)"
fi
cleanup_workspace "$ws"

# T13: 심볼릭 링크 dest 처리 (작업 23)
ws=$(make_workspace)
mkdir -p "$ws/home/.claude" "$ws/external"
echo "external content" > "$ws/external/my-claude.md"
ln -s "$ws/external/my-claude.md" "$ws/home/.claude/CLAUDE.md"
run_global "$ws" >/dev/null
if [[ -L "$ws/home/.claude/CLAUDE.md" ]]; then
  ok "심링크 보존: 사용자 링크 자체는 살아있음"
else
  ko "사용자 심링크가 파일로 교체됨"
fi
if head -1 "$ws/external/my-claude.md" | grep -q "AUTO-GENERATED-DO-NOT-EDIT"; then
  ok "심링크 타깃에 동기화: 외부 파일에 마커 부여"
else
  ko "심링크 타깃에 동기화 안됨"
fi
cleanup_workspace "$ws"

# T20: manifest 기반 stale link 정리 (작업 20)
# 두 개의 스킬로 workspace를 구성: 하나는 남고, 하나는 삭제되어 정리 대상이 되어야 한다.
# install-skills.sh 의 SRC_DIR glob 은 /*/ 이므로 스킬 디렉토리는 SRC_DIR 직속이어야 한다.
ws=$(mktemp -d)
mkdir -p "$ws/home" "$ws/src/keepme" "$ws/src/oldone"
touch "$ws/src/keepme/SKILL.md" "$ws/src/oldone/SKILL.md"
cp "$ROOT/install-skills.sh" "$ws/src/install-skills.sh"
cp "$ROOT/install-global-instructions.sh" "$ws/src/install-global-instructions.sh"
mkdir -p "$ws/src/global-instructions"; touch "$ws/src/global-instructions/common.md"

# 첫 실행: 두 스킬 모두 설치
( cd "$ws/src" && HOME="$ws/home" bash "$ws/src/install-skills.sh" ) >/dev/null 2>&1

# 원본에서 oldone 디렉토리 제거 후 두 번째 실행
rm -rf "$ws/src/oldone"
( cd "$ws/src" && HOME="$ws/home" bash "$ws/src/install-skills.sh" ) >/dev/null 2>&1

# keepme는 살아있고 oldone은 정리되어야 한다
if [[ ! -L "$ws/home/.claude/skills/oldone" ]] && [[ -L "$ws/home/.claude/skills/keepme" ]]; then
  ok "stale: 원본에서 삭제된 oldone 링크만 정리, keepme 보존"
else
  ko "stale 정리 실패 (oldone=$( [[ -L "$ws/home/.claude/skills/oldone" ]] && echo link || echo none), keepme=$( [[ -L "$ws/home/.claude/skills/keepme" ]] && echo link || echo none ))"
fi
cleanup_workspace "$ws"

# -----------------------------
echo
if [[ "$FAIL" == "0" ]]; then
  echo "PASS: $PASS tests"
  exit 0
else
  echo "FAIL: $FAIL / $((PASS+FAIL))"
  for n in "${FAIL_NAMES[@]}"; do echo "  - $n"; done
  exit 1
fi
