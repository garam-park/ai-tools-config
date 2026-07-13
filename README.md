# garam-park/ai-tools-config

개인용 AI 코딩 도구 스킬 묶음. Claude Code, GitHub Copilot (VS Code), Codex, OpenCode 네 도구에서 동일하게 동작하는 스킬과 동기화 스크립트를 관리한다.

## 구성

```
ai-tools-config/
├── install-skills.sh                          # 4개 도구에 스킬 심볼릭 링크 생성 (멱등)
├── skills/
│   └── paced-explainer/                       # 4개 도구 공통 스킬
│       ├── SKILL.md
│       ├── agents/openai.yaml
│       └── references/depth-patterns.md
├── .gitignore
└── README.md
```

## 새 머신에서 사용하기

```sh
# 1) 리포 clone
git clone git@github.com:garam-park/ai-tools-config.git ~/ai-tools-config

# 2) 스킬을 실제 위치에 동기화 (rsync --delete로 원본 동기화 유지)
rsync -a --delete ~/ai-tools-config/skills/ ~/.local/share/skills/

# 3) 스크립트 동기화
cp ~/ai-tools-config/install-skills.sh ~/.local/share/skills/install-skills.sh
chmod +x ~/.local/share/skills/install-skills.sh

# 4) 4개 도구 경로에 심볼릭 링크 생성
bash ~/.local/share/skills/install-skills.sh
```

## 스킬 추가하기

1. `skills/<name>/` 폴더를 만들고 `SKILL.md` 작성
2. `install-skills.sh`가 자동으로 4개 도구 경로(`~/.claude/skills`, `~/.codex/skills`, `~/.config/opencode/skills`)에 심볼릭 링크를 만들어 줌
3. 변경 후 `git add . && git commit && git push`

## 동기화되는 도구

| 도구 | 경로 |
|------|------|
| Claude Code | `~/.claude/skills/` |
| GitHub Copilot (VS Code) | `~/.claude/skills/` (Claude와 동일 위치 사용) |
| Codex | `~/.codex/skills/` |
| OpenCode | `~/.config/opencode/skills/` |

## `install-skills.sh` 동작 방식

1. 스크립트가 있는 폴더(`~/.local/share/skills/`)를 원본으로 본다
2. 4개 도구 경로를 순회하며 각 스킬 폴더에 대해 심볼릭 링크를 만든다
3. 기존 링크/파일이 있으면 제거 후 재생성 (멱등)
4. 여러 번 실행해도 안전