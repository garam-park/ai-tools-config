# 02. README와 install-skills.sh의 "새 머신에서 사용하기" 절차 정합성 맞추기

## 상태
- [ ] 시작 전
- [ ] 방안 결정
- [ ] 적용
- [ ] 검증
- [ ] 완료

## 우선순위
상

## 문제
두 곳에서 안내하는 새 머신 셋업 절차가 서로 다르다.

### A안: README가 안내하는 절차 ([README.md "새 머신에서 사용하기" 섹션](../../README.md))
1. 리포 clone
2. `rsync -a --delete ~/ai-tools-config/skills/ ~/.local/share/skills/`
3. `cp ~/ai-tools-config/install-skills.sh ~/.local/share/skills/install-skills.sh`
4. `bash ~/.local/share/skills/install-skills.sh`

→ `skills/` 폴더만 동기화되고 스크립트는 별도 복사.

### B안: install-skills.sh 헤더 주석이 안내하는 절차
- "이 스크립트와 `paced-explainer/` 폴더를 `~/.local/share/skills/` 아래에 둔다"

→ 스크립트와 스킬 폴더를 같은 곳에 두면 자동 인식.

`rsync`는 `skills/`만 동기화하므로 README 절차대로 하면 스크립트가 누락된다.

## 변경 파일
- `README.md`
- (필요 시) `install-skills.sh` 헤더 주석

## 권장 방안 (README 단일 절차로 통일)
둘 중 의도가 더 자연스러운 한 가지를 골라 README에 확정한다.

### 선택지 1 — 스크립트를 rsync에 포함 (B안)
README의 rsync 명령을 다음으로 바꾼다.

```sh
rsync -a --delete ~/ai-tools-config/ ~/.local/share/skills/
# (단, README.md, .git 등도 같이 따라오므로 --exclude 필요)

rsync -a --delete \
  --exclude='README.md' \
  --exclude='.git' \
  ~/ai-tools-config/ ~/.local/share/skills/

chmod +x ~/.local/share/skills/install-skills.sh
bash ~/.local/share/skills/install-skills.sh
```

### 선택지 2 — 스크립트를 항상 별도 복사 (A안 유지)
README의 절차는 그대로 두고, `install-skills.sh` 헤더의 "이 스크립트와 paced-explainer/ 폴더를 ..." 문장을 정정한다.

```
이 절차는 README의 "새 머신에서 사용하기"를 따른다.
```

## 검증
- README의 명령을 그대로 새 머신에서 실행했을 때 `~/.local/share/skills/install-skills.sh`가 존재하는지
- 헤더 주석과 실제 절차가 일치하는지

## 커밋 메시지 (예시)
```
docs(readme): align new-machine setup steps with install-skills.sh
```