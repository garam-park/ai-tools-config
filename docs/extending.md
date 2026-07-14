# 확장 가이드

새 스킬, 새 도구 타깃, 새 글로벌 지침 델타를 추가하는 방법을 정리한다.

## 새 스킬 추가

> 별도 `templates/` 디렉터리는 두지 않는다. 스켈레톤이 아래 두 코드블록으로 충분하고, 특히 `skills/` 안에 템플릿 폴더를 두면 설치기가 `SKILL.md`가 있는 모든 폴더를 실제 스킬로 설치하기 때문이다.

1. `skills/<name>/SKILL.md` 작성:

   ```markdown
   ---
   name: <name>
   description: 무엇을 하는 스킬인지 + 어떤 상황/키워드에서 트리거되는지 한두 문장.
   ---

   # <Skill Title>

   ## Purpose
   (이 스킬이 해결하는 문제)

   ## Triggers
   (명시 호출: /<name>, $<name> · 자동 트리거 조건)

   ## Steps
   (도구 중립적으로 서술 — 특정 도구의 설치 경로나 전용 기능을 가정하지 않는다)
   ```

2. Codex UI 메타데이터 `skills/<name>/agents/codex.yaml` 작성 (선택이지만 관례상 모든 스킬이 가짐):

   ```yaml
   interface:
     display_name: "짧은 한글 이름"
     short_description: "한 줄 설명"
     default_prompt: "$<name>를 사용해서 ..."
   ```

3. 리포 루트에서 재실행·확인:

   ```bash
   ./install-skills.sh
   ./install-skills.sh doctor
   ```

   `install-skills.sh`는 `SKILL.md`가 있는 폴더만 원본 스킬로 인식한다.

### 이름 규칙

- `inp-` 접두사는 Innopam 전용 작업·PR 워크플로(`TSK-*`)에만 사용한다. 범용 스킬과 이름이 충돌하지 않게 하기 위한 네임스페이스다.
- 참고: CI의 `agents-integrity` 검사는 현재 `skills/paced-explainer/agents/codex.yaml`만 확인한다. 전 스킬 루프 검사로 강화하는 것이 후속 작업 후보다.

## 새 도구 타깃 추가 (스킬 설치 경로)

1. `install-skills.sh`의 `TARGETS` 배열에 경로 추가 — doctor·stale 정리 로직은 배열을 순회하므로 자동 반영된다:

   ```bash
   TARGETS=(
     "$HOME/.claude/skills"    # Claude Code
     "$HOME/.agents/skills"    # Codex, GitHub Copilot, OpenCode
     # "$HOME/.newtool/skills" # 새 도구 (공식 문서로 경로 검증 후 추가)
   )
   ```

2. `tests/installers_test.sh` 갱신 — 대상 경로가 하드코딩된 곳:
   - `for target in .claude .agents` 루프 2곳 (최초 설치 테스트, stale 정리 테스트)
   - 개별 `assert_symlink "$home/.claude/..."` / `"$home/.agents/..."` 단언들
3. 공식 문서로 경로를 검증하고 [platform-mapping.md](platform-mapping.md)의 표와 외부 문서 링크를 갱신한다.

## 새 글로벌 지침 델타 추가 (새 도구의 지침 파일)

1. `global-instructions/<tool>.md` 생성 (도구 전용 규칙만 — 공통 규칙은 `common.md`에).
2. `install-global-instructions.sh`의 `TARGETS` 배열에 `"대상 파일 경로|소스 파일 이름"` 항목 추가:

   ```bash
   declare -a TARGETS=(
     "$HOME/.claude/CLAUDE.md|claude.md"
     "$HOME/.codex/AGENTS.md|codex.md"
     "$HOME/.config/opencode/AGENTS.md|opencode.md"
     # "$HOME/.newtool/INSTRUCTIONS.md|newtool.md"
   )
   ```

3. `tests/installers_test.sh`의 `test_global_first_repeat_and_backup`에 기존 스타일대로 `assert_contains` 단언 추가 (마커 + 델타 고유 문구).
4. [platform-mapping.md](platform-mapping.md)의 글로벌 지침 표 갱신.

주의: `global-instructions/*.md`의 기존 본문 문구는 테스트가 문자열로 단언하고 있으므로, 수정 시 `tests/installers_test.sh`의 해당 `assert_contains`도 함께 갱신해야 한다.

## 문서 갱신 체크리스트

구조가 바뀌면 다음을 함께 갱신한다.

- `README.md`의 구성 트리 — `git ls-files | cut -d/ -f1-2 | sort -u` 결과와 대조
- `docs/platform-mapping.md`의 매핑 표
- 스크립트를 추가·개명했으면 `.github/workflows/*.yml`의 `additional_files`와 `.github/MERGE_REQUIREMENTS.md`의 shellcheck 명령
