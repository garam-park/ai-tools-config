# 07. claude.md 미구현 스킬 트리거 정리

## 상태
- [ ] 시작 전
- [ ] 방안 결정
- [ ] 적용
- [ ] 검증
- [ ] 완료

## 우선순위
🟡 **P2 — 문서 정합성**

## 제안 모델
- ✅ claude ([06-claude-md-remove-nonexistent-skill-triggers.md](../claude/06-claude-md-remove-nonexistent-skill-triggers.md))
- ✅ codex ([06-align-documentation-and-instructions.md](../codex/06-align-documentation-and-instructions.md))
- ✅ m3 ([03-prune-unimplemented-skill-triggers.md](../m3/03-prune-unimplemented-skill-triggers.md))

## 문제
[global-instructions/claude.md:5-9](../../global-instructions/claude.md#L5-L9):

```markdown
## 트리거

- `/graphify` 입력 시 Skill 도구로 `graphify` 호출
- `/paced-explainer` 입력 시 Skill 도구로 `paced-explainer` 호출
- `/ask-step-by-step` 입력 시 Skill 도구로 `ask-step-by-step` 호출
```

`skills/` 폴더에는 `paced-explainer`만 존재. `graphify`, `ask-step-by-step` 디렉토리는 없다.
`~/.claude/CLAUDE.md`로 동기화되면 이 두 명령은 **해결할 수 없는 스킬 호출을 지시**하게 된다.

## 방안 A: 미구현 트리거 제거 (현재 상태에 맞춤, 권장)

```markdown
## 트리거

- `/paced-explainer` 입력 시 Skill 도구로 `paced-explainer` 호출
```

## 방안 B: TODO로 보존 (구현 의도가 있는 경우)

```markdown
## 트리거

- `/paced-explainer` 입력 시 Skill 도구로 `paced-explainer` 호출

## 미구현 트리거 (TODO)

- [ ] `/graphify` — `skills/graphify/` 추가 필요
- [ ] `/ask-step-by-step` — `skills/ask-step-by-step/` 추가 필요
```

## 권장
**방안 A**. 새 스킬은 추가될 때 트리거도 함께 추가하는 것이 정책상 명확.

## 완료 조건
- [ ] 트리거 목록이 실재하는 스킬만 참조
- [ ] 남긴 트리거가 실제 스킬 이름과 정확히 일치

## 검증
```sh
ls skills/                                       # paced-explainer만 보여야 함
grep -E '/(graphify|ask-step-by-step)' global-instructions/claude.md   # 매칭 없어야 함
```

## 커밋 메시지 (예시)
```
fix(claude): remove triggers for unimplemented skills
```