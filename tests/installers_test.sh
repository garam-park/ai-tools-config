#!/usr/bin/env bash

set -euo pipefail
shopt -s nullglob
shopt -s inherit_errexit 2>/dev/null || true

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/ai-tools-config-tests.XXXXXX")"
PASSED=0

cleanup() {
  rm -rf "$TEST_ROOT"
}
trap cleanup EXIT

fail() {
  echo "not ok - $*" >&2
  exit 1
}

pass() {
  PASSED=$((PASSED + 1))
  echo "ok $PASSED - $*"
}

assert_file() {
  [[ -f "$1" ]] || fail "파일이 없습니다: $1"
}

assert_symlink() {
  [[ -L "$1" ]] || fail "심볼릭 링크가 아닙니다: $1"
}

assert_not_exists() {
  [[ ! -e "$1" && ! -L "$1" ]] || fail "항목이 남아 있습니다: $1"
}

assert_contains() {
  grep -qF "$2" "$1" || fail "$1 에 '$2'가 없습니다"
}

assert_glob_exists() {
  compgen -G "$1" >/dev/null || fail "패턴과 일치하는 파일이 없습니다: $1"
}

assert_no_glob() {
  if compgen -G "$1" >/dev/null; then
    fail "예상하지 않은 파일이 있습니다: $1"
  fi
}

make_skills_fixture() {
  local fixture="$1"
  mkdir -p "$fixture/paced-explainer"
  cp "$REPO_ROOT/install-skills.sh" "$fixture/install-skills.sh"
  printf '%s\n' '---' 'name: paced-explainer' 'description: test' '---' > "$fixture/paced-explainer/SKILL.md"
}

make_global_fixture() {
  local fixture="$1"
  mkdir -p "$fixture"
  cp "$REPO_ROOT/install-global-instructions.sh" "$fixture/install-global-instructions.sh"
  cp -R "$REPO_ROOT/global-instructions" "$fixture/global-instructions"
}

run_skills() {
  local fixture="$1"
  local home="$2"
  HOME="$home" XDG_STATE_HOME="$home/.state" bash "$fixture/install-skills.sh"
}

run_globals() {
  local fixture="$1"
  local home="$2"
  HOME="$home" bash "$fixture/install-global-instructions.sh"
}

run_skills_doctor() {
  local fixture="$1"
  local home="$2"
  HOME="$home" XDG_STATE_HOME="$home/.state" bash "$fixture/install-skills.sh" doctor
}

run_globals_doctor() {
  local fixture="$1"
  local home="$2"
  HOME="$home" bash "$fixture/install-global-instructions.sh" doctor
}

test_first_and_repeated_skill_install() {
  local fixture="$TEST_ROOT/first install/source"
  local home="$TEST_ROOT/first install/home"
  local link_source
  local target
  make_skills_fixture "$fixture"

  run_skills "$fixture" "$home" >/dev/null
  run_skills "$fixture" "$home" >/dev/null
  for target in .claude .agents; do
    assert_symlink "$home/$target/skills/paced-explainer"
    link_source="$(readlink "$home/$target/skills/paced-explainer")"
    [[ -f "$link_source/SKILL.md" && "$link_source" != */ ]] || fail "링크 타깃이 다릅니다: $target"
  done
  assert_file "$home/.state/ai-tools-config/install-skills.manifest"
  pass "최초/반복 스킬 설치와 공백 경로"
}

test_collision_protection_and_partial_progress() {
  local fixture="$TEST_ROOT/collision/source"
  local home="$TEST_ROOT/collision/home"
  make_skills_fixture "$fixture"
  mkdir -p "$home/.claude/skills/paced-explainer"
  printf 'keep\n' > "$home/.claude/skills/paced-explainer/LOCAL_ONLY"

  if run_skills "$fixture" "$home" >"$TEST_ROOT/collision.out" 2>&1; then
    fail "실제 디렉토리 충돌이 성공으로 보고되었습니다"
  fi
  assert_file "$home/.claude/skills/paced-explainer/LOCAL_ONLY"
  assert_symlink "$home/.agents/skills/paced-explainer"
  assert_contains "$TEST_ROOT/collision.out" "덮어쓰지 않습니다"
  pass "사용자 디렉토리 보호와 부분 실패 후 계속 진행"
}

test_wrong_symlink_replacement() {
  local fixture="$TEST_ROOT/wrong-link/source"
  local home="$TEST_ROOT/wrong-link/home"
  local link_source
  make_skills_fixture "$fixture"
  mkdir -p "$home/.claude/skills"
  ln -s "$TEST_ROOT/nowhere" "$home/.claude/skills/paced-explainer"

  run_skills "$fixture" "$home" >/dev/null
  link_source="$(readlink "$home/.claude/skills/paced-explainer")"
  [[ -f "$link_source/SKILL.md" ]] || fail "잘못된 링크가 교체되지 않았습니다"
  pass "잘못되거나 끊어진 기존 링크 교체"
}

test_stale_manifest_cleanup() {
  local fixture="$TEST_ROOT/stale/source"
  local home="$TEST_ROOT/stale/home"
  local target
  make_skills_fixture "$fixture"
  mkdir -p "$fixture/old-skill"
  printf '%s\n' '---' 'name: old-skill' 'description: test' '---' > "$fixture/old-skill/SKILL.md"
  run_skills "$fixture" "$home" >/dev/null

  rm -rf "$fixture/old-skill"
  run_skills "$fixture" "$home" >/dev/null
  for target in .claude .agents; do
    assert_not_exists "$home/$target/skills/old-skill"
  done

  printf 'corrupt manifest\n' > "$home/.state/ai-tools-config/install-skills.manifest"
  run_skills "$fixture" "$home" >/dev/null
  assert_contains "$home/.state/ai-tools-config/install-skills.manifest" "paced-explainer"
  pass "stale 관리 링크 정리와 손상 manifest 자가 복구"
}

test_legacy_target_cleanup() {
  local fixture="$TEST_ROOT/legacy-targets/source"
  local home="$TEST_ROOT/legacy-targets/home"
  local old_target
  make_skills_fixture "$fixture"
  mkdir -p "$home/.state/ai-tools-config"

  for old_target in "$home/.copilot/skills" "$home/.codex/skills" "$home/.config/opencode/skills"; do
    mkdir -p "$old_target"
    ln -s "$fixture/paced-explainer" "$old_target/paced-explainer"
    printf '%s\t%s\t%s\n' "$old_target" paced-explainer "$fixture/paced-explainer" >> "$home/.state/ai-tools-config/install-skills.manifest"
  done

  run_skills "$fixture" "$home" >/dev/null
  assert_not_exists "$home/.copilot/skills/paced-explainer"
  assert_not_exists "$home/.codex/skills/paced-explainer"
  assert_not_exists "$home/.config/opencode/skills/paced-explainer"
  assert_symlink "$home/.claude/skills/paced-explainer"
  assert_symlink "$home/.agents/skills/paced-explainer"
  pass "이전 도구별 관리 링크를 공통 경로로 이전"
}

test_stale_user_item_preserved() {
  local fixture="$TEST_ROOT/stale-user/source"
  local home="$TEST_ROOT/stale-user/home"
  make_skills_fixture "$fixture"
  mkdir -p "$fixture/old-skill"
  printf '%s\n' '---' 'name: old-skill' 'description: test' '---' > "$fixture/old-skill/SKILL.md"
  run_skills "$fixture" "$home" >/dev/null

  rm -f "$home/.claude/skills/old-skill"
  mkdir -p "$home/.claude/skills/old-skill"
  printf 'mine\n' > "$home/.claude/skills/old-skill/LOCAL_ONLY"
  rm -rf "$fixture/old-skill"
  run_skills "$fixture" "$home" >"$TEST_ROOT/stale-user.out" 2>&1
  assert_file "$home/.claude/skills/old-skill/LOCAL_ONLY"
  assert_contains "$TEST_ROOT/stale-user.out" "사용자 항목으로 바뀌어"
  pass "stale 링크 위치의 사용자 항목 보존"
}

test_empty_skill_source_errors() {
  local empty="$TEST_ROOT/empty/source"
  local nonskill="$TEST_ROOT/nonskill/source"
  mkdir -p "$empty" "$nonskill/random-dir"
  cp "$REPO_ROOT/install-skills.sh" "$empty/install-skills.sh"
  cp "$REPO_ROOT/install-skills.sh" "$nonskill/install-skills.sh"

  if HOME="$TEST_ROOT/empty/home" bash "$empty/install-skills.sh" >"$TEST_ROOT/empty.out" 2>&1; then
    fail "빈 원본이 성공으로 보고되었습니다"
  fi
  assert_contains "$TEST_ROOT/empty.out" "디렉토리가 없습니다"
  if HOME="$TEST_ROOT/nonskill/home" bash "$nonskill/install-skills.sh" >"$TEST_ROOT/nonskill.out" 2>&1; then
    fail "SKILL.md 없는 원본이 성공으로 보고되었습니다"
  fi
  assert_contains "$TEST_ROOT/nonskill.out" "SKILL.md가 있는 스킬이 없습니다"
  pass "빈 원본과 비스킬 원본의 명시적 오류"
}

test_target_mkdir_error() {
  local fixture="$TEST_ROOT/mkdir/source"
  local home="$TEST_ROOT/mkdir/home-as-file"
  make_skills_fixture "$fixture"
  printf 'not a directory\n' > "$home"
  if run_skills "$fixture" "$home" >"$TEST_ROOT/mkdir.out" 2>&1; then
    fail "대상 mkdir 실패가 성공으로 보고되었습니다"
  fi
  assert_contains "$TEST_ROOT/mkdir.out" "만들 수 없습니다"
  pass "대상 디렉토리 생성 실패의 명확한 오류"
}

test_global_first_repeat_and_backup() {
  local fixture="$TEST_ROOT/globals/source"
  local home="$TEST_ROOT/globals/home"
  make_global_fixture "$fixture"
  run_globals "$fixture" "$home" >/dev/null
  run_globals "$fixture" "$home" >/dev/null

  assert_contains "$home/.claude/CLAUDE.md" "AUTO-GENERATED-DO-NOT-EDIT"
  assert_contains "$home/.codex/AGENTS.md" "Codex 전용 지침"
  assert_contains "$home/.config/opencode/AGENTS.md" "OpenCode 전용 지침"
  assert_contains "$home/.claude/CLAUDE.md" "한국어로 대화해요."
  assert_contains "$home/.claude/CLAUDE.md" '사용자가 `/paced-explainer`를 입력하면'
  assert_contains "$home/.codex/AGENTS.md" '사용자가 `$스킬명` 형식으로 스킬을 지정하면'
  assert_contains "$home/.config/opencode/AGENTS.md" '`sisyphus` 에이전트를 기본값으로 사용해요.'
  assert_no_glob "$home/.claude/CLAUDE.md.bak.*"

  printf '내 지침\n' > "$home/.codex/AGENTS.md"
  run_globals "$fixture" "$home" >/dev/null
  assert_glob_exists "$home/.codex/AGENTS.md.bak.*"
  assert_contains "$home/.codex/AGENTS.md" "AUTO-GENERATED-DO-NOT-EDIT"
  assert_no_glob "$home/.claude/CLAUDE.md.??????"
  pass "글로벌 지침 최초 설치, 멱등 갱신, 사용자 파일 백업"
}

test_marker_position_independent() {
  local fixture="$TEST_ROOT/marker/source"
  local home="$TEST_ROOT/marker/home"
  make_global_fixture "$fixture"
  run_globals "$fixture" "$home" >/dev/null
  {
    printf '사용자 앞줄\n'
    cat "$home/.claude/CLAUDE.md"
  } > "$home/.claude/CLAUDE.md.prepend"
  mv "$home/.claude/CLAUDE.md.prepend" "$home/.claude/CLAUDE.md"
  run_globals "$fixture" "$home" >/dev/null
  assert_no_glob "$home/.claude/CLAUDE.md.bak.*"
  pass "파일 내 위치와 무관한 자동 생성 마커 판별"
}

test_global_symlink_targets() {
  local fixture="$TEST_ROOT/symlink/source"
  local home="$TEST_ROOT/symlink/home"
  local external="$TEST_ROOT/symlink/external/my-claude.md"
  make_global_fixture "$fixture"
  mkdir -p "$home/.claude" "$(dirname "$external")"
  printf '내 외부 설정\n' > "$external"
  ln -s "$external" "$home/.claude/CLAUDE.md"

  run_globals "$fixture" "$home" >/dev/null 2>&1
  assert_symlink "$home/.claude/CLAUDE.md"
  assert_contains "$external" "AUTO-GENERATED-DO-NOT-EDIT"
  assert_glob_exists "$external.bak.*"

  local dangling_home="$TEST_ROOT/dangling/home"
  mkdir -p "$dangling_home/.claude"
  ln -s "../external/new-claude.md" "$dangling_home/.claude/CLAUDE.md"
  run_globals "$fixture" "$dangling_home" >/dev/null 2>&1
  assert_symlink "$dangling_home/.claude/CLAUDE.md"
  assert_contains "$dangling_home/external/new-claude.md" "AUTO-GENERATED-DO-NOT-EDIT"
  pass "정상/끊어진 글로벌 지침 심볼릭 링크 보존"
}

test_skills_doctor() {
  local fixture="$TEST_ROOT/doctor-skills/source"
  local home="$TEST_ROOT/doctor-skills/home"
  make_skills_fixture "$fixture"

  if run_skills_doctor "$fixture" "$home" >"$TEST_ROOT/doctor-skills.before" 2>&1; then
    fail "설치 전 doctor가 성공으로 보고되었습니다"
  fi
  assert_contains "$TEST_ROOT/doctor-skills.before" "디렉토리가 없습니다"

  run_skills "$fixture" "$home" >/dev/null
  run_skills_doctor "$fixture" "$home" >"$TEST_ROOT/doctor-skills.ok" 2>&1
  assert_contains "$TEST_ROOT/doctor-skills.ok" "문제 없음"

  rm "$home/.claude/skills/paced-explainer"
  if run_skills_doctor "$fixture" "$home" >"$TEST_ROOT/doctor-skills.missing" 2>&1; then
    fail "링크 누락이 doctor에서 성공으로 보고되었습니다"
  fi
  assert_contains "$TEST_ROOT/doctor-skills.missing" "링크가 없습니다"

  ln -s "$TEST_ROOT/nowhere" "$home/.claude/skills/paced-explainer"
  if run_skills_doctor "$fixture" "$home" >"$TEST_ROOT/doctor-skills.wrong" 2>&1; then
    fail "잘못된 링크 타깃이 doctor에서 성공으로 보고되었습니다"
  fi
  assert_contains "$TEST_ROOT/doctor-skills.wrong" "다른 곳을 가리킵니다"

  run_skills "$fixture" "$home" >/dev/null
  mkdir -p "$fixture/ghost-skill"
  printf '%s\n' '---' 'name: ghost-skill' 'description: test' '---' > "$fixture/ghost-skill/SKILL.md"
  run_skills "$fixture" "$home" >/dev/null
  rm -rf "$fixture/ghost-skill"
  if run_skills_doctor "$fixture" "$home" >"$TEST_ROOT/doctor-skills.stale" 2>&1; then
    fail "stale 링크가 doctor에서 성공으로 보고되었습니다"
  fi
  assert_contains "$TEST_ROOT/doctor-skills.stale" "stale 링크"

  if HOME="$home" bash "$fixture/install-skills.sh" bogus >"$TEST_ROOT/doctor-skills.bogus" 2>&1; then
    fail "알 수 없는 인자가 성공으로 보고되었습니다"
  fi
  assert_contains "$TEST_ROOT/doctor-skills.bogus" "알 수 없는 인자"
  pass "skills doctor: 설치 전/후, 누락·오링크·stale 진단과 인자 검증"
}

test_globals_doctor() {
  local fixture="$TEST_ROOT/doctor-globals/source"
  local home="$TEST_ROOT/doctor-globals/home"
  make_global_fixture "$fixture"

  if run_globals_doctor "$fixture" "$home" >"$TEST_ROOT/doctor-globals.before" 2>&1; then
    fail "설치 전 doctor가 성공으로 보고되었습니다"
  fi
  assert_contains "$TEST_ROOT/doctor-globals.before" "파일이 없습니다"

  run_globals "$fixture" "$home" >/dev/null
  run_globals_doctor "$fixture" "$home" >"$TEST_ROOT/doctor-globals.ok" 2>&1
  assert_contains "$TEST_ROOT/doctor-globals.ok" "문제 없음"

  printf '추가 줄\n' >> "$home/.claude/CLAUDE.md"
  if run_globals_doctor "$fixture" "$home" >"$TEST_ROOT/doctor-globals.drift" 2>&1; then
    fail "내용 드리프트가 doctor에서 성공으로 보고되었습니다"
  fi
  assert_contains "$TEST_ROOT/doctor-globals.drift" "내용이 원본과 다릅니다"

  printf '내 지침\n' > "$home/.claude/CLAUDE.md"
  if run_globals_doctor "$fixture" "$home" >"$TEST_ROOT/doctor-globals.user" 2>&1; then
    fail "마커 없는 사용자 파일이 doctor에서 성공으로 보고되었습니다"
  fi
  assert_contains "$TEST_ROOT/doctor-globals.user" "자동 생성 마커가 없습니다"

  run_globals "$fixture" "$home" >/dev/null
  run_globals_doctor "$fixture" "$home" >"$TEST_ROOT/doctor-globals.fixed" 2>&1
  assert_contains "$TEST_ROOT/doctor-globals.fixed" "문제 없음"

  if HOME="$home" bash "$fixture/install-global-instructions.sh" bogus >"$TEST_ROOT/doctor-globals.bogus" 2>&1; then
    fail "알 수 없는 인자가 성공으로 보고되었습니다"
  fi
  assert_contains "$TEST_ROOT/doctor-globals.bogus" "사용법"
  pass "globals doctor: 설치 전/후, 드리프트·사용자 파일 진단과 인자 검증"
}

test_first_and_repeated_skill_install
test_collision_protection_and_partial_progress
test_wrong_symlink_replacement
test_stale_manifest_cleanup
test_legacy_target_cleanup
test_stale_user_item_preserved
test_empty_skill_source_errors
test_target_mkdir_error
test_global_first_repeat_and_backup
test_marker_position_independent
test_global_symlink_targets
test_skills_doctor
test_globals_doctor

echo "1..$PASSED"
