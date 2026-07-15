# 06. global-instructions/codex.md — 오타 + 자기모순 정정

## 상태
- [x] 시작 전
- [x] 적용
- [x] 검증
- [x] 완료

## 우선순위
🟡 **P2 — 문서 정합성**

## 제안 모델
- ✅ claude ([07-codex-md-fix-contradictory-line.md](../claude/07-codex-md-fix-contradictory-line.md)) — 가장 깊이
- ✅ codex ([06-align-documentation-and-instructions.md](../codex/06-align-documentation-and-instructions.md)) — 부분
- ✅ m3 ([01-fix-codex-typo.md](../m3/01-fix-codex-typo.md)) — 표면 (오타만)

## 문제
[global-instructions/codex.md:10](../../global-instructions/codex.md#L10):

```markdown
- 응답이 길어질 때만 paced-explrainer 청크 모드로 전환 (자동 발동은 기본값)
```

한 줄에 두 가지 결함이 있다.

1. **자기모순**: "응답이 길어질 때만 전환"(길이 게이트)과 "자동 발동은 기본값"이 충돌.
   [SKILL.md](../../skills/paced-explainer/SKILL.md) 의 정의: 자동 트리거는 "모르겠어" 같은 혼란 신호에 발동 — 길이 조건이 아님.
2. **오타**: `paced-explrainer` → `paced-explainer` (dir/SKILL.md/CLAUDE.md 모두 이 철자).

## 권장 구현 (claude안 채택 — SKILL.md 정의에 맞춤)

```markdown
- paced-explainer는 자동 발동이 기본값이며, 사용자가 이해하지 못한다는 신호("모르겠어" 등)에 청크 모드로 전환한다
```

(수동 전환 정책으로 갈 경우엔 "긴 응답에서만 수동 전환"으로 통일 — 양쪽을 섞지 말 것.)

## 완료 조건
- [x] 자기모순 없이 하나의 정책을 서술
- [x] SKILL.md의 트리거 정의와 충돌하지 않음
- [x] `paced-explrainer` 오타 → `paced-explainer`

## 검증
```sh
grep -n paced-explainer global-instructions/codex.md
grep -n paced-explrainer global-instructions/ -r   # 매칭 없어야 함
```

## 커밋 메시지 (예시)
```
fix(codex): correct skill name typo and resolve self-contradicting policy
```