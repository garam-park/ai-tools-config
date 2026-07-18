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

## doctor 출력 해석

두 스크립트의 `doctor`는 아무것도 변경하지 않고 상태만 검사하며, 문제가 있으면 종료 코드 1을 반환한다.

| 메시지 | 의미 | 조치 |
|--------|------|------|
| `링크가 없습니다` / `파일이 없습니다` | 아직 설치되지 않음 | 해당 설치기 `install` 실행 |
| `링크가 다른 곳을 가리킵니다` | 링크 타깃이 리포 원본이 아님 | `install` 재실행 (기존 심링크는 안전히 교체) |
| `심볼릭 링크가 아닌 실제 파일/디렉토리입니다` | 사용자 항목과 충돌 | 내용 확인 후 `install --force` (백업 후 교체) |
| `stale 링크` | 원본에서 삭제된 스킬의 링크가 남음 | `install` 재실행 (manifest 기반 정리) |
| `dangling 링크` | 타깃이 사라진 링크 | `install` 재실행 또는 수동 삭제 |
| `내용이 원본과 다릅니다` | 글로벌 지침이 원본과 드리프트 | `install-global-instructions.sh` 재실행 |
| `자동 생성 마커가 없습니다` | 사용자 작성 파일이 자리를 차지 | `install` 실행 시 `.bak.<timestamp>` 백업 후 교체 |

## git pull 이후

심볼릭 링크가 리포 작업 트리(`~/ai-tools-config/skills/`)를 직접 가리키므로, `git pull`만 하면 스킬 내용이 즉시 반영된다. `./install-skills.sh` 재실행은 스킬을 추가하거나 삭제했을 때만 필요하다. 제거된 리포 스킬의 도구별 심볼릭 링크는 설치 스크립트의 manifest가 관리 링크인지 확인한 뒤 정리한다.

## 마이그레이션: 구 `~/.local/share/skills/` 구조에서

이전 구조(`~/.local/share/skills/` 중간 사본)에서 마이그레이션하려면 리포 루트에서 `./install-skills.sh`를 한 번 실행한다. 기존 심볼릭 링크가 리포 경로로 교체된다. 로컬 전용 스킬이 없다면 `~/.local/share/skills/`는 제거해도 된다.

## 비밀값: NOTION_TOKEN

`inp-start-task` 스킬의 `scripts/notion_task.py`는 Notion API 토큰을 `NOTION_TOKEN` 환경변수(또는 `--config` 파일)에서 읽는다. 토큰 값은 **절대 리포에 커밋하지 않는다** — 기기별로 셸 프로필 등에서 주입한다:

```bash
# 예: ~/.zshrc (리포 밖, 커밋되지 않는 파일)
export NOTION_TOKEN="..."
```

`.gitignore`가 `.env`, `.env.local`, `*.local`을 차단하지만, 안전망일 뿐 비밀값 파일을 리포 안에 두지 않는 것이 원칙이다.
