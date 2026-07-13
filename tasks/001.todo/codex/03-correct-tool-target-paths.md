# 도구별 개인 스킬 경로 수정

## 목적

각 도구가 실제로 인식하는 개인 스킬 경로에 링크를 생성하도록 대상 목록을 바로잡는다.

## 작업

- Claude Code 대상은 `~/.claude/skills`로 유지한다.
- Codex 대상은 `~/.codex/skills`로 유지한다.
- OpenCode 대상은 `~/.config/opencode/skills`로 유지한다.
- GitHub Copilot 개인 스킬 대상으로 `~/.copilot/skills`를 추가한다.
- Copilot이 `~/.claude/skills`를 개인 경로로 사용한다는 설명을 제거한다.
- 스크립트 출력과 README의 경로 표를 같은 내용으로 맞춘다.

## 완료 조건

- 네 도구가 각각 올바른 개인 경로를 가진다.
- 코드, 주석, 출력 메시지, README 사이에 경로 불일치가 없다.
