# garam-park/ai-tools-config

개인용 AI 코딩 도구 설정 묶음. Claude Code, GitHub Copilot, Codex, OpenCode, Hermes Agent에서 공통 스킬을 사용하고, 도구별 글로벌 지침을 안전하게 동기화한다.

## 빠른 시작
> 전제: macOS 또는 Linux 같은 Unix 환경이 필요하다. Windows에서는 WSL을 권장하며, Git Bash를 쓸 경우에도 `ln -s`가 실제 심볼릭 링크를 만들 수 있어야 한다. `bash`가 설치되어 있어야 한다.

```bash
git clone git@github.com:garam-park/ai-tools-config.git ~/ai-tools-config
cd ~/ai-tools-config

# 1) 권장: 한 번에 설치 + 점검
./bootstrap.sh

# 2) 수동 실행: 스킬 링크 설치
./install-skills.sh

# 3) 수동 실행: 글로벌 지침 동기화
./install-global-instructions.sh
```

`bootstrap.sh`는 스킬 설치 → 글로벌 지침 동기화 → 두 `doctor` 검사를 순서대로 실행한다. 전제조건과 doctor 출력 해석은 [docs/device-setup.md](docs/device-setup.md) 참조.

설치 상태만 점검하려면:

```bash
./install-skills.sh doctor              # 스킬 링크 상태 점검
./install-global-instructions.sh doctor # 글로벌 지침 동기화 상태 점검
```

두 doctor 모두 아무것도 변경하지 않으며, 문제가 있으면 종료 코드 1을 반환한다.

## 구성

```text
ai-tools-config/
├── README.md
├── ARCHITECTURE-REVIEW.md             # 구조 리뷰 보고서 (2026-07)
├── bootstrap.sh                       # 설치 2종 + doctor 2종 일괄 실행
├── install-skills.sh                  # 스킬 심볼릭 링크 설치/doctor
├── install-global-instructions.sh     # 공통+델타 글로벌 지침 조립/doctor
├── docs/
│   ├── concepts.md                    # 구조·개념, 의도적으로 없는 것들
│   ├── platform-mapping.md            # 파일 → 도구별 설치 경로 매핑
│   ├── device-setup.md                # 새 기기 설정, doctor 해석
│   ├── inp-workflow.md                # Innopam inp-* 스킬 흐름과 경계
│   ├── extending.md                   # 스킬/타깃/델타 추가 가이드
│   └── archive/tasks/                 # 완료된 작업 카드 기록 (fork 시 삭제 무관)
├── global-instructions/               # common.md + claude.md/codex.md/opencode.md
├── skills/                            # 각 스킬: SKILL.md + agents/codex.yaml (+부속)
│   ├── inp-analyze-task/
│   ├── inp-create-pr/
│   ├── inp-review-pr/
│   ├── inp-spec-task/
│   ├── inp-start-task/                # + scripts/notion_task.py
│   └── paced-explainer/               # + references/depth-patterns.md
├── tests/
│   └── installers_test.sh
├── .github/
│   ├── workflows/                     # shell.yml, merge-requirements.yml
│   ├── agents/                        # Copilot 역할 에이전트 4종 (GitHub 고정 경로)
│   ├── MERGE_REQUIREMENTS.md
│   └── PULL_REQUEST_TEMPLATE.md
└── .gitignore
```

`inp-` 접두사는 Innopam 전용 작업·PR 워크플로를 뜻한다. 범용 스킬과 이름이 충돌하지 않도록 이노팸의 `TSK-*` 작업을 다루는 스킬에만 사용한다.

심볼릭 링크가 리포 작업 트리를 직접 가리키므로 `git pull`만 하면 스킬 내용이 즉시 반영된다. 설치기 재실행은 스킬을 추가·삭제했을 때만 필요하다.

Claude Code는 전용 개인 경로를 사용하고, Codex·GitHub Copilot·OpenCode는 세 도구가 모두 공식 지원하는 공통 Agent Skills 경로를 사용한다. Hermes Agent는 자체 설정(`skills.external_dirs`)으로 같은 공통 경로를 읽는다. 같은 스킬을 여러 탐색 경로에 중복 설치하지 않는다.

| 도구 | 개인 스킬 경로 | 스크립트 소스 | 비고 |
|------|----------------|---------------|------|
| Claude Code | `~/.claude/skills/` | `TARGETS[0]` | Claude 전용 경로 |
| Codex | `~/.agents/skills/` | `TARGETS[1]` | 공통 Agent Skills 경로 |
| GitHub Copilot | `~/.agents/skills/` | `TARGETS[1]` | 공통 Agent Skills 경로 |
| OpenCode | `~/.agents/skills/` | `TARGETS[1]` | 공통 Agent Skills 경로 |
| Hermes Agent | `~/.agents/skills/` | `TARGETS[1]` | `skills.external_dirs` 설정 필요 (아래 참고) |

### Hermes Agent 연동

Hermes Agent(Nous Research)는 기본적으로 `~/.hermes/skills/`만 읽지만, agentskills.io 규격을 지원하며 설정으로 외부 스킬 디렉토리를 추가할 수 있다. 링크를 또 만들지 않고 `~/.hermes/config.yaml`에 공통 Agent Skills 경로를 한 번만 등록한다.

```yaml
skills:
  external_dirs:
    - ~/.agents/skills
```

등록 후 `hermes skills list` 또는 세션에서 `/skills`로 스킬이 보이는지 확인한다.

> 주의: Hermes는 자기 학습 루프로 스킬 파일을 수정할 수 있다. 외부 디렉토리가 쓰기 가능하면 이 리포 작업 트리의 스킬 원본까지 고쳐질 수 있는데, 변경은 `git status`로 드러나므로 원치 않으면 되돌리면 된다. 원본을 보호하려면 스킬 디렉토리를 읽기 전용으로 두라는 것이 Hermes 공식 문서의 권고다.

외부 경로는 다음 공식 문서와 플러그인 원문을 기준으로 확인했다.

- 공통 Agent Skills 규격: [Agent Skills — Specification](https://agentskills.io/specification)
- Codex Personal 스킬: [OpenAI — Build skills](https://learn.chatgpt.com/docs/build-skills.md)
- Claude Code Personal 스킬: [Claude Code Docs — Extend Claude with skills](https://code.claude.com/docs/en/slash-commands)
- GitHub Copilot Personal 스킬: [GitHub Docs — About agent skills](https://docs.github.com/en/copilot/concepts/agents/about-agent-skills)
- OpenCode 스킬과 글로벌 지침: [OpenCode — Agent Skills](https://opencode.ai/docs/skills), [OpenCode — Rules](https://opencode.ai/docs/rules)
- Hermes Agent 스킬과 외부 디렉토리: [Hermes Agent — Skills System](https://github.com/NousResearch/hermes-agent/blob/main/website/docs/user-guide/features/skills.md)
- oh-my-openagent 사용자 설정: [Configuration Reference](https://github.com/code-yeongyu/oh-my-openagent/blob/dev/docs/reference/configuration.md)

## `install-skills.sh` 동작 방식

1. 스크립트 옆의 `skills/`에서 `SKILL.md`가 있는 하위 폴더를 찾는다.
2. Claude 전용 경로와 공통 Agent Skills 경로를 준비하고 각 스킬의 심볼릭 링크를 만든다.
3. 실제 파일·디렉토리와 충돌하면 사용자 항목을 보존하고 경고한다 (`--force` 시 `.bak.<timestamp>` 백업 후 교체).
4. `${XDG_STATE_HOME:-~/.local/state}/ai-tools-config/install-skills.manifest`에 성공한 관리 링크를 기록한다.
5. 다음 실행에서 원본이 사라진 관리 링크만 정리한다. 사용자가 바꾼 항목은 보존한다.

## 글로벌 지침 동기화

`install-global-instructions.sh`는 `global-instructions/common.md` 뒤에 도구별 델타를 결합한다.

| 도구 | 생성 경로 | 결합 소스 |
|------|-----------|-----------|
| Claude Code | `~/.claude/CLAUDE.md` | `common.md` + `claude.md` |
| Codex | `~/.codex/AGENTS.md` | `common.md` + `codex.md` |
| OpenCode | `~/.config/opencode/AGENTS.md` | `common.md` + `opencode.md` |

마커 없는 기존 파일은 `.bak.<timestamp>`로 백업한다. 자동 생성 파일은 백업 없이 갱신한다. 대상이 심볼릭 링크면 링크 자체를 보존하고 실제 타깃을 백업·갱신한다 (순환 링크 탐지 포함, 최대 40 depth). dangling 심링크는 dest 위치에 직접 쓴다. 임시 파일은 대상과 같은 디렉토리에 만든 뒤 원자적으로 교체한다.

## 문서

- [docs/concepts.md](docs/concepts.md) — 스킬·커맨드·에이전트·훅·MCP·플러그인 개념 구분과 이 리포의 채택 여부
- [docs/inp-workflow.md](docs/inp-workflow.md) — Innopam `inp-*` 스킬의 단계별 흐름, 경계, 종료 지점
- [docs/platform-mapping.md](docs/platform-mapping.md) — 리포 파일이 도구별로 어디에 설치되는지, 알려진 공백
- [docs/device-setup.md](docs/device-setup.md) — 새 기기 설정 절차, doctor 출력 해석, 비밀값 주입
- [docs/extending.md](docs/extending.md) — 새 스킬/도구 타깃/지침 델타 추가 방법
- [ARCHITECTURE-REVIEW.md](ARCHITECTURE-REVIEW.md) — 구조 진단 결과와 설계 결정 근거 (2026-07-15)

## 테스트

테스트는 임시 `HOME`만 사용하며 실제 사용자 설정을 변경하지 않는다.

```bash
bash tests/installers_test.sh
shellcheck --severity=warning bootstrap.sh install-skills.sh install-global-instructions.sh tests/installers_test.sh
```

GitHub Actions에서도 두 검증을 모든 push와 pull request에 실행한다. 머지 조건은 [.github/MERGE_REQUIREMENTS.md](.github/MERGE_REQUIREMENTS.md) 참조.
