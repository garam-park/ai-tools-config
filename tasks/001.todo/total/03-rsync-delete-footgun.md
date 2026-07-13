# 03. README rsync --delete footgun 제거

## 상태
- [ ] 시작 전
- [ ] 적용
- [ ] 검증
- [ ] 완료

## 우선순위
🔴 **P1 — 데이터 손실 위험**

## 제안 모델
- ✅ claude ([03-rsync-delete-footgun.md](../claude/03-rsync-delete-footgun.md))
- ⚠️ m3 (절차 정합성의 일부로 언급 — 표면적)
- ❌ codex

## 문제
[README.md](../README.md) "새 머신에서 사용하기" 2단계:

```sh
rsync -a --delete ~/ai-tools-config/skills/ ~/.local/share/skills/
```

`--delete`는 소스에 없는 목적지 항목을 제거한다. 그런데 `~/.local/share/skills/`는 source-of-truth 폴더이며, 그곳에 별도 복사해 둔 `install-skills.sh`도 있다(`skills/` 소스에는 포함되지 않음).

**재실행 시 로컬 전용 스킬과 복사해 둔 스크립트가 삭제**될 수 있다. 별도 경고 없이 일상 단계로 제시되어 있다.

## 권장 구현 (claude 권장안 채택)

`--delete` 제거. 원본 미러 시맨틱이 필요 없다 — 사용자가 직접 편집할 일 없는 폴더다.

```sh
rsync -a ~/ai-tools-config/skills/ ~/.local/share/skills/
```

대안(미러 시맨틱 유지): `--delete`를 유지하되 `install-skills.sh`를 별도 위치에 두고 "이 폴더에는 리포가 관리하는 스킬만 두라"는 경고를 명시. **권장하지 않음** — 사용자에게 불필요한 복잡성.

## 완료 조건
- [ ] 재실행해도 사용자의 로컬 전용 스킬이 삭제되지 않는다
- [ ] 관련 주석/설명이 실제 동작과 일치한다

## 커밋 메시지 (예시)
```
docs(readme): drop --delete from rsync to avoid removing local skills
```