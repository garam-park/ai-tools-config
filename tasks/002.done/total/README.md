# ai-tools-config — 통합 작업 목록 (total)

> 세 AI 모델(claude · codex · m3)이 동일 리포를 분석해 도출한 **모든 발견 항목**을 중복 제거하고
> 우선순위별로 재구성한 통합 작업 목록. 각 작업은 개별 md로 분해되어 있다.
>
> 메타 분석으로 도출된 **누락 보강 11건**(22–32)이 추가되었다.

## 출처별 원본 작업

| 모델 | 폴더 | 작업 수 | 특징 |
|------|------|--------|------|
| claude | [../claude/](../claude/) | 15 | 가장 상세·포괄, 셸 견고성·문서 불일치까지 발굴 |
| codex | [../codex/](../codex/) | 7 | 큰 단위로 통합, 테스트/CI·manifest 등 인프라 제안 |
| m3 | [../m3/](../m3/) | 6 | 간결, 외부 경로 검증이라는 메타 접근 |
| **메타 분석** | (이 total의 22–32) | **11** | **세 모델이 모두 놓친 결함 / 보강 필요 항목** |

비교 평가 원문: [../t1.md](../t1.md)

## 통합 결과

- **총 32개 고유 작업** (원본 28건 + 메타 분석 11건 − 중복 보강 7건)
- 우선순위 P1 → P3 → 운영 → 장기 로드맵 순으로 배치
- 각 작업 md는 출처 모델과 의존 관계를 명시

## 마스터 인덱스

### P1 — 데이터 손실 / 파괴적 연산 / 보안 (5건)

| # | 작업 | 대상 파일 | 제안 | 비고 |
|---|------|----------|------|------|
| 01 | [01-install-skills-rm-rf-guard.md](01-install-skills-rm-rf-guard.md) | `install-skills.sh` | claude, codex | 기존 P1 |
| 02 | [02-global-instructions-backup.md](02-global-instructions-backup.md) | `install-global-instructions.sh` | claude, codex | 기존 P1 |
| 03 | [03-rsync-delete-footgun.md](03-rsync-delete-footgun.md) | `README.md` | claude | 기존 P1 |
| 22 | [22-install-skills-partial-failure-handling.md](22-install-skills-partial-failure-handling.md) | `install-skills.sh` | **메타** | 작업 01 보강 |
| 23 | [23-global-instructions-dest-is-symlink.md](23-global-instructions-dest-is-symlink.md) | `install-global-instructions.sh` | **메타** | 작업 02 보강 |

### P2 — 정확성 / 문서 정합성 (8건)

| # | 작업 | 대상 파일 | 제안 | 의존 |
|---|------|----------|------|------|
| 04 | [04-verify-external-paths.md](04-verify-external-paths.md) | (조사) | m3 | — |
| 05 | [05-align-tool-target-paths.md](05-align-tool-target-paths.md) | `install-skills.sh` + 문서 | claude, codex | → 04 |
| 06 | [06-fix-codex-md-typo-contradiction.md](06-fix-codex-md-typo-contradiction.md) | `global-instructions/codex.md` | claude, codex, m3 | — |
| 07 | [07-prune-unimplemented-skill-triggers.md](07-prune-unimplemented-skill-triggers.md) | `global-instructions/claude.md` | claude, codex, m3 | — |
| 08 | [08-document-global-instructions-in-readme.md](08-document-global-instructions-in-readme.md) | `README.md` | claude, codex | — |
| 09 | [09-fix-skill-md-platforms-section.md](09-fix-skill-md-platforms-section.md) | `skills/paced-explainer/SKILL.md` | claude, codex | → 04 |
| 24 | [24-empty-srcdir-warning.md](24-empty-srcdir-warning.md) | `install-skills.sh` | **메타** | 작업 10 보강 |
| 25 | [25-simplify-auto-generated-marker.md](25-simplify-auto-generated-marker.md) | `install-global-instructions.sh` | **메타** | 작업 02 보강 |

### P3 — 셸 견고성 · 문서 폴리시 (13건)

| # | 작업 | 대상 파일 | 제안 |
|---|------|----------|------|
| 10 | [10-add-nullglob.md](10-add-nullglob.md) | `install-skills.sh` | claude, codex |
| 11 | [11-fix-src-dir-comment.md](11-fix-src-dir-comment.md) | `install-skills.sh` | claude |
| 12 | [12-atomic-mktemp-write.md](12-atomic-mktemp-write.md) | `install-global-instructions.sh` | claude |
| 13 | [13-strip-trailing-slash-symlink.md](13-strip-trailing-slash-symlink.md) | `install-skills.sh` | claude |
| 14 | [14-remove-dead-guard-with-skill-md-filter.md](14-remove-dead-guard-with-skill-md-filter.md) | `install-skills.sh` | claude, codex, m3 |
| 15 | [15-remove-stale-codex-parenthetical.md](15-remove-stale-codex-parenthetical.md) | `global-instructions/codex.md` | claude |
| 16 | [16-readme-4-tools-3-paths.md](16-readme-4-tools-3-paths.md) | `README.md` | claude |
| 17 | [17-readme-tree-diagram-agents-references.md](17-readme-tree-diagram-agents-references.md) | `README.md` | m3 |
| 18 | [18-readme-platform-prerequisite.md](18-readme-platform-prerequisite.md) | `README.md` | claude |
| 19 | [19-align-readme-install-skills-procedure.md](19-align-readme-install-skills-procedure.md) | `README.md` + `install-skills.sh` | m3 |
| 26 | [26-readme-code-fence-language.md](26-readme-code-fence-language.md) | `README.md` | **메타** |
| 27 | [27-skill-md-description-trim.md](27-skill-md-description-trim.md) | `skills/paced-explainer/SKILL.md` | **메타** |
| 28 | [28-openai-yaml-codex-only-notation.md](28-openai-yaml-codex-only-notation.md) | `skills/paced-explainer/agents/openai.yaml` | **메타** |

### P3-위생 — 정책 명시 (2건)

| # | 작업 | 대상 파일 | 제안 |
|---|------|----------|------|
| 29 | [29-gitignore-tasks-policy.md](29-gitignore-tasks-policy.md) | `.gitignore` + `README.md` | **메타** |
| 30 | [30-readme-tool-table-script-source.md](30-readme-tool-table-script-source.md) | `README.md` | **메타** (작업 16 확장) |

### 운영 개선 (2건)

| # | 작업 | 대상 파일 | 제안 |
|---|------|----------|------|
| 31 | [31-status-board-or-projects.md](31-status-board-or-projects.md) | `tasks/STATUS.md` (신규) 또는 GitHub Projects | **메타** |
| 32 | [32-commit-message-task-token.md](32-commit-message-task-token.md) | `global-instructions/common.md` | **메타** |

### 장기 로드맵 (2건)

| # | 작업 | 대상 파일 | 제안 |
|---|------|----------|------|
| 20 | [20-clean-stale-managed-links.md](20-clean-stale-managed-links.md) | `install-skills.sh` (manifest) | codex |
| 21 | [21-installer-tests-and-ci.md](21-installer-tests-and-ci.md) | CI + 테스트 | codex |

## 권장 진행 순서 (커밋 가능 단위)

### 1단계: 데이터 안전 (P1, 이번 사이클 필수)
1. **01** install-skills rm-rf 가드 + **22** 부분 실패 처리 (한 커밋에 묶기)
2. **02** global-instructions 백업 + **23** dest 심링크 처리 + **25** 마커 단순화 (한 커밋에 묶기)
3. **03** rsync --delete 제거

### 2단계: 경로 사실 확인 (P2, 다른 P2 작업의 전제)
4. **04** 외부 도구 경로 검증 → 결과를 **05, 09**에 반영

### 3단계: 저위험 문서/스크립트 정리 (P2 + P3)
5. **06** codex.md 오타·모순
6. **14** 죽은 가드 제거 + SKILL.md 필터 (가장 큰 구조 개선)
7. **15** codex.md 잔재 주석
8. **07** 미구현 트리거 정리
9. **10** nullglob 추가 + **24** 빈 SRC_DIR 경고 (한 커밋에 묶기)
10. **11** SRC_DIR 주석 정정
11. **12** mktemp 원자성
12. **13** 심링크 후행 슬래시

### 4단계: 문서 정합성 (P2 + P3 + 위생)
13. **08** README에 global-instructions 문서화
14. **05** 도구별 타깃 경로 정렬 (04 결과 반영)
15. **09** SKILL.md Platforms 정정 (04 결과 반영)
16. **16** README "4도구-3경로" 표기 + **30** 스크립트 소스 컬럼 (한 커밋에 묶기)
17. **17** README 트리 다이어그램 보강
18. **18** README 전제 환경 명시
19. **19** README ↔ install-skills 절차 정합
20. **26** README 코드 펜스 언어
21. **27** SKILL.md description 축약
22. **28** agents/openai.yaml Codex 전용 표기
23. **29** `.gitignore`에 tasks 추적 정책 명시

### 5단계: 운영 규약
24. **32** 커밋 메시지 작업 토큰 규약 (common.md)
25. **31** 작업 상태 보드(STATUS.md) 작성

### 6단계: 인프라 (장기)
26. **20** manifest 기반 stale link 정리
27. **21** 테스트 + CI

## 작업 완료 처리

각 작업 md의 체크박스를 모두 채운 뒤 `tasks/002.done/total/`로 이동:

```sh
git mv tasks/001.todo/total/06-fix-codex-md-typo-contradiction.md tasks/002.done/total/
```

## 작업 상태 표기 규칙

- `[ ] 시작 전` → `[ ] 적용` → `[ ] 검증` → `[ ] 완료`
- 정책 결정이 필요한 작업은 `[ ] 방안 결정`을 추가로 둠

## 메타 분석 메모 (22–32 추가 배경)

세 모델은 각자 분석은 우수했지만, 모두 놓친 결함이 존재했다. 메타 분석으로 다음을 발견:

- **P1 보안 공백**: `set -e` + 부분 실패 시 비일관 링크 상태. dest가 심볼릭 링크일 때 `mv` 동작.
- **P2 정확성**: 빈 SRC_DIR 조용한 성공, 마커 3줄 분산.
- **P3 위생**: README `sh` 펜스, SKILL description 중복, `.gitignore` 정책 부재, agents 표기 모호.
- **운영**: 상태 보드 부재, 커밋-카드 연결 규약 부재.

## 모델별 발견 매트릭스 (참고)

| 발견 항목 | claude | codex | m3 | 메타 |
|-----------|:------:|:-----:|:--:|:----:|
| rm-rf 가드 | ✅ | ✅ | ❌ | ✅ 부분 실패 보강 |
| global-instructions 백업 | ✅ | ✅ | ❌ | ✅ dest-심링크 + 마커 단순화 |
| rsync --delete | ✅ | ❌ | 표면 | — |
| 외부 경로 검증 | ❌ | ❌ | ✅ | — |
| 도구별 경로 정렬 | ✅ (공유) | ✅ (별도) | ❌ | — |
| codex 오타·모순 | ✅ 깊이 | ✅ | ✅ 표면 | — |
| 미구현 트리거 | ✅ | ✅ | ✅ | — |
| global-instructions 문서화 | ✅ | ✅ | ❌ | — |
| SKILL.md Platforms 정정 | ✅ | ✅ (다른 의견) | ❌ | — |
| nullglob | ✅ | ✅ 언급 | ❌ | ✅ 빈 SRC_DIR 경고 |
| dead guard | ✅ (대체안) | ✅ | ✅ (단순) | — |
| 기타 셸 견고성 4건 | ✅ | ❌ | ❌ | ✅ 일부 (README 펜스 등) |
| README 문서 4건 | ✅ | ❌ | ✅ 일부 | ✅ 일부 (스크립트 소스 컬럼) |
| agents/openai.yaml 표기 | ❌ | ❌ | ❌ | ✅ Codex 전용 |
| .gitignore 정책 | ❌ | ❌ | ❌ | ✅ |
| 상태 보드 / 토큰 규약 | ❌ | ❌ | ❌ | ✅ |
| manifest 기반 정리 | ❌ | ✅ | ❌ | — |
| 테스트·CI | ❌ | ✅ | ❌ | — |

> 표의 출처: [../t1.md](../t1.md) §6 + 메타 분석