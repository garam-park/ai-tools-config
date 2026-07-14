# garam-park/ai-tools-config

개인용 AI 코딩 도구 설정 묶음. Claude Code, GitHub Copilot, Codex, OpenCode에서 공통 스킬을 사용하고, 도구별 글로벌 지침을 안전하게 동기화한다.

## 빠른 시작

```bash
git clone git@github.com:garam-park/ai-tools-config.git ~/ai-tools-config
cd ~/ai-tools-config
./bootstrap.sh
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
│   ├── extending.md                   # 스킬/타깃/델타 추가 가이드
│   └── archive/tasks/                 # 완료된 작업 카드 기록 (fork 시 삭제 무관)
├── global-instructions/               # common.md + claude.md/codex.md/opencode.md
├── skills/                            # 각 스킬: SKILL.md + agents/codex.yaml (+부속)
│   ├── inp-analyze-task/
│   ├── inp-create-pr/
│   ├── inp-handle-pr/
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

## 문서

- [docs/concepts.md](docs/concepts.md) — 스킬·커맨드·에이전트·훅·MCP·플러그인 개념 구분과 이 리포의 채택 여부
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
