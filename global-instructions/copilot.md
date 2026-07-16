# GitHub Copilot 전용 지침

## 적용 범위

- 이 델타는 **GitHub Copilot CLI**(`~/.copilot/copilot-instructions.md`)에 적용된다. `install-global-instructions.sh`가 `common.md` + 이 파일을 결합해 생성한다.
- VS Code / JetBrains / Visual Studio / 웹 Copilot Chat에는 **사용자 전역(글로벌) 지침 파일 메커니즘이 없다**. 이 리포는 해당 표면에 글로벌 지침을 전송하지 않는다 (리포 단위 지침인 `.github/copilot-instructions.md`는 의도적으로 두지 않음).

## CLI 표면에서 추가로 따른다

- 사용자가 명시적으로 다른 도구를 지정하지 않는 한, 이 리포에서 정의한 `inp-*` 5종 스킬은 Copilot CLI 세션에서도 `~/.agents/skills/`를 통해 그대로 로드된다.
- 인라인 `@inp-<name>` 호출 외에 사용자가 `TSK-<id>` 형식의 작업을 지시하면 `inp-start-task` 스킬을 우선 고려한다.
- 위험 명령(파일 삭제, force push, 시크릿 노출 등) 자동화는 의도적으로 두지 않는다. 사용자의 명시 승인을 받은 뒤에만 수행한다.

## GitHub Copilot 역할 에이전트

`.github/agents/`의 4종 역할 규약은 Copilot **코딩 에이전트**(이 리포를 작업 기반으로 다룰 때)만을 위한 것이다. 인터랙티브 채팅 세션에는 적용되지 않는다.
