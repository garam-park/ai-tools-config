# 구조 리뷰 보고서 (2026-07-15)

여러 장치·여러 AI 코딩 플랫폼(Claude Code, Codex, GitHub Copilot, OpenCode)에서 일관된 개발환경을 제공한다는 목표에 비추어 리포 전체를 진단하고, 그 결과에 따라 수행한 경량 정리를 기록한다.

## 1. 요약

핵심 아키텍처는 **건전하다**. 이 리포는 이미 다음 모델을 구현하고 있다.

- **플랫폼 중립 자산**: 스킬 6종의 `SKILL.md`는 중립 frontmatter(`name`+`description`)만 사용하고, 본문도 특정 도구의 경로·기능을 가정하지 않는다.
- **얇은 플랫폼 델타**: 글로벌 지침은 `common.md` 하나에 도구별 델타 3종(`claude.md`·`codex.md`·`opencode.md`)을 결합해 설치 시 렌더링한다.
- **재현 가능한 설치기**: 모든 경로가 `$HOME`/`$XDG_STATE_HOME` 기준(하드코딩 절대 경로 없음), bash 3.2 호환, 멱등, manifest 기반 정리, `doctor` 서브커맨드, 격리 HOME 테스트, CI 2종.
- **비밀값 안전**: 커밋된 시크릿 없음. `NOTION_TOKEN`은 환경변수 주입, `.gitignore`가 `.env` 계열 차단.

문제는 구조가 아니라 **문서화와 정합성**이었다: README의 구성 트리가 실제와 어긋나고, 스킬 하나에 옛 설치 경로 서술이 남았고, 종료된 작업 카드 33개 파일이 루트를 차지했고, 새 기기 설정에 명령 4개가 필요했다. 이번 정리는 이 지점들만 손봤다.

## 2. 진단 요약표

| 영역 | 현재 파일/폴더 | 적용 상태 | 문제점 | 개선 방향 (→ 수행 결과) |
|---|---|---|---|---|
| 공통 지침 | `global-instructions/` (common+델타 3종) | 양호 — 설치 시 3개 도구 경로로 렌더 | Copilot만 글로벌 지침 미수신 (공백) | 공백을 [docs/platform-mapping.md](docs/platform-mapping.md)에 명시, 검증된 경로 확인은 후속 작업 |
| 스킬 | `skills/` 6종 (`inp-*` 5 + `paced-explainer`) | 양호 — 중립 SKILL.md + Codex 메타 | `paced-explainer/SKILL.md`에 구경로(`~/.local/share/skills/`) 서술 잔존 | 리포 직결 심링크 모델로 서술 수정 (완료) |
| 커맨드 | 없음 (스킬 트리거 + `codex.yaml` `default_prompt`로 대체) | 의도적 부재 | 부재 사유 미문서화 | [docs/concepts.md](docs/concepts.md)에 도입 기준 기록 (완료) |
| 에이전트 | `.github/agents/` 4종 (Copilot 역할 규약) | 양호 | Claude 서브에이전트와 개념 혼동 여지 | concepts.md에서 구분 설명 (완료) |
| MCP | 없음 (Notion은 REST 직접 호출 fallback) | 의도적 부재 | 부재 사유 미문서화 | concepts.md에 도입 기준 기록 (완료) |
| 훅 | 없음 | 의도적 부재 | 동일 | 동일 (완료) |
| 플러그인 | 없음 | 의도적 부재 | 동일 | 동일 (완료) |
| 하네스 | 설치기 2종(install/doctor/--force) + `tests/installers_test.sh` + CI 2종 | 양호 | 새 기기에서 명령 4개 필요 | `bootstrap.sh` 신설 — 설치 2종+doctor 2종 일괄 (완료) |
| 장치 동기화 | `$HOME`/`$XDG_STATE_HOME` 기반, 하드코딩 경로 없음, bash 3.2 호환 | 양호 | Windows 지원 조건이 README 한 줄뿐 | [docs/device-setup.md](docs/device-setup.md)로 확장 (완료) |
| 비밀값 | 커밋된 시크릿 없음, `NOTION_TOKEN`은 env 주입, `.gitignore`에 `.env` 차단 | 양호 | 없음 | 현상 유지 + device-setup.md에 주입 안내 (완료) |
| 문서화 | README.md 단일 (149줄) | 미흡 | 구성 트리 stale(`.github/agents/` 등 누락, 들여쓰기 오류), 상세 내용 과밀 | `docs/` 4종 신설 + README 재작성 (완료) |
| 운영 기록 | `tasks/` (STATUS.md + 완료 카드 32장, 진행 0건) | 완료 상태 | 종료된 기록이 루트 점유 | `docs/archive/tasks/`로 `git mv` (완료) |

## 3. 전면 재구성(`common/`+`platforms/`)을 하지 않은 근거

`common/{instructions,skills,...}` + `platforms/{codex,claude-code,...}` + `scripts/` 형태의 전면 재구성을 검토했고, **채택하지 않았다**.

1. **공통/플랫폼 분리는 이미 달성돼 있다.** 스킬은 전부 플랫폼 중립이고(사실상 전부 `common/`감), 글로벌 지침은 `common.md`+델타로 이미 분리돼 있다. 디렉터리 이름만 바꾸는 이동이 된다.
2. **플랫폼 종속 파일은 위치가 강제된다.**
   - `.github/agents/*.agent.md`: GitHub Copilot 코딩 에이전트가 요구하는 고정 경로. `platforms/github-copilot/`로 옮기면 동작하지 않는다.
   - `skills/*/agents/codex.yaml`: Codex가 스킬 디렉터리 안 동봉을 요구하는 UI 메타데이터. 분리하면 동작하지 않고, CI `agents-integrity` 검사도 이 경로를 전제한다.
   - 즉 `platforms/`를 만들어도 정작 플랫폼 종속 파일 2종은 담을 수 없어 반쪽짜리가 된다.
3. **이동 비용 대비 이득이 없다.** 설치기 2종, 테스트(대상 경로·`$REPO_ROOT` 참조 다수), CI 워크플로 2종(`additional_files`, `run:`)이 현재 경로를 참조한다. 전면 이동은 이들 전부를 수정하는 churn만 만들고 도구 동작은 그대로다.
4. **단순함이 목표에 부합한다.** "사람이 직접 수정하기 쉬운 구조"와 "자동화보다 이해 가능한 구조"라는 운영 원칙에는, 계층을 늘리는 것보다 루트에서 한눈에 보이는 현 구조 + 좋은 문서가 낫다.

같은 이유로 `templates/` 디렉터리도 두지 않았다. 스킬 스켈레톤은 [docs/extending.md](docs/extending.md)의 인라인 코드블록으로 충분하고, `skills/` 안의 템플릿 폴더는 설치기가 실제 스킬로 오인한다.

## 4. 이번 정리에서 수행한 변경 (2026-07-15)

| 변경 | 내용 |
|------|------|
| `bootstrap.sh` 신설 | 설치 2종 + doctor 2종 일괄 실행. `--force`는 스킬 설치기에만 전달. CI shellcheck 대상과 `MERGE_REQUIREMENTS.md` M-1.1에 추가, 테스트 14번(`test_bootstrap_smoke`) 추가 |
| `docs/` 신설 | [concepts.md](docs/concepts.md)(개념 구분·의도적 부재 항목), [platform-mapping.md](docs/platform-mapping.md)(파일→도구 경로 매핑, Copilot 공백), [device-setup.md](docs/device-setup.md)(새 기기 절차·doctor 해석), [extending.md](docs/extending.md)(스킬/타깃/델타 추가 가이드) |
| `tasks/` 아카이브 | `git mv tasks docs/archive/tasks` (이력 보존). CI `tasks-policy` 잡 제거, M-1.4 은퇴, PR 템플릿의 카드 체크리스트 제거, `.github/agents/README.md` 다이어그램 일반화 |
| stale 참조 수정 | `skills/paced-explainer/SKILL.md`의 구 설치 경로 서술을 리포 직결 심링크 모델로 갱신 |
| README 재작성 | 정확한 구성 트리 + 간결한 진입점으로 축소, 상세 내용은 docs/로 이동 |
| 위생 | untracked `.DS_Store` 삭제 |

설치기 2종과 `global-instructions/` 본문, 스킬 본문(경로 서술 1건 제외), 완료 카드 32장은 변경하지 않았다.

## 5. 후속 작업

- [x] **Copilot 글로벌 지침 경로 검증 (2026-07-15)**: GitHub Copilot CLI `~/.copilot/copilot-instructions.md`가 공식 지원됨을 확인. `global-instructions/copilot.md` 신설, `install-global-instructions.sh`의 `TARGETS`에 4번째 엔트리 추가, 테스트 갱신, [docs/platform-mapping.md](docs/platform-mapping.md) 외부 문서 링크 추가. **VS Code / JetBrains / 웹 Copilot Chat에는 글로벌 지침 파일 메커니즘이 없음** — 그 부분은 의도적 공백으로 유지.
- [x] **CI `agents-integrity` 강화 (2026-07-15)**: `skills/*/SKILL.md`가 있는 모든 스킬에 대해 `agents/codex.yaml` 존재를 검사하는 루프로 교체. 옛 `agents/openai.yaml` 부재도 함께 검사. [docs/extending.md](docs/extending.md)의 후속 작업 주석도 갱신.
- [ ] **CI에 macOS 러너 추가 검토**: 현재 `ubuntu-latest`만 실행. bash 3.2/macOS 특이 동작은 로컬에서만 검증되고 있다.
- [ ] **오래된 병렬 브랜치 정리**: 1차 사이클의 `claude`, `codex`, `m3`, `total`, `develop`, `chore/consolidate-local-skills` — 머지 완료분은 삭제 검토.
- [ ] **훅/MCP 도입 시 설계 선행**: 도입하게 되면 도구별 설정 포맷 매핑 문서를 먼저 작성 ([docs/concepts.md](docs/concepts.md)의 도입 기준 참조).
