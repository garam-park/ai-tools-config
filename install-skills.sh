#!/usr/bin/env bash
# install-skills.sh
#
# 원본: 이 스크립트 옆의 skills/<name>/ (SKILL.md 포함)
# 공통 Agent Skills 경로와 Claude Code 경로에 심볼릭 링크를 만들어 동기화한다.
# 링크가 리포 작업 트리를 직접 가리키므로 git pull만으로 스킬 내용이 반영된다.
# 멱등성 보장: 여러 번 실행해도 같은 결과.
#
# 사용자가 손으로 만든 실제 파일/디렉토리는 삭제하지 않는다.
# 강제 교체가 필요하면 --force (백업 후 교체).
# 원본에서 사라진 스킬의 관리 링크는 manifest로 추적해 안전히 정리한다.
#
# 새 머신에서: git clone 후 리포 루트에서 ./install-skills.sh
#
# 사용법:
#   ./install-skills.sh [install] [--force]   # 설치/동기화 (기본)
#   ./install-skills.sh doctor                # 변경 없이 설치 상태만 검사 (문제 시 exit 1)

set -euo pipefail
shopt -s nullglob
shopt -s inherit_errexit 2>/dev/null || true   # bash 4.4+: command substitution도 errexit 상속

# 원본 폴더 (이 스크립트 옆의 skills/)
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/skills"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/ai-tools-config"
MANIFEST="$STATE_DIR/install-skills.manifest"

# Claude Code는 전용 개인 경로를 사용한다.
# Codex, GitHub Copilot, OpenCode는 공통 Agent Skills 경로를 공식 지원한다.
# Hermes Agent는 ~/.hermes/config.yaml의 skills.external_dirs에
# 공통 경로를 등록해 같은 링크를 읽는다 (README '동기화되는 도구' 참고).
TARGETS=(
  "$HOME/.claude/skills"    # Claude Code
  "$HOME/.agents/skills"    # Codex, GitHub Copilot, OpenCode, Hermes Agent
)

warn() {
  echo "warning: $*" >&2
}

error() {
  echo "error: $*" >&2
}

is_known_target() {
  local candidate="$1"
  local target

  for target in "${TARGETS[@]}"; do
    [[ "$candidate" == "$target" ]] && return 0
  done
  return 1
}

usage() {
  echo "사용법: $0 [install [--force] | doctor]" >&2
}

CMD="install"
case "${1:-}" in
  install|doctor)
    CMD="$1"
    shift
    ;;
esac

FORCE=0
if [[ "$CMD" == "install" && "${1:-}" == "--force" ]]; then
  FORCE=1
  shift
fi

if [[ $# -gt 0 ]]; then
  error "알 수 없는 인자입니다: $1"
  usage
  exit 2
fi

if [[ ! -d "$SRC_DIR" ]]; then
  error "원본 폴더를 찾을 수 없습니다: $SRC_DIR"
  exit 1
fi

directories=("$SRC_DIR"/*/)
if [[ ${#directories[@]} -eq 0 ]]; then
  warn "$SRC_DIR 에 디렉토리가 없습니다. 스킬 원본 위치를 확인하세요."
  exit 1
fi

skill_dirs=()
for skill_dir in "${directories[@]}"; do
  skill_dir="${skill_dir%/}"
  [[ -f "$skill_dir/SKILL.md" ]] || continue
  skill_dirs+=("$skill_dir")
done

if [[ ${#skill_dirs[@]} -eq 0 ]]; then
  warn "$SRC_DIR 에 SKILL.md가 있는 스킬이 없습니다. 디렉토리 구조를 확인하세요."
  exit 1
fi

# doctor: 아무것도 변경하지 않고 설치 상태만 검사한다.
if [[ "$CMD" == "doctor" ]]; then
  ok_count=0
  problem_count=0

  report_ok() {
    echo "  ok: $*"
    ok_count=$((ok_count + 1))
  }

  report_problem() {
    echo "  problem: $*"
    problem_count=$((problem_count + 1))
  }

  for target in "${TARGETS[@]}"; do
    echo "[$target]"
    if [[ ! -d "$target" ]]; then
      report_problem "디렉토리가 없습니다. install을 실행하세요."
      echo
      continue
    fi

    for skill_dir in "${skill_dirs[@]}"; do
      name="$(basename "$skill_dir")"
      link="$target/$name"
      if [[ -L "$link" ]]; then
        actual="$(readlink "$link")"
        if [[ "$actual" == "$skill_dir" ]]; then
          report_ok "$name"
        else
          report_problem "$name: 링크가 다른 곳을 가리킵니다 ($actual)"
        fi
      elif [[ -e "$link" ]]; then
        report_problem "$name: 심볼릭 링크가 아닌 실제 파일/디렉토리입니다 (install --force 로 백업 후 교체 가능)"
      else
        report_problem "$name: 링크가 없습니다. install을 실행하세요."
      fi
    done

    # 원본에서 사라진 스킬의 stale 링크와 타깃이 없는 dangling 링크 탐지
    for link in "$target"/*; do
      [[ -L "$link" ]] || continue
      actual="$(readlink "$link")"
      name="$(basename "$link")"
      is_current=0
      for skill_dir in "${skill_dirs[@]}"; do
        if [[ "$name" == "$(basename "$skill_dir")" ]]; then
          is_current=1
          break
        fi
      done
      [[ "$is_current" -eq 0 ]] || continue
      if [[ "$actual" == "$SRC_DIR"/* ]]; then
        report_problem "$name: 원본에 없는 스킬을 가리키는 stale 링크입니다 ($actual)"
      elif [[ ! -e "$link" ]]; then
        report_problem "$name: 타깃이 없는 dangling 링크입니다 ($actual)"
      fi
    done
    echo
  done

  if [[ "$problem_count" -eq 0 ]]; then
    echo "doctor: 문제 없음 (${ok_count}개 링크 확인)."
    exit 0
  fi
  echo "doctor: ${problem_count}개 문제 발견. ./install-skills.sh 를 실행해 동기화하세요."
  exit 1
fi

for target in "${TARGETS[@]}"; do
  if ! mkdir -p "$target"; then
    error "$target 을(를) 만들 수 없습니다. 권한 또는 상위 경로를 확인하세요."
    exit 1
  fi
done

# 이전 실행에서 관리한 링크 중 이제 원본에 없는 것만 안전하게 정리한다.
if [[ -f "$MANIFEST" ]]; then
  while IFS=$'\t' read -r old_target old_name old_source extra; do
    [[ -n "$old_target" && -n "$old_name" && -n "$old_source" && -z "${extra:-}" ]] || continue

    old_link="$old_target/$old_name"
    still_desired=0
    for skill_dir in "${skill_dirs[@]}"; do
      if is_known_target "$old_target" && [[ "$old_name" == "$(basename "$skill_dir")" ]]; then
        still_desired=1
        break
      fi
    done
    [[ "$still_desired" -eq 0 ]] || continue

    if [[ -L "$old_link" && "$(readlink "$old_link")" == "$old_source" ]]; then
      if rm -f "$old_link"; then
        echo "removed stale link: $old_link"
      else
        warn "오래된 관리 링크를 제거할 수 없습니다: $old_link"
      fi
    elif [[ -e "$old_link" || -L "$old_link" ]]; then
      warn "$old_link 이(가) 사용자 항목으로 바뀌어 오래된 링크 정리에서 제외합니다."
    fi
  done < "$MANIFEST"
fi

failures=0
for target in "${TARGETS[@]}"; do
  for skill_dir in "${skill_dirs[@]}"; do
    name="$(basename "$skill_dir")"
    link="$target/$name"

    if [[ -L "$link" ]]; then
      # 기존 심링크는 안전하게 교체 (스크립트가 만든 링크든 사용자 링크든)
      if ! rm -f "$link"; then
        error "기존 링크를 제거할 수 없습니다: $link"
        failures=$((failures + 1))
        continue
      fi
    elif [[ -e "$link" ]]; then
      # 실제 파일/디렉토리: 기본 보호, --force 시 백업 후 교체
      if [[ "$FORCE" == "1" ]]; then
        backup="$link.bak.$(date +%Y%m%d%H%M%S)"
        if mv "$link" "$backup"; then
          echo "backed up: $link -> $backup"
        else
          error "백업 실패로 건너뜀: $link"
          failures=$((failures + 1))
          continue
        fi
      else
        warn "$link 은(는) 실제 파일/디렉토리라 덮어쓰지 않습니다 (--force 필요)."
        failures=$((failures + 1))
        continue
      fi
    fi

    if ! ln -s "$skill_dir" "$link"; then
      error "링크를 만들 수 없습니다: $link -> $skill_dir"
      failures=$((failures + 1))
      continue
    fi
    echo "linked: $link -> $skill_dir"
  done
done

# 실제로 원하는 원본을 가리키는 링크만 다음 실행의 관리 대상으로 기록한다.
if ! mkdir -p "$STATE_DIR"; then
  error "manifest 디렉토리를 만들 수 없습니다: $STATE_DIR"
  exit 1
fi
manifest_tmp="$(mktemp "$MANIFEST.XXXXXX")"
trap 'rm -f "${manifest_tmp:-}"' EXIT
{
  for target in "${TARGETS[@]}"; do
    for skill_dir in "${skill_dirs[@]}"; do
      name="$(basename "$skill_dir")"
      link="$target/$name"
      if [[ -L "$link" && "$(readlink "$link")" == "$skill_dir" ]]; then
        printf '%s\t%s\t%s\n' "$target" "$name" "$skill_dir"
      fi
    done
  done
} > "$manifest_tmp"
mv "$manifest_tmp" "$MANIFEST"
manifest_tmp=""

echo
echo "완료. 다음 도구에서 사용 가능:"
echo "  - Claude Code: ~/.claude/skills"
echo "  - Codex: ~/.agents/skills"
echo "  - GitHub Copilot: ~/.agents/skills"
echo "  - OpenCode: ~/.agents/skills"
echo "  - Hermes Agent: ~/.agents/skills (~/.hermes/config.yaml skills.external_dirs 등록 필요)"

if [[ "$failures" -gt 0 ]]; then
  error "${failures}개 항목을 설치하지 못했습니다. 위 경고를 확인하세요."
  exit 1
fi
