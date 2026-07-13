# 14. codex.md 낡은 잔재 주석 제거

- **우선순위**: P3 (사소한 정리 — 문서)
- **대상 파일**: `global-instructions/codex.md` (L4)
- **상태**: TODO

## 문제

L4: "`~/.codex/AGENTS.md`로 동기화된다 **(이전에는 빈 파일이었음)**."

괄호 안 "(이전에는 빈 파일이었음)"은 과거 상태에 대한 잔재로, 현재 동작과 무관하다.
평행 헤더인 `claude.md:4`, `opencode.md:4`에는 이런 부연이 없어 일관성도 깨진다.

## 수정 방향

괄호 부연을 제거해 다른 도구 헤더와 형식을 맞춘다:

```markdown
> `~/.codex/AGENTS.md`로 동기화된다.
```

## 완료 조건

- [ ] 낡은 괄호 주석이 제거됨
- [ ] 헤더 형식이 claude.md / opencode.md와 일치
