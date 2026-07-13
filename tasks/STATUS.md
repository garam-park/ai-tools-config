# 작업 상태 보드

> 마지막 갱신: 2026-07-14
> 작업 시작/완료 시 이 파일을 함께 갱신한다. 카드 원본과 우선순위는
> [001.todo/total/README.md](001.todo/total/README.md) 참조.

## 진행 규칙

- 각 작업의 세부 진행은 카드 md의 `## 상태` 체크박스로 관리한다.
- 완료한 카드는 `git mv`로 `001.todo/total/` → `002.done/total/`로 이동한다.
- 커밋 메시지에는 `(task NN)` / `(tasks NN,MM)` 토큰을 붙인다 (common.md 규약, task 32).
- 카드별 `started`/`status` 헤더는 두지 않는다 — 진행 상태는 카드 위치(todo/done)와
  이 보드로 충분히 드러나므로, 중복 메타데이터를 남기지 않는다는 결정.

## In Progress

(없음)

## Next (이번 사이클)

(없음 — 1차 사이클 전량 완료)

## 1차 사이클 — 완료 ✅ (2026-07-14)

세 AI 모델(claude · codex · m3) 분석 + 메타 분석으로 도출한 **32건 전부 완료**,
`002.done/total/`로 이동. 요약:

| 구분 | 작업 카드 |
| --- | --- |
| P1 데이터 안전 | 01, 22 · 02, 23, 25 · 03 |
| P2 정확성/정합성 | 04, 05 · 06 · 07 · 08 · 09 · 24 |
| P3 셸 견고성 | 10, 11, 12, 13, 14 |
| P3 문서 | 15, 16, 17, 18, 19, 26, 27, 28, 30 |
| P3 위생/정책 | 29 |
| 운영 개선 | 31, 32 |
| 장기 인프라 | 20 (manifest), 21 (테스트·CI) |

주요 성과:

- **데이터 손실 차단**: `install-skills.sh`는 심링크만 교체(사용자 실제 파일/디렉토리 보존, `--force` 백업),
  `install-global-instructions.sh`는 사용자 파일 백업·심링크 dest 보존·원자적 쓰기.
- **정합성**: 외부 경로 검증(Copilot = `~/.copilot/skills`) 후 코드·README·SKILL.md 일치.
- **인프라**: manifest 기반 stale 링크 정리, 임시 HOME 통합 테스트 19케이스 + ShellCheck CI.

## Backlog (다음 사이클)

- 새 작업 카드는 `001.todo/`에 추가하고 이 보드의 **In Progress / Next**에 반영한다.
- 우선순위 기준은 [001.todo/total/README.md](001.todo/total/README.md)의 P1 → P3 → 운영 → 장기 순서를 따른다.
