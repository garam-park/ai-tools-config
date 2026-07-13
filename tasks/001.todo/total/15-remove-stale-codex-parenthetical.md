# 15. codex.md 낡은 잔재 주석 제거

## 상태
- [ ] 시작 전
- [ ] 적용
- [ ] 검증
- [ ] 완료

## 우선순위
⚪ **P3 — 문서**

## 제안 모델
- ✅ claude ([14-remove-stale-parenthetical-codex.md](../claude/14-remove-stale-parenthetical-codex.md))
- ❌ codex
- ❌ m3

## 문제
[global-instructions/codex.md:4](../../global-instructions/codex.md#L4):

```markdown
> `~/.codex/AGENTS.md`로 동기화된다 **(이전에는 빈 파일이었음)**.
```

괄호 안 "(이전에는 빈 파일이었음)"은 과거 상태의 잔재로 현재 동작과 무관하다. 평행 헤더인 [claude.md:4](../../global-instructions/claude.md#L4), [opencode.md:4](../../global-instructions/opencode.md#L4)에는 이런 부연이 없어 일관성이 깨진다.

## 권장 구현

```markdown
> `~/.codex/AGENTS.md`로 동기화된다.
```

## 완료 조건
- [ ] 낡은 괄호 주석 제거
- [ ] 헤더 형식이 claude.md / opencode.md와 일치

## 커밋 메시지 (예시)
```
docs(codex): remove stale parenthetical about prior empty file
```