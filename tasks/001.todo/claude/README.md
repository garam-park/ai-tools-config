# claude 작업 묶음

> 이전 대화의 "프로젝트 분석" 결과(고유 이슈 16건)를 논리적 커밋 단위 7개 태스크로 분해한 목록.
> 각 파일은 독립적으로 작업·커밋할 수 있고, 무관한 변경이 한 커밋에 섞이지 않도록 파일/관심사 단위로 묶었다.

## 인덱스

| # | 파일 | 대상 | 우선순위 | 성격 |
|---|------|------|---------|------|
| 01 | [01-guard-destructive-skill-link.md](01-guard-destructive-skill-link.md) | `install-skills.sh` | 🔴 상 | 데이터 손실 방지 |
| 02 | [02-protect-global-instructions.md](02-protect-global-instructions.md) | `install-global-instructions.sh` | 🔴 상 | 데이터 손실 방지 |
| 03 | [03-document-global-instructions-in-readme.md](03-document-global-instructions-in-readme.md) | `README.md` | 🟡 중 | 문서 정합성 |
| 04 | [04-fix-skill-source-model-doc.md](04-fix-skill-source-model-doc.md) | `SKILL.md` | 🟡 중 | 문서 정합성 |
| 05 | [05-prune-unimplemented-triggers.md](05-prune-unimplemented-triggers.md) | `claude.md` | 🟡 중 | 정책 결정 필요 |
| 06 | [06-cleanup-codex-instructions.md](06-cleanup-codex-instructions.md) | `codex.md` | ⚪ 하 | 오타·일관성 |
| 07 | [07-harden-install-skills-shell.md](07-harden-install-skills-shell.md) | `install-skills.sh` | ⚪ 하 | 셸 견고성 |

## 권장 진행 순서

1. **06** (codex 오타·정리) — 가장 단순·저위험, 즉시 처리
2. **07** (install-skills 견고성) — 비파괴적 정리
3. **04** (SKILL 문서) → **03** (README 문서) — 문서 정합성
4. **05** (미구현 트리거) — **정책 결정 필요**(제거 vs 스킬 추가). 결정 후 진행
5. **01**, **02** (데이터 손실 방지) — 파괴적 연산 방어. 실제 셸 환경(Unix/WSL)에서 검증 필요

> 우선순위는 "영향도"(01·02가 최상)와 "진행 난이도"(06·07이 최하)를 분리해 표기했다.
> 실제 착수는 저위험 항목부터 하되, **01·02는 반드시 이번 사이클에 포함**하는 것을 권장한다.

## 상태 표기 규칙

각 파일 상단 체크박스로 진행 상태를 관리한다.

- `[ ] 시작 전` → `[ ] 방안 결정`(해당 시) → `[ ] 적용` → `[ ] 검증` → `[ ] 완료`

## 작업 완료 처리

작업이 끝나면 md 파일의 체크박스를 모두 채우고, 해당 파일을 `tasks/002.done/claude/`로 이동한다.

```sh
git mv tasks/001.todo/claude/06-cleanup-codex-instructions.md tasks/002.done/claude/
```

## 참고

- 스크립트는 `bash` + `ln -s` + `~/.config` 기반이라 **현재 Windows 머신에서는 그대로 실행되지 않는다.**
  검증(특히 01·02·07)은 macOS/Linux 또는 WSL/Git Bash 환경에서 수행한다.
- 커밋 메시지는 "왜"를 중심으로 작성하고, AI 관련 트레일러·서명을 넣지 않는다. push는 명시 요청 시에만.
