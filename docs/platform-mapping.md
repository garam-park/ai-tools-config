# 플랫폼 매핑

리포의 어떤 파일이 어느 도구의 어느 경로로 설치되는지 정리한다.

## 스킬

Claude Code는 전용 개인 경로를 사용하고, Codex·GitHub Copilot·OpenCode는 세 도구가 모두 공식 지원하는 공통 Agent Skills 경로를 사용한다. 같은 스킬을 여러 탐색 경로에 중복 설치하지 않는다.

| 도구 | 개인 스킬 경로 | 스크립트 소스 | 비고 |
|------|----------------|---------------|------|
| Claude Code | `~/.claude/skills/` | `TARGETS[0]` | Claude 전용 경로 |
| Codex | `~/.agents/skills/` | `TARGETS[1]` | 공통 Agent Skills 경로 |
| GitHub Copilot | `~/.agents/skills/` | `TARGETS[1]` | 공통 Agent Skills 경로 |
| OpenCode | `~/.agents/skills/` | `TARGETS[1]` | 공통 Agent Skills 경로 |

### `install-skills.sh` 동작 방식

1. 스크립트 옆의 `skills/`에서 `SKILL.md`가 있는 하위 폴더를 찾는다.
2. Claude 전용 경로와 공통 Agent Skills 경로를 준비하고 각 스킬의 심볼릭 링크를 만든다. 링크는 리포 작업 트리를 직접 가리키므로 `git pull`만으로 스킬 내용이 반영된다.
3. 실제 파일·디렉토리와 충돌하면 사용자 항목을 보존하고 경고한다 (`--force` 시 `.bak.<timestamp>` 백업 후 교체).
4. `${XDG_STATE_HOME:-~/.local/state}/ai-tools-config/install-skills.manifest`에 성공한 관리 링크를 기록한다.
5. 다음 실행에서 원본이 사라진 관리 링크만 정리한다. 사용자가 바꾼 항목은 보존한다.

## 글로벌 지침

`install-global-instructions.sh`는 `global-instructions/common.md` 뒤에 도구별 델타를 결합해 각 도구의 지침 파일로 렌더링한다.

| 도구 | 생성 경로 | 결합 소스 |
|------|-----------|-----------|
| Claude Code | `~/.claude/CLAUDE.md` | `common.md` + `claude.md` |
| Codex | `~/.codex/AGENTS.md` | `common.md` + `codex.md` |
| OpenCode | `~/.config/opencode/AGENTS.md` | `common.md` + `opencode.md` |
| GitHub Copilot CLI | `~/.copilot/copilot-instructions.md` | `common.md` + `copilot.md` |

동작 규칙:

- 생성 파일에는 `AUTO-GENERATED-DO-NOT-EDIT` 마커가 들어간다. 마커 없는 기존 파일은 사용자 작성 파일로 간주해 `.bak.<timestamp>`로 백업한 뒤 교체한다. 자동 생성 파일은 백업 없이 갱신한다.
- 대상이 심볼릭 링크면 링크 자체를 보존하고 실제 타깃 파일을 백업·갱신한다 (순환 링크 탐지 포함, 최대 40 depth). dangling 심링크는 dest 위치에 직접 쓴다.
- 임시 파일은 대상과 같은 디렉토리에 만든 뒤 원자적으로 교체한다.

## Copilot 역할 에이전트

`.github/agents/*.agent.md` 4종(implementer·tester·documenter·ci-runner)은 GitHub Copilot 코딩 에이전트가 읽는 역할 규약이다. GitHub이 이 리포 내 경로를 요구하므로 **설치 대상이 아니며**, 커밋된 상태 그대로 동작한다. 운영 규약은 [.github/agents/README.md](../.github/agents/README.md) 참조.

## 알려진 공백: Copilot 글로벌 지침

GitHub Copilot의 표면별 사용자 전역 지침 지원은 표면에 따라 다르다.

- **VS Code / JetBrains / Visual Studio**: 전역 지침 파일 메커니즘 없음. 리포별 `.github/copilot-instructions.md`만 지원. 이 리포는 의도적으로 두지 않는다.
- **웹 Copilot Chat**: UI 텍스트박스 입력만. 파일 메커니즘 없음.
- **GitHub Copilot CLI**: `~/.copilot/copilot-instructions.md` 공식 지원. 2026-07-15에 검증되어 `install-global-instructions.sh`의 4번째 엔트리로 추가되었다 (`common.md` + `copilot.md` 결합).

참조:
- [GitHub Copilot CLI configuration directory](https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-config-dir-reference)
- [Adding personal custom instructions](https://docs.github.com/en/copilot/how-tos/configure-custom-instructions/add-personal-instructions)
- [About customizing GitHub Copilot responses](https://docs.github.com/en/copilot/concepts/prompting/response-customization)

## 외부 공식 문서

외부 경로는 다음 공식 문서와 플러그인 원문을 기준으로 확인했다.

- 공통 Agent Skills 규격: [Agent Skills — Specification](https://agentskills.io/specification)
- Codex Personal 스킬: [OpenAI — Build skills](https://learn.chatgpt.com/docs/build-skills.md)
- Claude Code Personal 스킬: [Claude Code Docs — Extend Claude with skills](https://code.claude.com/docs/en/slash-commands)
- GitHub Copilot Personal 스킬: [GitHub Docs — About agent skills](https://docs.github.com/en/copilot/concepts/agents/about-agent-skills)
- GitHub Copilot CLI 사용자 설정: [Configuration directory reference](https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-config-dir-reference)
- OpenCode 스킬과 글로벌 지침: [OpenCode — Agent Skills](https://opencode.ai/docs/skills), [OpenCode — Rules](https://opencode.ai/docs/rules)
- oh-my-openagent 사용자 설정: [Configuration Reference](https://github.com/code-yeongyu/oh-my-openagent/blob/dev/docs/reference/configuration.md)
