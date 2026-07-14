# garam-park/ai-tools-config

개인용 AI 코딩 도구 설정 묶음. Claude Code, GitHub Copilot, Codex, OpenCode에서 공통 스킬을 사용하고, 도구별 글로벌 지침을 안전하게 동기화한다.

## 구성

```text
ai-tools-config/
├── install-skills.sh                          # 4개 도구에 스킬 심볼릭 링크 생성
├── install-global-instructions.sh             # 공통 + 도구별 글로벌 지침 조립
├── global-instructions/
│   ├── common.md                              # 모든 도구 공통 지침
│   ├── claude.md                              # Claude Code 전용 델타
│   ├── codex.md                               # Codex 전용 델타
│   └── opencode.md                            # OpenCode 전용 델타
├── skills/
│   └── paced-explainer/
│       ├── SKILL.md
│       ├── agents/
│       │   ├── README.md
│       │   └── codex.yaml
│       └── references/
│           └── depth-patterns.md
├── tests/
│   └── installers_test.sh
├── tasks/                                     # 추적되는 작업 카드와 상태 보드
├── .github/workflows/shell.yml                # ShellCheck + 설치 테스트 CI
├── .gitignore
└── README.md
```

## 새 머신에서 사용하기

> 전제: macOS 또는 Linux 같은 Unix 환경이 필요하다. Windows에서는 WSL을 권장하며, Git Bash를 쓸 경우에도 `ln -s`가 실제 심볼릭 링크를 만들 수 있어야 한다. `bash`, `rsync`, `chmod`가 설치되어 있어야 한다.

```bash
# 1) 리포 clone
git clone git@github.com:garam-park/ai-tools-config.git ~/ai-tools-config

# 2) 공통 스킬 원본과 설치 스크립트 준비
mkdir -p ~/.local/share/skills
rsync -a ~/ai-tools-config/skills/ ~/.local/share/skills/
cp ~/ai-tools-config/install-skills.sh ~/.local/share/skills/install-skills.sh
chmod +x ~/.local/share/skills/install-skills.sh

# 3) 네 도구의 개인 스킬 경로에 심볼릭 링크 생성
bash ~/.local/share/skills/install-skills.sh

# 4) 공통 지침과 도구별 지침 동기화
bash ~/ai-tools-config/install-global-instructions.sh
```

`rsync`에는 `--delete`를 사용하지 않으므로 `~/.local/share/skills/`의 로컬 전용 스킬이나 설치 스크립트가 삭제되지 않는다. 제거된 리포 스킬의 도구별 심볼릭 링크는 설치 스크립트의 manifest가 관리 링크인지 확인한 뒤 정리한다.

## 스킬 추가하기

1. `skills/<name>/` 폴더를 만들고 그 안에 `SKILL.md`를 작성한다.
2. 위 설치 절차의 2~3단계를 다시 실행한다.
3. `install-skills.sh`는 `SKILL.md`가 있는 폴더만 원본 스킬로 인식한다.

실제 파일이나 디렉토리가 대상 경로에 이미 있으면 덮어쓰거나 삭제하지 않고 경고한다 (`--force` 옵션으로 백업 후 강제 교체 가능). 기존 심볼릭 링크만 안전하게 교체하며, 일부 링크 처리에 실패해도 나머지를 계속 시도한 뒤 비정상 종료한다.

## 동기화되는 도구

공식 Personal 스킬 경로에 맞춰 네 도구를 네 경로에 연결한다. VS Code의 Copilot은 `~/.claude/skills`도 호환 경로로 읽지만, 도구 간 소유권을 명확히 하기 위해 Copilot 전용 표준 경로를 사용한다.

| 도구 | 개인 스킬 경로 | 스크립트 소스 | 비고 |
|------|----------------|---------------|------|
| Claude Code | `~/.claude/skills/` | `TARGETS[0]` | |
| GitHub Copilot | `~/.copilot/skills/` | `TARGETS[1]` | VS Code는 `~/.claude/skills/`도 지원 |
| Codex | `~/.codex/skills/` | `TARGETS[2]` | |
| OpenCode | `~/.config/opencode/skills/` | `TARGETS[3]` | |

외부 경로는 다음 공식 문서와 플러그인 원문을 기준으로 확인했다.

- GitHub Copilot Personal 스킬: [GitHub Docs — About agent skills](https://docs.github.com/en/copilot/concepts/agents/about-agent-skills)
- VS Code의 호환 Personal 스킬 경로: [VS Code — Use Agent Skills](https://code.visualstudio.com/docs/agent-customization/agent-skills)
- OpenCode 스킬과 글로벌 지침: [OpenCode — Agent Skills](https://opencode.ai/docs/skills), [OpenCode — Rules](https://opencode.ai/docs/rules)
- oh-my-openagent 사용자 설정: [Configuration Reference](https://github.com/code-yeongyu/oh-my-openagent/blob/dev/docs/reference/configuration.md)

## `install-skills.sh` 동작 방식

1. 스크립트가 있는 폴더(`~/.local/share/skills/`)에서 `SKILL.md`가 있는 하위 폴더를 찾는다.
2. 네 대상 경로를 준비하고 각 스킬의 심볼릭 링크를 만든다.
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

## 테스트

테스트는 임시 `HOME`만 사용하며 실제 사용자 설정을 변경하지 않는다.

```bash
bash tests/installers_test.sh
shellcheck install-skills.sh install-global-instructions.sh tests/installers_test.sh
```

GitHub Actions에서도 두 검증을 모든 push와 pull request에 실행한다.

## 작업 카드 정책

`tasks/`의 `001.todo`, `002.done`, `STATUS.md`는 리포 운영 기록으로 함께 추적한다. 리포를 fork하거나 개인 설정만 재사용하는 경우 작업 카드는 삭제해도 설치 동작에는 영향이 없다.
