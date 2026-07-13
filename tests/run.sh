#!/usr/bin/env bash
# tests/run.sh
#
# install-skills.sh / install-global-instructions.sh 통합 테스트.
# 실제 홈 디렉토리를 절대 건드리지 않고, 임시 HOME/원본에서만 설치 동작을 검증한다.
#
# 실행: bash tests/run.sh
# 종료 코드: 실패가 하나라도 있으면 1.

set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS="$REPO/install-skills.sh"
GLOBAL="$REPO/install-global-instructions.sh"

pass=0
fail=0
ok()   { printf '  ok    %s\n' "$1"; pass=$((pass + 1)); }
ng()   { printf '  FAIL  %s\n' "$1"; fail=$((fail + 1)); }

# 정리할 임시 디렉토리 추적
_tmpdirs=()
sandbox() { local d; d="$(mktemp -d)"; _tmpdirs+=("$d"); printf '%s' "$d"; }
cleanup() { local d; for d in "${_tmpdirs[@]:-}"; do [[ -n "$d" ]] && rm -rf "$d"; done; }
trap cleanup EXIT

# 심볼릭 링크 지원 확인 (Windows Git Bash 등에서는 스킵)
_probe="$(mktemp -d)"
ln -s "$_probe" "$_probe/link" 2>/dev/null || true
if [[ ! -L "$_probe/link" ]]; then
  echo "SKIP: 이 환경은 심볼릭 링크를 지원하지 않습니다 (WSL / Linux / macOS 에서 실행하세요)."
  rm -rf "$_probe"
  exit 0
fi
rm -rf "$_probe"

echo "== install-skills.sh =="

# 1. 최초 설치: 4개 경로에 링크
S="$(sandbox)"; cp "$SKILLS" "$S/"; mkdir -p "$S/demo"; echo x > "$S/demo/SKILL.md"
HOME="$S/home" bash "$S/install-skills.sh" >/dev/null 2>&1
if [[ -L "$S/home/.claude/skills/demo" && -L "$S/home/.copilot/skills/demo" \
   && -L "$S/home/.codex/skills/demo" && -L "$S/home/.config/opencode/skills/demo" ]]; then
  ok "최초 설치: 4개 경로에 링크 생성"
else
  ng "최초 설치: 4개 경로에 링크 생성"
fi

# 2. 반복 설치(멱등성)
HOME="$S/home" bash "$S/install-skills.sh" >/dev/null 2>&1
if [[ -L "$S/home/.claude/skills/demo" ]]; then ok "반복 설치: 멱등 유지"; else ng "반복 설치: 멱등 유지"; fi

# 3. 실제 디렉토리 충돌 보호
rm -f "$S/home/.claude/skills/demo"; mkdir -p "$S/home/.claude/skills/demo"; echo keep > "$S/home/.claude/skills/demo/USER"
HOME="$S/home" bash "$S/install-skills.sh" >/dev/null 2>&1
if [[ -f "$S/home/.claude/skills/demo/USER" ]]; then ok "충돌 보호: 사용자 디렉토리 보존"; else ng "충돌 보호: 사용자 디렉토리 보존"; fi

# 4. --force: 백업 후 링크로 교체
HOME="$S/home" bash "$S/install-skills.sh" --force >/dev/null 2>&1
if [[ -L "$S/home/.claude/skills/demo" ]]; then ok "--force: 링크로 교체"; else ng "--force: 링크로 교체"; fi
if ls "$S"/home/.claude/skills/demo.bak.* >/dev/null 2>&1; then ok "--force: 백업 생성"; else ng "--force: 백업 생성"; fi

# 5. 잘못된(깨진) 링크 교체
rm -f "$S/home/.codex/skills/demo"; ln -s "$S/does-not-exist" "$S/home/.codex/skills/demo"
HOME="$S/home" bash "$S/install-skills.sh" >/dev/null 2>&1
if [[ "$(readlink "$S/home/.codex/skills/demo")" == "$S/demo" ]]; then ok "깨진 링크 교체"; else ng "깨진 링크 교체"; fi

# 6. 원본 스킬 삭제 후 stale link 정리 (task 20)
mkdir -p "$S/temp2"; echo x > "$S/temp2/SKILL.md"
HOME="$S/home" bash "$S/install-skills.sh" >/dev/null 2>&1
rm -rf "$S/temp2"
HOME="$S/home" bash "$S/install-skills.sh" >/dev/null 2>&1
if [[ ! -e "$S/home/.codex/skills/temp2" && ! -e "$S/home/.claude/skills/temp2" ]]; then
  ok "stale 정리: 사라진 스킬 링크 제거"
else
  ng "stale 정리: 사라진 스킬 링크 제거"
fi

# 7. 경로에 공백이 있는 경우
SP="$(sandbox)/with space"; mkdir -p "$SP"; cp "$SKILLS" "$SP/"; mkdir -p "$SP/demo"; echo x > "$SP/demo/SKILL.md"
HOME="$SP/home" bash "$SP/install-skills.sh" >/dev/null 2>&1
if [[ -L "$SP/home/.claude/skills/demo" ]]; then ok "공백 경로: 링크 생성"; else ng "공백 경로: 링크 생성"; fi

# 8. 빈 원본: 명시적 실패
SE="$(sandbox)"; cp "$SKILLS" "$SE/"
if HOME="$SE/home" bash "$SE/install-skills.sh" >/dev/null 2>&1; then
  ng "빈 원본: exit 1 로 실패해야 함"
else
  ok "빈 원본: exit 1 로 실패"
fi

echo "== install-global-instructions.sh =="

# 9. 마커 없는 사용자 파일 백업 + 마커 삽입 (task 02)
G="$(sandbox)"; mkdir -p "$G/home/.claude"; echo "내 손으로 쓴 지침" > "$G/home/.claude/CLAUDE.md"
HOME="$G/home" bash "$GLOBAL" >/dev/null 2>&1
if ls "$G"/home/.claude/CLAUDE.md.bak.* >/dev/null 2>&1; then ok "사용자 파일 백업 생성"; else ng "사용자 파일 백업 생성"; fi
if head -1 "$G/home/.claude/CLAUDE.md" | grep -q AUTO-GENERATED; then ok "동기화 후 마커 존재"; else ng "동기화 후 마커 존재"; fi

# 10. 마커 있는 파일 재실행: 추가 백업 없음(멱등)
before="$(ls "$G"/home/.claude/CLAUDE.md.bak.* 2>/dev/null | wc -l)"
HOME="$G/home" bash "$GLOBAL" >/dev/null 2>&1
after="$(ls "$G"/home/.claude/CLAUDE.md.bak.* 2>/dev/null | wc -l)"
if [[ "$before" == "$after" ]]; then ok "마커 있는 파일: 재실행 시 추가 백업 없음"; else ng "마커 있는 파일: 재실행 시 추가 백업 없음"; fi

# 11. 심볼릭 링크 dest 보존 + 타깃에 동기화 (task 23)
G2="$(sandbox)"; mkdir -p "$G2/home/.claude"; echo "외부 설정" > "$G2/external.md"
ln -s "$G2/external.md" "$G2/home/.claude/CLAUDE.md"
HOME="$G2/home" bash "$GLOBAL" >/dev/null 2>&1
if [[ -L "$G2/home/.claude/CLAUDE.md" ]]; then ok "심링크 dest: 링크 자체 보존"; else ng "심링크 dest: 링크 자체 보존"; fi
if head -1 "$G2/external.md" | grep -q AUTO-GENERATED; then ok "심링크 dest: 타깃 파일에 동기화"; else ng "심링크 dest: 타깃 파일에 동기화"; fi

# 12. 공백 있는 HOME 경로
GS="$(sandbox)/home dir"; mkdir -p "$GS/.claude"
HOME="$GS" bash "$GLOBAL" >/dev/null 2>&1
if head -1 "$GS/.claude/CLAUDE.md" | grep -q AUTO-GENERATED; then ok "공백 HOME: 동기화 성공"; else ng "공백 HOME: 동기화 성공"; fi

echo "== 정적 검사 =="

# 13. 두 스크립트 모두 안전 옵션 선언
for s in "$SKILLS" "$GLOBAL"; do
  n="$(basename "$s")"
  if grep -q 'set -euo pipefail' "$s"; then ok "$n: set -euo pipefail"; else ng "$n: set -euo pipefail"; fi
  if grep -q 'inherit_errexit' "$s"; then ok "$n: inherit_errexit"; else ng "$n: inherit_errexit"; fi
done

echo
echo "결과: ${pass} 통과, ${fail} 실패"
[[ "$fail" -eq 0 ]]
