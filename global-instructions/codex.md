# Codex 전용 지침

> Codex에서만 추가로 적용되는 사항.
> `~/.codex/AGENTS.md`로 동기화된다.

## Codex 전용

- 도구 트리거는 `$analyze-task TSK-XXXX` / `$spec-task` / `$start-task` 형식의 슬래시-달러 명령이다
- Notion 작업 분석/실행 시 `$analyze-task` → `$spec-task` → `$start-task` 순서를 따른다
- paced-explainer는 자동 발동이 기본값이며, 사용자가 이해하지 못한다는 신호("모르겠어" 등)에 청크 모드로 전환한다
