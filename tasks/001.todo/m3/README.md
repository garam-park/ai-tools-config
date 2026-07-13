# m3 작업 묶음

> 이전 대화의 "프로젝트 분석" 결과 도출된 수정 후보 6건을 개별 md 파일로 분리한 목록.
> 각 파일은 독립적으로 작업·커밋할 수 있다.

## 인덱스

| # | 파일 | 우선순위 |
|---|------|---------|
| 01 | [01-fix-codex-typo.md](01-fix-codex-typo.md) | 상 |
| 02 | [02-align-readme-and-install-skills.md](02-align-readme-and-install-skills.md) | 상 |
| 03 | [03-prune-unimplemented-skill-triggers.md](03-prune-unimplemented-skill-triggers.md) | 중 |
| 04 | [04-update-readme-tree-diagram.md](04-update-readme-tree-diagram.md) | 중 |
| 05 | [05-remove-dead-skip-line.md](05-remove-dead-skip-line.md) | 하 |
| 06 | [06-verify-external-paths.md](06-verify-external-paths.md) | 환경 의존 |

## 권장 진행 순서

1. **01** (오타) — 가장 단순·저위험, 즉시 처리
2. **05** (dead code) — 단순 정리
3. **04** (README 트리) — 문서 정합성
4. **03** (미구현 트리거) — 정책 결정 필요 (방안 A vs B)
5. **02** (README ↔ 스크립트) — 절차 정책 결정 필요 (선택지 1 vs 2)
6. **06** (외부 경로 검증) — 머신에서 직접 확인 후 처리

## 작업 완료 처리

작업이 끝나면 md 파일의 체크박스를 모두 채우고, 해당 파일을 `tasks/002.done/m3/`로 이동한다.

```sh
git mv tasks/001.todo/m3/01-fix-codex-typo.md tasks/002.done/m3/
```