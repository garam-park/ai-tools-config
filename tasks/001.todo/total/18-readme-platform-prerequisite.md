# 18. README에 전제 환경(Unix/WSL) 명시

## 상태
- [ ] 시작 전
- [ ] 적용
- [ ] 검증
- [ ] 완료

## 우선순위
⚪ **P3 — 이식성**

## 제안 모델
- ✅ claude ([15-readme-platform-prerequisite.md](../claude/15-readme-platform-prerequisite.md))
- ❌ codex
- ❌ m3

## 문제
설치 절차가 POSIX 전용 도구(`rsync`, `chmod`, `bash`, `ln -s`)와 `~/.local/share`, `~/.config` 경로에 의존한다. 그러나 전제 플랫폼 안내가 없다.

현재 사용자의 머신은 **Windows**이며, Windows에선 기본적으로 이 도구·경로가 없다
(Git Bash에서 `ln -s`가 복사로 격하되거나 실패). 안내 없이 따라 하면 실패한다.

## 권장 구현

설치 섹션 상단에 한 줄 전제 조건을 추가:

```markdown
> 전제: Unix-like 환경 필요 (macOS / Linux, 또는 Windows에서는 WSL/Git Bash).
> `ln -s` 심볼릭 링크가 동작하는 환경이어야 한다.
```

(선택) 스크립트에서 `ln -s` 가능 여부를 검사해 불가 시 경고하거나 `cp -r`로 폴백. 단, 이 카드는 **문서 명시까지로 한정**.

## 완료 조건
- [ ] README에 전제 플랫폼이 명시됨
- [ ] Windows 사용자가 WSL/Git Bash 필요를 사전 인지 가능

## 커밋 메시지 (예시)
```
docs(readme): state Unix/WSL prerequisite at install section
```