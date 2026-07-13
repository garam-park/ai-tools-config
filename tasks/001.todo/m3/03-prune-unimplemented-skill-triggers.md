# 03. claude.md의 미구현 스킬 트리거 정리

## 상태
- [ ] 시작 전
- [ ] 방안 결정
- [ ] 적용
- [ ] 검증
- [ ] 완료

## 우선순위
중

## 문제
[global-instructions/claude.md:5-9](global-instructions/claude.md#L5-L9) 에는 3개 스킬 트리거가 명시되어 있지만, 실제 `skills/` 폴더에는 `paced-explainer`만 존재한다.

```markdown
## 트리거

- `/graphify` 입력 시 Skill 도구로 `graphify` 호출
- `/paced-explainer` 입력 시 Skill 도구로 `paced-explainer` 호출
- `/ask-step-by-step` 입력 시 Skill 도구로 `ask-step-by-step` 호출
```

## 변경 파일
- `global-instructions/claude.md`

## 방안 A: 미구현 트리거 제거 (현재 상태에 맞춤)
```markdown
## 트리거

- `/paced-explainer` 입력 시 Skill 도구로 `paced-explainer` 호출
```

## 방안 B: 트리거를 TODO로 보존 (구현 의도가 있는 경우)
```markdown
## 트리거

- `/paced-explainer` 입력 시 Skill 도구로 `paced-explainer` 호출

## 미구현 트리거 (TODO)

- [ ] `/graphify` — `skills/graphify/` 추가 필요
- [ ] `/ask-step-by-step` — `skills/ask-step-by-step/` 추가 필요
```

## 권장
방안 A (현재 동작하는 상태와 정합). 새 스킬은 추가될 때 트리거도 함께 추가.

## 검증
- `claude.md`에 적힌 모든 `/xxx` 명령이 `skills/<xxx>/SKILL.md`로 연결되는지

## 커밋 메시지 (예시)
```
fix(claude): remove triggers for unimplemented skills
```