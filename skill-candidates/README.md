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

- `ask-step-by-step`
- `graphify`
- `multi-agent-decide`
- `obsidian-docs`

## 제외한 항목

- `paced-explainer`: 이미 `skills/`에서 관리 중이다.
- `.codex/skills/.system`: Codex 시스템 제공 스킬이다.
- `paperclip*`, `para-memory-files`, `frontend-design--*`: 외부 패키지나 런타임을 가리키는 심볼릭 링크라서 복사하지 않았다.

## 검토 원칙

1. 후보를 한 개씩 분석한다.
2. 유지, 수정, 다른 후보와 통합, 제외 중 하나를 결정한다.
3. 유지하기로 한 스킬만 `skills/`로 옮긴다.
4. 로컬 원본 삭제는 별도로 명시적으로 결정하기 전까지 하지 않는다.
