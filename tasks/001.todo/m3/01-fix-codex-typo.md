# 01. codex.md 오타 수정

## 상태
- [ ] 시작 전
- [ ] 수정 적용
- [ ] 검증
- [ ] 완료

## 우선순위
상

## 문제
[global-instructions/codex.md:7](global-instructions/codex.md#L7) 에 스킬 이름 오타가 있다.

```markdown
- 응답이 길어질 때만 paced-explrainer 청크 모드로 전환 (자동 발동은 기본값)
```

`paced-explrainer` → `paced-explainer`

## 변경 파일
- `global-instructions/codex.md` (한 단어만 수정)

## 변경 내용
```diff
-- 응답이 길어질 때만 paced-explrainer 청크 모드로 전환 (자동 발동은 기본값)
++ 응답이 길어질 때만 paced-explainer 청크 모드로 전환 (자동 발동은 기본값)
```

## 검증
```sh
grep -n paced-explainer global-instructions/codex.md
grep -n paced-explrainer global-instructions/   # 매칭 없어야 함
```

## 커밋 메시지 (예시)
```
fix(codex): correct skill name typo in codex.md
```