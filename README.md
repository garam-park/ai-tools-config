# garam-park/ai-tools-config

개인용 AI 코딩 도구 설정 묶음. Claude Code, GitHub Copilot (VS Code), Codex, OpenCode 네 도구에서 동일하게 동작하는 **스킬**과 **글로벌 지침**, 그리고 이를 각 도구 경로에 뿌려 주는 **동기화 스크립트**를 관리한다.

> **전제**: Unix-like 환경 필요 (macOS / Linux, 또는 Windows에서는 WSL/Git Bash).
> 설치 스크립트는 bash 전용(`[[ ]]`, `BASH_SOURCE`, `declare -a` 등)이며 `ln -s` 심볼릭 링크가 동작하는 환경이어야 한다.

## 구성

```text
ai-tools-config/
├── install-skills.sh                          # 4개 도구 경로에 스킬 심볼릭 링크 생성 (멱등)
├── install-global-instructions.sh             # 각 도구 경로에 글로벌 지침 동기화 (멱등)
├── global-instructions/
│   ├── common.md                              # 모든 도구 공통 지침
│   ├── claude.md                              # Claude Code 델타
│   ├── codex.md                               # Codex 델타
│   └── opencode.md                            # OpenCode 델타
├── skills/
│   └── paced-explainer/                       # 4개 도구 공통 스킬
│       ├── SKILL.md
│       ├── agents/
│       │   ├── README.md
│       │   └── codex.yaml
│       └── references/depth-patterns.md
├── .gitignore
└── README.md
```

## 새 머신에서 사용하기

```bash
# 1) 리포 clone
git clone git@github.com:garam-park/ai-tools-config.git ~/ai-tools-config

# 2) 스킬을 실제 위치에 동기화 (--delete 없이: 로컬 전용 스킬/스크립트 보존)
rsync -a ~/ai-tools-config/skills/ ~/.local/share/skills/

# 3) 스크립트를 스킬 폴더 옆에 두고 실행 권한 부여
#    install-skills.sh는 "자기 폴더"를 원본으로 보므로 스킬 폴더와 같은 위치에 있어야 한다
cp ~/ai-tools-config/install-skills.sh ~/.local/share/skills/install-skills.sh
chmod +x ~/.local/share/skills/install-skills.sh

# 4) 도구별 경로에 스킬 심볼릭 링크 생성
bash ~/.local/share/skills/install-skills.sh

# 5) 글로벌 지침 동기화 (스크립트는 클론 위치에서 바로 실행)
bash ~/ai-tools-config/install-global-instructions.sh
```

`install-global-instructions.sh`는 `common.md` + 도구별 델타를 결합해 각 도구의 글로벌 지침 경로
(`~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, `~/.config/opencode/AGENTS.md`)로 동기화한다.
자동 생성 마커가 없는 기존(사용자 작성) 파일은 덮어쓰기 전에 `.bak.<timestamp>`로 백업한다.

## 스킬 추가하기

1. `skills/<name>/` 폴더를 만들고 `SKILL.md` 작성
2. 위 "새 머신에서 사용하기" 2–4단계로 동기화하면 `install-skills.sh`가 도구별 경로
   (`~/.claude/skills`, `~/.copilot/skills`, `~/.codex/skills`, `~/.config/opencode/skills`)에 심볼릭 링크를 만들어 줌
3. 변경 후 `git add . && git commit && git push`

## 동기화되는 도구

`install-skills.sh`는 4개 도구를 각각의 개인 스킬 경로로 동기화한다 (4개 도구 → 4개 경로).

| 도구 | 경로 | 동기화 코드 | 비고 |
| --- | --- | --- | --- |
| Claude Code | `~/.claude/skills/` | `TARGETS[0]` | — |
| GitHub Copilot (VS Code) | `~/.copilot/skills/` | `TARGETS[1]` | Claude Code와 별개 경로 |
| Codex | `~/.codex/skills/` | `TARGETS[2]` | — |
| OpenCode | `~/.config/opencode/skills/` | `TARGETS[3]` | — |

> Copilot **CLI**는 `~/.claude/skills`도 검색하지만, VS Code 개인 스킬 기본 경로는 `~/.copilot/skills`다.

## `install-skills.sh` 동작 방식

1. 스크립트가 있는 폴더(`~/.local/share/skills/`)를 원본으로 본다
2. `SKILL.md`가 있는 하위 폴더만 스킬로 인식한다
3. 위 표의 도구별 경로(`TARGETS`)를 순회하며 각 스킬에 대해 심볼릭 링크를 만든다
4. 기존 항목이 스크립트가 만든 심링크면 교체하고, 사용자가 만든 실제 파일/디렉토리는 건드리지 않는다
   (강제 교체가 필요하면 `--force`: 백업 후 교체)
5. 여러 번 실행해도 안전 (멱등)

## 테스트

설치 스크립트는 실제 홈 디렉토리를 건드리지 않고 임시 `HOME`에서 검증한다.

```bash
bash tests/run.sh
```

- 심볼릭 링크가 동작하는 환경(WSL / Linux / macOS)에서 실행한다. 링크 미지원 환경에서는 자동 스킵된다.
- GitHub Actions(`.github/workflows/ci.yml`)가 push/PR마다 ShellCheck + 위 설치 테스트를 실행한다.

## 작업 카드 (tasks/)

`tasks/` 디렉토리의 작업 카드(`001.todo`, `002.done`)도 이 리포에 함께 추적된다.
개인 작업 메모이므로, 이 리포를 fork/clone한 경우 작업 카드는 자유롭게 삭제해도 무방하다.
