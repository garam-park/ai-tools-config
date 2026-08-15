# 새 기기 설정

## 전제조건

- macOS 또는 Linux 같은 Unix 환경. Windows에서는 WSL을 권장하며, Git Bash를 쓸 경우에도 `ln -s`가 실제 심볼릭 링크를 만들 수 있어야 한다.
- `bash`, `git`.

모든 설치 경로는 `$HOME`과 `$XDG_STATE_HOME` 기준이라 기기별 절대 경로 수정이 필요 없다.

## 표준 절차

```bash
# 1) 리포 clone
git clone git@github.com:garam-park/ai-tools-config.git ~/ai-tools-config
cd ~/ai-tools-config

# 2) 설치 2종 + doctor 2종 일괄 실행
./bootstrap.sh
```

`bootstrap.sh`는 `install-skills.sh install` → `install-global-instructions.sh install` → 두 스크립트의 `doctor`를 순서대로 실행한다. 대상 경로에 사용자가 직접 만든 실제 파일/디렉토리가 있어 충돌하면 `./bootstrap.sh --force`로 백업 후 교체할 수 있다 (`--force`는 스킬 설치기에만 전달된다).

개별 실행도 가능하다:

```bash
./install-skills.sh                     # 스킬 심볼릭 링크 설치
./install-global-instructions.sh       # 글로벌 지침 조립·동기화
./install-skills.sh doctor              # 스킬 링크 상태 점검
./install-global-instructions.sh doctor # 글로벌 지침 동기화 상태 점검
```

## 선택 설치

기기마다 필요한 스킬만 설치할 수 있다.

```bash
./install-skills.sh install clarify        # 지정한 스킬만 설치
./install-skills.sh install ntn-start-task # 선택에 추가 (기존 선택 유지)
./install-skills.sh uninstall clarify      # 선택에서 제거 (링크와 선택 상태 모두)
./install-skills.sh install --all          # 전체 설치로 복귀
./bootstrap.sh install clarify             # bootstrap에서도 동일하게 지정
```

선택 상태는 `${XDG_STATE_HOME:-~/.local/state}/ai-tools-config/install-skills.selection`에 `all` 또는 스킬 이름 목록으로 남는다. 이후 무인자 실행과 `doctor`는 이 선택을 기준으로 동작하므로, `./bootstrap.sh`를 다시 돌려도 선택하지 않은 스킬이 되살아나지 않는다.

이름 인자는 더하기만 한다. 전체 설치 상태에서 일부만 남기려면 빼려는 스킬을 `uninstall <이름>`으로 제거하거나, `uninstall` 후 원하는 이름으로 다시 설치한다. 선택 설치 중에는 리포에 새로 추가된 스킬이 자동으로 설치되지 않는다.

설치 해제도 가능하다:

```bash
./bootstrap.sh uninstall
./install-skills.sh uninstall
./install-global-instructions.sh uninstall
```

`uninstall`은 이 프로젝트가 관리한다고 확인할 수 있는 항목만 제거한다. 스킬은 리포 원본 또는 manifest가 기록한 원본을 가리키는 심볼릭 링크만 삭제하고, 글로벌 지침은 자동 생성 마커가 있는 파일만 삭제한다. 사용자 파일·디렉토리와 다른 원본으로 바뀐 항목은 보존한다.

## doctor 출력 해석

두 스크립트의 `doctor`는 아무것도 변경하지 않고 상태만 검사하며, 문제가 있으면 종료 코드 1을 반환한다.

| 메시지 | 의미 | 조치 |
|--------|------|------|
| `링크가 없습니다` / `파일이 없습니다` | 아직 설치되지 않음 | 해당 설치기 `install` 실행 |
| `링크가 다른 곳을 가리킵니다` | 링크 타깃이 리포 원본이 아님 | `install` 재실행 (기존 심링크는 안전히 교체) |
| `심볼릭 링크가 아닌 실제 파일/디렉토리입니다` | 사용자 항목과 충돌 | 내용 확인 후 `install --force` (백업 후 교체) |
| `stale 링크` | 원본에서 삭제된 스킬의 링크가 남음 | `install` 재실행 (manifest 기반 정리) 또는 `uninstall` |
| `dangling 링크` | 타깃이 사라진 링크 | `install` 재실행 또는 수동 삭제 |
| `내용이 원본과 다릅니다` | 글로벌 지침이 원본과 드리프트 | `install-global-instructions.sh` 재실행 |
| `자동 생성 마커가 없습니다` | 사용자 작성 파일이 자리를 차지 | `install` 실행 시 `.bak.<timestamp>` 백업 후 교체 |
| `선택 제외(검사 안 함)` | 선택 설치라 해당 스킬은 검사 대상이 아님 (문제 아님) | 필요하면 `install <이름>` 또는 `install --all` |

## git pull 이후

심볼릭 링크가 리포 작업 트리(`~/ai-tools-config/skills/`)를 직접 가리키므로, `git pull`만 하면 스킬 내용이 즉시 반영된다. `./install-skills.sh` 재실행은 스킬을 추가하거나 삭제했을 때만 필요하다. 선택 설치 중이라면 새로 추가된 스킬은 이름을 지정해야 설치된다. 제거된 리포 스킬의 도구별 심볼릭 링크는 설치 스크립트의 manifest가 관리 링크인지 확인한 뒤 정리한다. 전체 설치 해제가 필요하면 `./bootstrap.sh uninstall`을 사용한다.

## 마이그레이션: 구 `~/.local/share/skills/` 구조에서

이전 구조(`~/.local/share/skills/` 중간 사본)에서 마이그레이션하려면 리포 루트에서 `./install-skills.sh`를 한 번 실행한다. 기존 심볼릭 링크가 리포 경로로 교체된다. 로컬 전용 스킬이 없다면 `~/.local/share/skills/`는 제거해도 된다.

## Notion task 설정: .env.tsk와 ntn CLI

`ntn-*` 스킬은 Notion CLI `ntn`과 프로젝트 루트 `.env.tsk`에서 task database 설정을 읽는다. `.env.tsk`는 로컬 전용 파일이며 커밋하지 않는다:

```bash
NOTION_DATABASE_ID="..."
NOTION_DATA_SOURCE_ID="..."
```

값이 없으면 스킬 실행 중 확인 가능한 Notion database 또는 task 링크를 받아 `ntn datasources resolve <database-id>` 또는 사용 가능한 Notion 통합으로 값을 확인하고 `.env.tsk`를 생성하거나 업데이트한다. 기본 database ID fallback은 두지 않는다.

새 기기에서는 먼저 `ntn`을 설치하고 로그인 상태를 확인한다:

```bash
command -v ntn
ntn --version
ntn login
ntn doctor
```

설치는 `curl -fsSL https://ntn.dev | bash`를 우선 사용하거나, Node.js 22+와 npm 10+ 환경에서는 `npm install --global ntn`을 사용할 수 있다. 자동 인증 대신 환경변수를 써야 하는 환경에서는 Notion CLI가 지원하는 `NOTION_API_TOKEN`을 리포 밖 셸 프로필 등에 주입한다. 토큰 값은 **절대 리포에 커밋하지 않는다**.

`.gitignore`가 `.env`, `.env.tsk`, `.env.local`, `*.local`을 차단하지만, 안전망일 뿐 비밀값 파일을 리포 안에 두지 않는 것이 원칙이다.
