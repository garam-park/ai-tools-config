# Codex 전용 지침

> Codex에서만 추가로 적용되는 사항.
> `~/.codex/AGENTS.md`로 동기화된다 (이전에는 빈 파일이었음).

## Codex 전용

- 도구 트리거는 `$analyze-task TSK-XXXX` / `$spec-task` / `$start-task` 형식의 슬래시-달러 명령이다
- Notion 작업 분석/실행 시 `$analyze-task` → `$spec-task` → `$start-task` 순서를 따른다
- 응답이 길어질 때만 paced-explrainer 청크 모드로 전환 (자동 발동은 기본값)