# 03. 온보딩 `rsync --delete` footgun 제거

- **우선순위**: P1 (데이터 손실 위험)
- **대상 파일**: `README.md` (L25–L26 부근, "새 머신에서 사용하기")
- **상태**: TODO

## 문제

온보딩 2단계 명령이 `rsync -a --delete ~/ai-tools-config/skills/ ~/.local/share/skills/`.
`--delete`는 소스에 없는 목적지 항목을 제거한다. 그런데 `~/.local/share/skills/`는
스크립트의 source-of-truth 폴더이자 복사된 `install-skills.sh`(리포 루트에 있어 `skills/` 소스에 포함되지 않음)가 놓이는 곳이다.
따라서 **재실행 시 로컬 전용 스킬과 복사해 둔 `install-skills.sh`가 삭제**될 수 있다. 별도 경고 없이 일상 단계로 제시되어 있다.

## 수정 방향

둘 중 하나:

1. (권장) 온보딩 복사에서 `--delete`를 뺀다.
   ```sh
   rsync -a ~/ai-tools-config/skills/ ~/.local/share/skills/
   ```
2. 미러 시맨틱을 유지하려면, "이 폴더에는 리포가 관리하는 스킬만 두라"는 경고를 명시하고
   복사한 `install-skills.sh`를 `--delete` 대상 밖으로 옮긴다.

## 완료 조건

- [ ] 재실행해도 사용자의 로컬 전용 스킬이 삭제되지 않는다
- [ ] 관련 주석/설명이 실제 동작과 일치한다
