# 리포 레이아웃

이 리포의 파일은 성격이 다른 네 계층으로 나뉜다. 파일 이름이나 위치만으로는 계층이 드러나지 않는 항목이 있어서, 판별 기준과 계층별 목록을 여기에 고정한다.

자산의 *종류*(스킬·글로벌 지침·Copilot 역할 에이전트)는 [concepts.md](concepts.md), 배포 *경로*는 [platform-mapping.md](platform-mapping.md)를 따른다. 이 문서는 그 앞단인 "이 파일이 애초에 어느 계층인가"만 다룬다.

## 판별 기준

> **`install-skills.sh` / `install-global-instructions.sh`를 통해 `$HOME`으로 나가는가?**
>
> 나가면 **배포 자산**, 나가지 않으면 **이 리포 전용 설정**이다.

이름이 비슷해서 헷갈리는 대표 사례:

- `skills/` 는 배포 자산이고, `.agents/skills/` 와 `.claude/skills/` 는 이 리포 전용이다.
- `scripts/` 는 하네스가 아니라 이 리포 전용 MCP 런처다 ([scripts/README.md](../scripts/README.md)).
- `.env.tsk`(작업 대상 프로젝트 루트에서 `ntn-*` 스킬이 읽는 파일)의 템플릿은 리포 루트가 아니라
  `skills/ntn-start-task/references/env.tsk.example`에 둔다. 이 리포의 설정이 아니기 때문이다.

## 계층별 목록

### 1. 배포 자산 — `$HOME`으로 나가는 것

| 경로 | 내용 |
|------|------|
| `skills/` | 글로벌 배포 스킬 원본. `install-skills.sh`가 각 도구 경로에 심볼릭 링크를 만든다. |
| `global-instructions/` | `common.md` + 도구별 델타. `install-global-instructions.sh`가 결합해 렌더링한다. |

`skills/<name>/references/`, `skills/<name>/scripts/`, `skills/<name>/agents/` 는 스킬 디렉터리와 함께 통째로 링크되므로 같은 계층이다.

### 2. 설치 하네스 — 내보내는 도구

| 경로 | 내용 |
|------|------|
| `bootstrap.sh` | 설치 2종 + doctor 2종 일괄 실행 |
| `install-skills.sh` | 스킬 링크 install / uninstall / doctor |
| `install-global-instructions.sh` | 글로벌 지침 조립 install / uninstall / doctor |
| `tests/` | 격리 `HOME`으로 설치기를 검증 |
| `.github/workflows/` | shellcheck + 설치 테스트 + 머지 요건 CI |

### 3. 이 리포 전용 설정 — 여기서 작업할 때만 쓰는 것

**대부분 도구가 경로를 강제하므로 옮길 수 없다.** 옮기면 도구가 인식하지 못한다.

| 경로 | 읽는 도구 | 비고 |
|------|-----------|------|
| `AGENTS.md` | Codex, Copilot, OpenCode | 리포 작업 지침 |
| `.mcp.json` | Claude Code | 프로젝트 MCP 서버 |
| `.codex/config.toml` | Codex | 프로젝트 MCP 서버 |
| `.vscode/mcp.json` | VS Code GitHub Copilot | 프로젝트 MCP 서버. `.gitignore`에서 이 파일만 예외로 추적한다 |
| `opencode.json` | OpenCode | 프로젝트 MCP 서버 |
| `.omm` | `mcp-script-builder` | MCP 소유권·생성 파일 해시 매니페스트 |
| `scripts/mcp/<server>/` | 위 네 프로바이더 설정이 참조 | 런처와 `.env.example`. `.env`는 추적하지 않는다 |
| `.agents/skills/` | Codex, Copilot, OpenCode | 프로젝트 전용 스킬 원본 |
| `.claude/skills/` | Claude Code | `.agents/skills/`를 가리키는 상대 심볼릭 링크만 |
| `.github/agents/` | GitHub Copilot 코딩 에이전트 | 이 리포 PR 작업용 역할 규약. GitHub 고정 경로 |

### 4. 문서

`README.md`(진입점), `docs/`(상세), `ARCHITECTURE-REVIEW.md`(구조 결정 근거), `.github/MERGE_REQUIREMENTS.md`, `.github/PULL_REQUEST_TEMPLATE.md`.

## 새 파일을 추가할 때

1. 판별 기준으로 계층을 먼저 정한다.
2. 배포 자산이면 [extending.md](extending.md)의 절차를 따른다.
3. 이 리포 전용 설정이면 도구가 요구하는 경로에 두고, 위 3번 표에 한 줄 추가한다.
4. MCP 관련이면 `mcp-script-builder` 스킬을 거쳐 `.omm`에 기록되게 한다. 손으로 만들고 매니페스트를 비워두지 않는다.
