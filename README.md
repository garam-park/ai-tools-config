# garam-park/ai-tools-config

개인용 AI 코딩 도구 스킬 묶음. Claude Code, GitHub Copilot (VS Code), Codex, OpenCode 네 도구에서 동일하게 동작하는 스킬과 글로벌 지침, 그리고 동기화 스크립트를 관리한다.

> **전제 환경**: Unix-like 시스템 (macOS / Linux). Windows에서는 **WSL** 또는 **Git Bash** 등 `ln -s` 심볼릭 링크가 동작하는 환경을 사용해야 한다. 스크립트는 bash 전용 문법(`[[ ]]`, `BASH_SOURCE`, `${var%/}`, `declare -a` 등)을 사용한다.
>
> **참고**: `tasks/` 디렉토리의 작업 카드(`001.todo`, `002.done`)도 추적 대상이다. 이 리포를 fork/clone한 경우, 작업 카드는 자유롭게 삭제해도 무방하다.

## 구성

```text
ai-tools-config/
├── install-skills.sh                          # 4개 도구에 스킬 심볼릭 링크 생성 (멱등, 보호 가드 포함)
├── install-global-instructions.sh             # 글로벌 지침(common + 도구별 델타) 동기화 + 자동 백업
├── skills/
│   └── paced-explainer/                       # 4개 도구 공통 스킬
│       ├── SKILL.md
│       ├── agents/
│       │   └── codex.yaml                     # Codex 인터페이스 메타
│       └── references/
│           └── depth-patterns.md
├── global-instructions/
│   ├── common.md                              # 4개 도구 공통 정책
│   ├── claude.md                              # Claude Code 델타
│   ├── codex.md                               # Codex 델타
│   └── opencode.md                            # OpenCode 델타
├── tests/
│   └── installer.bats                         # install-skills.sh / install-global-instructions.sh 동작 검증
├── .github/workflows/
│   └── ci.yml                                 # ShellCheck + bats 실행
├── .gitignore
└── README.md
```

## 새 머신에서 사용하기

```bash
# 1) 리포 clone
git clone git@github.com:garam-park/ai-tools-config.git ~/ai-tools-config

# 2) clone한 리포 자체를 원본 폴더로 사용해 install-skills.sh 를 1회 실행한다.
#    이미 리포가 source-of-truth 이므로 별도 rsync/cp 는 필요하지 않다.
#    (리포의 skills/ 가 곧 TARGETS 의 원본 폴더에 동기화된다.)
cd ~/ai-tools-config
chmod +x install-skills.sh
./install-skills.sh

# 3) 글로벌 지침 동기화
./install-global-instructions.sh
```

> **중요**: 리포의 `skills/` 폴더는 원본이며, `install-skills.sh`는 자기 폴더를 `SRC_DIR`로 인식해 세 도구 경로(`~/.claude/skills`, `~/.codex/skills`, `~/.config/opencode/skills`)에 심볼릭 링크를 만들어 준다. 별도로 `~/.local/share/skills`에 복사할 필요는 없다. 단, 그렇게 모사본을 별도로 두고 싶다면:
>
> ```bash
> rsync -a ~/ai-tools-config/skills/ ~/.local/share/skills/
> rsync -a ~/ai-tools-config/install-skills.sh ~/.local/share/skills/
> chmod +x ~/.local/share/skills/install-skills.sh
> bash ~/.local/share/skills/install-skills.sh
> ```
>
> ⚠️ 위 `--delete` 없는 rsync 는 의도된 동작이다. `--delete` 를 다시 켜면 사용자가 별도로 둔 로컬 스킬이 삭제될 수 있다.

## 스킬 추가하기

1. `skills/<name>/` 폴더를 만들고 `SKILL.md` 작성
2. `install-skills.sh`가 자동으로 `SKILL.md` 가 있는 폴더만 골라 4개 도구 경로(`~/.claude/skills`, `~/.codex/skills`, `~/.config/opencode/skills`)에 심볼릭 링크를 만들어 준다
3. 변경 후 `git add . && git commit && git push`

## 동기화되는 도구

4개 도구 — 단, 경로는 3개다 (Claude Code 와 GitHub Copilot 은 `~/.claude/skills` 를 공유한다).

| 도구 | 경로 | 동기화 코드 | 비고 |
|------|------|------------|------|
| Claude Code | `~/.claude/skills/` | `install-skills.sh` TARGETS[0] | |
| GitHub Copilot (VS Code) | `~/.claude/skills/` | TARGETS[0] 공유 | Claude Code 와 동일 위치 |
| Codex | `~/.codex/skills/` | `install-skills.sh` TARGETS[1] | |
| OpenCode | `~/.config/opencode/skills/` | `install-skills.sh` TARGETS[2] | |

스크립트와 글로벌 지침 파일을 함께 보려면 [install-skills.sh](./install-skills.sh) 와 [install-global-instructions.sh](./install-global-instructions.sh) 의 헤더 주석과 TARGETS 배열을 참조한다.

## 글로벌 지침 동기화

`install-global-instructions.sh`는 `global-instructions/common.md`와 도구별 델타(`claude.md` / `codex.md` / `opencode.md`)를 결합해 각 도구의 글로벌 지침 경로로 동기화한다.

| 도구 | 글로벌 지침 경로 | 소스 |
|------|------------------|------|
| Claude Code | `~/.claude/CLAUDE.md` | `common.md` + `claude.md` |
| Codex | `~/.codex/AGENTS.md` | `common.md` + `codex.md` |
| OpenCode | `~/.config/opencode/AGENTS.md` | `common.md` + `opencode.md` |

- 동기화된 파일은 `<!-- AUTO-GENERATED-DO-NOT-EDIT -->` 마커로 시작한다.
- 마커가 없는 사용자가 만든 파일은 `.bak.<timestamp>` 백업 후 덮어쓴다.
- dest 가 심볼릭 링크면 링크 타깃 파일을 기준으로 동작한다 (사용자 링크 자체는 보존).

## `install-skills.sh` 동작 방식

1. 스크립트가 있는 폴더의 `skills/` 를 원본으로 본다
2. 3개 대상 경로를 순회하며 `SKILL.md` 가 있는 폴더만 심볼릭 링크로 만든다
3. 기존 항목이 **심볼릭 링크**면 그대로 교체한다
4. 기존 항목이 **실제 파일/디렉토리**면 보호하고 stderr 로 경고한다 (`--force` 옵션 시에만 백업 후 교체)
5. 멱등 — 여러 번 실행해도 결과 동일

## `tasks/` 추적 정책

이 리포에는 `tasks/` 디렉토리에 작업 카드가 함께 추적된다.

- `tasks/001.todo/total/<NN>-*.md` — 진행 중이거나 미착수 작업
- `tasks/002.done/total/<NN>-*.md` — 완료된 작업
- `tasks/STATUS.md` — 한눈에 보는 진행 보드

외부에서 clone 했다면 작업 카드는 자유롭게 삭제해도 된다.

## 테스트 & CI

```bash
# bats + tap 테스트 (별도 install 필요: brew install bats-core / apt install bats)
bats tests/installer.bats

# 셸 정적 검사
shellcheck install-skills.sh install-global-instructions.sh
```

PR / push 시 GitHub Actions `.github/workflows/ci.yml` 가 `shellcheck` 및 bats 테스트를 자동 실행한다.
