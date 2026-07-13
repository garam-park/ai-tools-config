# 작업 상태 보드

> 마지막 갱신: 2026-07-14
> 작업 카드는 한 사이클이 끝나면 `tasks/002.done/total/` 로 이동한다.
> 자세한 카드 내용 / 권장 진행 순서는 [002.done/total/README.md](002.done/total/README.md) 참조.

## 완료된 사이클

- **2026-07-14** 통합 작업 (`tasks/002.done/total/*.md`, 32건 전부 완료)
  - 모든 체크박스 [x] 표시 후 `tasks/002.done/total/` 로 이동
  - 실제 변경: `install-skills.sh`/`install-global-instructions.sh` 보호 + 원자성, `SKILL.md`/`codex.md`/`claude.md`/`common.md` 정정, `agents/openai.yaml` → `codex.yaml` 리네임, README 전면 개편, `tests/installer.sh` + `.github/workflows/ci.yml` 추가, `tasks/STATUS.md` 신설

## 작업 카드 ↔ 커밋 토큰 규약

커밋 메시지에 작업 번호를 명시한다. 자세한 규약은 `global-instructions/common.md` 참조.

- 단일: `(task NN)`
- 묶음: `(tasks NN,MM)`
- 추적: `git log --grep="task "`

## 완료 후 새 사이클 시작 절차

1. `tasks/002.done/total/` 의 마지막 인덱스(`README.md`)를 검토
2. 새 사이클 시작 시 `tasks/003.todo/total/` 를 만들고 동일한 통합 분석 절차(예: 다른 모델 비교 + 메타 분석)로 카드를 작성
3. 진행 중 작업은 이 STATUS.md 의 "In Progress" 섹션에 명시
