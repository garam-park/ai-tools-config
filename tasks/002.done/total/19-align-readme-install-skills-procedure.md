# 19. README ↔ install-skills.sh "새 머신" 절차 정합성

## 상태
- [x] 시작 전
- [x] 방안 결정
- [x] 적용
- [x] 검증
- [x] 완료

## 우선순위
⚪ **P3 — 문서**

## 제안 모델
- ✅ m3 ([02-align-readme-and-install-skills.md](../m3/02-align-readme-and-install-skills.md))
- ❌ claude
- ❌ codex

## 문제
두 곳에서 안내하는 새 머신 셋업 절차가 서로 다르다.

### A안 — README 안내
```sh
rsync -a --delete ~/ai-tools-config/skills/ ~/.local/share/skills/
cp ~/ai-tools-config/install-skills.sh ~/.local/share/skills/install-skills.sh
chmod +x ~/.local/share/skills/install-skills.sh
bash ~/.local/share/skills/install-skills.sh
```
→ `skills/`만 동기화, 스크립트는 별도 복사

### B안 — install-skills.sh 헤더 주석
> "이 스크립트와 `paced-explainer/` 폴더를 `~/.local/share/skills/` 아래에 둔다"

→ 스크립트와 스킬 폴더를 같은 곳에 두면 자동 인식

**`rsync`는 `skills/`만 동기화**하므로 README 절차대로 하면 스크립트가 누락됨.

> 작업 **03**(`--delete` 제거)이 먼저 적용되면 rsync 명령 자체는 변경됨

## 권장 절차 (m3안)

### 선택지 1 — 스크립트를 rsync에 포함 (B안)
```sh
rsync -a \
  --exclude='README.md' --exclude='.git' \
  ~/ai-tools-config/ ~/.local/share/skills/

chmod +x ~/.local/share/skills/install-skills.sh
bash ~/.local/share/skills/install-skills.sh
```
> 이 방식이면 README 1단계(클론) → 2단계(rsync) → 3단계(실행)으로 단순화 가능

### 선택지 2 — 스크립트 별도 복사 유지 (A안)
README 절차는 유지하고 `install-skills.sh` 헤더 주석을 정정.

## 완료 조건
- [x] README의 명령만으로 새 머신에서 모든 동기화가 끝남
- [x] 헤더 주석과 실제 절차가 일치

## 커밋 메시지 (예시)
```
docs(readme): align new-machine setup steps with install-skills.sh comment
```