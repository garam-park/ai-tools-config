# 구조와 개념

이 문서는 리포가 관리하는 자산의 종류와, AI 코딩 도구 생태계의 개념(스킬·커맨드·에이전트·훅·MCP·플러그인) 중 무엇을 채택했고 무엇을 의도적으로 두지 않았는지 설명한다.

## 리포가 관리하는 세 자산군

| 자산군 | 위치 | 성격 |
|--------|------|------|
| 스킬 | `skills/<name>/` | 플랫폼 중립 `SKILL.md` (frontmatter는 `name`+`description`만) + Codex 전용 UI 메타데이터 `agents/codex.yaml`. 설치기가 도구별 스킬 경로에 심볼릭 링크를 만든다. |
| 글로벌 지침 | `global-instructions/` | 모든 도구 공통 `common.md` + 도구별 델타(`claude.md`, `codex.md`, `opencode.md`). 설치 시 common+델타를 결합해 각 도구의 지침 파일로 렌더링한다. |
| Copilot 역할 에이전트 | `.github/agents/*.agent.md` | GitHub Copilot 코딩 에이전트의 역할 규약 4종. GitHub이 이 경로를 요구하므로 설치 대상이 아니며 리포에 커밋된 상태 그대로 동작한다. |

도구별 설치 경로는 [platform-mapping.md](platform-mapping.md) 참조.

## 개념 구분과 채택 여부

| 개념 | 정의 | 이 리포에서의 상태 | 도입 기준 |
|------|------|--------------------|-----------|
| 스킬 (Skills) | `SKILL.md` 기반 재사용 워크플로. 도구가 설명을 읽고 자동/명시 트리거한다. | **채택** — 6종 (`inp-*` 5종 + `paced-explainer`) | 여러 도구에서 같은 절차를 반복할 때 |
| 커맨드 (Slash commands) | `/명령` 형태의 프롬프트 단축. 도구별 포맷이 서로 다르다. | **의도적 부재** — 스킬의 자동 트리거와 `agents/codex.yaml`의 `default_prompt`로 충분 | 인자 치환이 필요한 짧은 반복 프롬프트가 생길 때 |
| 서브에이전트 (Subagents) | 역할별 별도 컨텍스트로 실행되는 에이전트 (예: Claude Code의 `~/.claude/agents/`) | **의도적 부재** — `.github/agents/`의 Copilot 역할 규약과는 **별개 개념**이니 혼동 주의 | 특정 역할(리뷰어·테스터 등)을 도구 안에서 분리 실행하고 싶을 때 |
| 훅 (Hooks) | 작업 전후 자동 실행되는 검증·포맷·로그 스크립트 (도구 설정 파일에 등록) | **의도적 부재** — 도구별 설정 포맷(settings.json 등) 동기화 설계가 선행돼야 함 | 강제 자동화(커밋 전 포맷, 위험 명령 차단)가 필요할 때 |
| MCP | 외부 도구(Notion, DB 등)를 표준 프로토콜로 연결 | **의도적 부재** — 도구별 MCP 설정 포맷이 달라 동기화 비용이 큼. Notion 연동은 각 도구의 내장 통합 또는 `skills/inp-start-task/scripts/notion_task.py`(REST 직접 호출)로 대체 | 여러 도구에서 같은 외부 연결을 반복 설정하게 될 때 |
| 플러그인 (Plugins) | 스킬·커맨드·훅을 묶어 배포하는 패키지 (도구별 마켓플레이스 포맷) | **의도적 부재** — 이 리포 자체가 심볼릭 링크 설치 방식으로 그 역할을 함 | 타인에게 배포할 필요가 생길 때 |
| 하네스 (Harness) | 설치·검증·동기화 스크립트와 테스트 | **채택** — `bootstrap.sh`, 설치기 2종(`install`/`doctor`/`--force`), `tests/installers_test.sh`, CI 2종 | — |

## 설계 결정: 전면 재구성을 하지 않은 이유

`common/` + `platforms/` 식 전면 재구성 대신 현 구조를 유지하는 결정과 그 상세 근거는 루트의 [ARCHITECTURE-REVIEW.md](../ARCHITECTURE-REVIEW.md)에 기록되어 있다. 요약:

1. 스킬은 이미 플랫폼 중립이고, 글로벌 지침은 이미 common+델타 구조다.
2. 플랫폼 종속 파일은 위치가 강제된다 — `.github/agents/`(GitHub 고정 경로), `skills/*/agents/codex.yaml`(Codex가 스킬 디렉터리 동봉 요구).
3. 이동하면 설치기·테스트·CI의 경로 참조만 대량 수정될 뿐 기능적 이득이 없다.

새 자산을 추가할 때는 [extending.md](extending.md)를 따른다.
