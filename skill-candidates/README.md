# 스킬 통합 후보

로컬 사용자 스킬 경로에서 수집한 검토용 원본이다. 아직 유지·수정·통합·삭제 여부를 결정하지 않았다.

이 디렉터리는 배포 대상인 `skills/` 밖에 있으므로 `install-skills.sh`와 README의 `rsync skills/` 절차에 포함되지 않는다. 검토가 끝난 스킬만 `skills/<name>/`으로 이동한다.

## Codex 경로에서 가져온 후보

원본 위치: `~/.codex/skills/`

- `analyze-task`
- `create-pr`
- `end-chat`
- `gc-onboard`
- `gc-resolve-context`
- `gc-update-global-context`
- `handle-pr`
- `hatch-pet`
- `pr-review`
- `spec-task`
- `start-task`
- `start-task-worktree`

## Claude 경로에서 가져온 후보

원본 위치: `~/.claude/skills/`

- `graphify`
- `obsidian-docs`

## 검토 완료

- `ask-step-by-step` — **폐기**. 한 번에 질문 하나만 다루는 핵심 규칙이 `paced-explainer`와 중복되고, 모든 질문을 여러 턴으로 나누는 자동 트리거 및 Claude 전용 `AskUserQuestion` 표현이 공통 스킬에 적합하지 않다. 로컬 원본은 보존한다.
- `multi-agent-decide` — **폐기**. 일반적인 결정에도 다수 에이전트의 2회 토론을 자동 실행해 비용과 지연이 크고, Claude 전용 도구 및 폐기된 `ask-step-by-step`에 의존한다. 필요한 멀티에이전트 절차는 목적별 스킬에서 선택적으로 다룬다. 로컬 원본은 보존한다.

## 제외한 항목

- `paced-explainer`: 이미 `skills/`에서 관리 중이다.
- `.codex/skills/.system`: Codex 시스템 제공 스킬이다.
- `paperclip*`, `para-memory-files`, `frontend-design--*`: 외부 패키지나 런타임을 가리키는 심볼릭 링크라서 복사하지 않았다.

## 검토 원칙

1. 후보를 한 개씩 분석한다.
2. 유지, 수정, 다른 후보와 통합, 제외 중 하나를 결정한다.
3. 유지하기로 한 스킬만 `skills/`로 옮긴다.
4. 로컬 원본 삭제는 별도로 명시적으로 결정하기 전까지 하지 않는다.
