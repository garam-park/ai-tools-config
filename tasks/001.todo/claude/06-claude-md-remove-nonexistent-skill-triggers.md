# 06. claude.md에서 존재하지 않는 스킬 트리거 제거

- **우선순위**: P2 (문서·기능 일관성)
- **대상 파일**: `global-instructions/claude.md` (트리거 섹션 L8, L10)
- **상태**: TODO

## 문제

트리거 섹션이 세 개의 슬래시 명령을 연결한다:

- L8: `/graphify` 입력 시 `graphify` 호출
- L9: `/paced-explainer` 입력 시 `paced-explainer` 호출  ← 유일하게 실재함
- L10: `/ask-step-by-step` 입력 시 `ask-step-by-step` 호출

`skills/`에는 `paced-explainer` 하나만 존재한다. `graphify`, `ask-step-by-step` 스킬 디렉토리는 없다.
동기화되어 `~/.claude/CLAUDE.md`가 되면, 이 두 명령은 해결할 수 없는 스킬을 호출하라고 지시하게 된다.

## 수정 방향

둘 중 하나:

1. (기본) `/graphify`, `/ask-step-by-step` 트리거 줄을 삭제하고 `/paced-explainer`만 남긴다.
2. 실제로 쓸 계획이면 `skills/graphify/`, `skills/ask-step-by-step/` 스킬을 추가한다
   (이 경우 별도 작업으로 분리).

## 완료 조건

- [ ] 트리거 목록이 실재하는 스킬만 참조한다
- [ ] 남긴 트리거가 실제 스킬 이름과 정확히 일치한다
