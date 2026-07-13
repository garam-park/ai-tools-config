# 13. README "4개 도구 경로" 표기 정정

- **우선순위**: P3 (사소한 정리 — 문서)
- **대상 파일**: `README.md` (L39)
- **상태**: TODO

## 문제

L39: "`install-skills.sh`가 자동으로 **4개 도구 경로**(`~/.claude/skills`, `~/.codex/skills`, `~/.config/opencode/skills`)에 심볼릭 링크를 만들어 줌"

"4개 도구 경로"라고 하면서 경로는 3개만 나열한다.
실제로 Claude Code와 GitHub Copilot이 `~/.claude/skills`를 공유하므로 **4개 도구 → 3개 경로**다.
(표 L46–L47과 `install-skills.sh`의 TARGETS 3개와 일치.)

## 수정 방향

도구 수와 경로 수를 구분해 표기한다:

```markdown
`install-skills.sh`가 자동으로 4개 도구(3개 경로: `~/.claude/skills`, `~/.codex/skills`, `~/.config/opencode/skills`)에 심볼릭 링크를 만들어 줌 (Claude Code와 Copilot은 `~/.claude/skills` 공유)
```

## 완료 조건

- [ ] "도구 수"와 "경로 수"가 혼동 없이 표기됨
- [ ] 나열한 경로 수가 실제 TARGETS 수와 일치
