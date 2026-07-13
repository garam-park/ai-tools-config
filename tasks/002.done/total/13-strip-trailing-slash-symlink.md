# 13. install-skills.sh — 심링크 타깃 후행 슬래시 제거

## 상태
- [x] 시작 전
- [x] 적용
- [x] 검증
- [x] 완료

## 우선순위
⚪ **P3 — 미관**

## 제안 모델
- ✅ claude ([12-strip-trailing-slash-symlink.md](../claude/12-strip-trailing-slash-symlink.md))
- ❌ codex
- ❌ m3

## 문제
[install-skills.sh:39](../../install-skills.sh#L39) (작업 14 적용 후 위치 변경 가능):

```bash
ln -s "$skill_dir" "$link"
```

`skill_dir`은 `*/` 글롭에서 오므로 항상 `/`로 끝난다.
따라서 생성된 심링크의 타깃 문자열도 `/`로 끝나 (`paced-explainer -> /abs/paced-explainer/`),
`readlink` 결과가 비정규 형태가 된다.

Linux에서 해석은 정상이지만, 심링크 타깃을 문자열 비교하는 도구에는 노이즈다. **동작에는 무해.**

## 권장 구현

루프 본문 상단에서 후행 슬래시 제거:

```bash
skill_dir="${skill_dir%/}"
```

(`name`/`basename` 로직은 슬래시 유무와 무관하게 동작.)

## 완료 조건
- [x] 생성된 심링크의 `readlink` 값이 후행 슬래시 없이 정규 경로로 나온다
- [x] 링크 해석/동작은 기존과 동일

## 검증
```sh
bash install-skills.sh
readlink ~/.claude/skills/paced-explainer   # 슬래시 없이 끝나야 함
```

## 커밋 메시지 (예시)
```
chore(install-skills): strip trailing slash from symlink target
```