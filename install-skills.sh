#!/usr/bin/env bash
# install-skills.sh
#
# 원본: 이 스크립트 옆의 skills/<name>/ (SKILL.md 포함)
# 공통 Agent Skills 경로와 Claude Code 경로에 심볼릭 링크를 만들어 동기화한다.
# 링크가 리포 작업 트리를 직접 가리키므로 git pull만으로 스킬 내용이 반영된다.
# 멱등성 보장: 여러 번 실행해도 같은 결과.
#
# 선택 설치: 스킬 이름을 인자로 주면 그 스킬만 설치한다.
# 선택은 상태 파일(install-skills.selection)에 남아 다음 무인자 실행과
# bootstrap.sh, doctor 판정에서도 유지된다.
# 이름 인자는 더하기만 한다. 이미 관리 중인 다른 스킬의 링크는 제거하지 않으므로
# 선택에서 빼려면 uninstall <이름>을, 전체로 되돌리려면 install --all을 사용한다.
#
# 사용자가 손으로 만든 실제 파일/디렉토리는 삭제하지 않는다.
# 강제 교체가 필요하면 --force (백업 후 교체).
# 원본에서 사라진 스킬의 관리 링크는 manifest로 추적해 안전히 정리한다.
#
# 새 머신에서: git clone 후 리포 루트에서 ./install-skills.sh
#
# 사용법:
#   ./install-skills.sh [install] [--force] [--all] [스킬...]  # 설치/동기화 (기본)
#   ./install-skills.sh uninstall [스킬...]                    # 관리 중인 스킬 링크 제거
#   ./install-skills.sh doctor [--all] [스킬...]               # 변경 없이 설치 상태만 검사

set -euo pipefail
shopt -s nullglob
shopt -s inherit_errexit 2>/dev/null || true   # bash 4.4+: command substitution도 errexit 상속

# 원본 폴더 (이 스크립트 옆의 skills/)
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/skills"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/ai-tools-config"
MANIFEST="$STATE_DIR/install-skills.manifest"
SELECTION="$STATE_DIR/install-skills.selection"

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

contains() {
  local needle="$1"
  shift
  local item

  for item in "$@"; do
    [[ "$item" == "$needle" ]] && return 0
  done
  return 1
}

join_names() {
  local out=""
  local item

  for item in "$@"; do
    if [[ -z "$out" ]]; then
      out="$item"
    else
      out="$out, $item"
    fi
  done
  printf '%s' "$out"
}

usage() {
  echo "사용법: $0 [install [--force] [--all] [스킬...] | uninstall [스킬...] | doctor [--all] [스킬...]]" >&2
}

CMD="install"
case "${1:-}" in
  install|uninstall|doctor)
    CMD="$1"
    shift
    ;;
esac

FORCE=0
ALL=0
requested=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force)
      FORCE=1
      ;;
    --all)
      ALL=1
      ;;
    --)
      shift
      while [[ $# -gt 0 ]]; do
        requested+=("$1")
        shift
      done
      break
      ;;
    -*)
      error "알 수 없는 옵션입니다: $1"
      usage
      exit 2
      ;;
    *)
      requested+=("$1")
      ;;
  esac
  shift
done

if [[ "$CMD" != "install" && "$FORCE" == "1" ]]; then
  error "--force는 install에서만 사용할 수 있습니다."
  usage
  exit 2
fi

if [[ "$ALL" == "1" && ${#requested[@]} -gt 0 ]]; then
  error "--all과 스킬 이름은 함께 쓸 수 없습니다."
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
skill_names=()
for skill_dir in "${directories[@]}"; do
  skill_dir="${skill_dir%/}"
  [[ -f "$skill_dir/SKILL.md" ]] || continue
  skill_dirs+=("$skill_dir")
  skill_names+=("$(basename "$skill_dir")")
done

if [[ ${#skill_dirs[@]} -eq 0 ]]; then
  warn "$SRC_DIR 에 SKILL.md가 있는 스킬이 없습니다. 디렉토리 구조를 확인하세요."
  exit 1
fi

# manifest에 기록된 이름 (원본에서 사라진 스킬도 uninstall 대상으로 허용하기 위해 읽는다)
manifest_names=()
if [[ -f "$MANIFEST" ]]; then
  while IFS=$'\t' read -r m_target m_name m_source m_extra; do
    [[ -n "$m_target" && -n "$m_name" && -n "$m_source" && -z "${m_extra:-}" ]] || continue
    contains "$m_name" ${manifest_names[@]+"${manifest_names[@]}"} || manifest_names+=("$m_name")
  done < "$MANIFEST"
fi

# 요청한 이름 정규화와 검증
selected=()
for name in ${requested[@]+"${requested[@]}"}; do
  contains "$name" ${selected[@]+"${selected[@]}"} && continue
  if contains "$name" "${skill_names[@]}"; then
    selected+=("$name")
    continue
  fi
  if [[ "$CMD" == "uninstall" ]] && contains "$name" ${manifest_names[@]+"${manifest_names[@]}"}; then
    selected+=("$name")
    continue
  fi
  error "알 수 없는 스킬입니다: $name"
  echo "사용 가능한 스킬: $(join_names "${skill_names[@]}")" >&2
  exit 2
done

# 저장된 선택 상태
stored_mode=""
stored_names=()
if [[ -f "$SELECTION" ]]; then
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -n "$line" ]] || continue
    if [[ "$line" == "all" ]]; then
      stored_mode="all"
      stored_names=()
      break
    fi
    contains "$line" ${stored_names[@]+"${stored_names[@]}"} || stored_names+=("$line")
  done < "$SELECTION"
  if [[ "$stored_mode" != "all" && ${#stored_names[@]} -gt 0 ]]; then
    stored_mode="list"
  fi
elif [[ -f "$MANIFEST" ]]; then
  # 선택 파일 없이 manifest만 있으면 선택 설치 도입 이전의 전체 설치로 본다.
  stored_mode="all"
fi

# 이번 실행에서 다룰 스킬 결정
#   - 이름 인자: install은 저장된 선택에 더하고, doctor는 지정한 이름만 검사한다.
#   - 무인자: 저장된 선택을 그대로 유지한다 (없으면 전체).
selection_mode="all"
selection_names=()

add_selection() {
  local name="$1"
  contains "$name" ${selection_names[@]+"${selection_names[@]}"} || selection_names+=("$name")
}

if [[ "$ALL" == "1" ]]; then
  selection_mode="all"
elif [[ ${#selected[@]} -gt 0 ]]; then
  if [[ "$CMD" == "install" && "$stored_mode" == "all" ]]; then
    selection_mode="all"
  else
    selection_mode="list"
    if [[ "$CMD" == "install" ]]; then
      for name in ${stored_names[@]+"${stored_names[@]}"}; do
        contains "$name" "${skill_names[@]}" && add_selection "$name"
      done
    fi
    for name in "${selected[@]}"; do
      add_selection "$name"
    done
  fi
elif [[ "$stored_mode" == "list" ]]; then
  for name in "${stored_names[@]}"; do
    contains "$name" "${skill_names[@]}" && add_selection "$name"
  done
  if [[ ${#selection_names[@]} -gt 0 ]]; then
    selection_mode="list"
  fi
fi

if [[ "$selection_mode" == "all" ]]; then
  selection_names=("${skill_names[@]}")
fi

excluded_names=()
for name in "${skill_names[@]}"; do
  contains "$name" "${selection_names[@]}" || excluded_names+=("$name")
done

in_selection() {
  contains "$1" "${selection_names[@]}"
}

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

    for i in "${!skill_dirs[@]}"; do
      skill_dir="${skill_dirs[$i]}"
      name="${skill_names[$i]}"
      in_selection "$name" || continue
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
      contains "$name" "${skill_names[@]}" && continue
      if [[ "$actual" == "$SRC_DIR"/* ]]; then
        report_problem "$name: 원본에 없는 스킬을 가리키는 stale 링크입니다 ($actual)"
      elif [[ ! -e "$link" ]]; then
        report_problem "$name: 타깃이 없는 dangling 링크입니다 ($actual)"
      fi
    done
    echo
  done

  if [[ ${#excluded_names[@]} -gt 0 ]]; then
    echo "선택 제외(검사 안 함): $(join_names "${excluded_names[@]}")"
    echo
  fi

  if [[ "$problem_count" -eq 0 ]]; then
    echo "doctor: 문제 없음 (${ok_count}개 링크 확인)."
    exit 0
  fi
  echo "doctor: ${problem_count}개 문제 발견. ./install-skills.sh 를 실행해 동기화하세요."
  exit 1
fi

manifest_tmp=""
selection_tmp=""
trap 'rm -f "${manifest_tmp:-}" "${selection_tmp:-}"' EXIT

ensure_state_dir() {
  if ! mkdir -p "$STATE_DIR"; then
    error "상태 디렉토리를 만들 수 없습니다: $STATE_DIR"
    return 1
  fi
  return 0
}

# 선택 상태 기록: write_selection all | write_selection list <name>...
write_selection() {
  local mode="$1"
  shift

  ensure_state_dir || return 1
  selection_tmp="$(mktemp "$SELECTION.XXXXXX")"
  if [[ "$mode" == "all" ]]; then
    printf 'all\n' > "$selection_tmp"
  else
    printf '%s\n' "$@" > "$selection_tmp"
  fi
  if ! mv "$selection_tmp" "$SELECTION"; then
    error "선택 상태를 기록할 수 없습니다: $SELECTION"
    return 1
  fi
  selection_tmp=""
  return 0
}

uninstall_link() {
  local target="$1"
  local name="$2"
  local source="$3"
  local link="$target/$name"

  if [[ -L "$link" && "$(readlink "$link")" == "$source" ]]; then
    if rm -f "$link"; then
      echo "uninstalled: $link"
      return 0
    fi
    warn "관리 링크를 제거할 수 없습니다: $link"
    return 1
  fi

  if [[ -e "$link" || -L "$link" ]]; then
    warn "$link 이(가) 사용자 항목으로 바뀌어 삭제하지 않습니다."
  fi
  return 0
}

if [[ "$CMD" == "uninstall" ]]; then
  failures=0
  partial=0
  [[ ${#selected[@]} -gt 0 ]] && partial=1

  for target in "${TARGETS[@]}"; do
    for i in "${!skill_dirs[@]}"; do
      skill_dir="${skill_dirs[$i]}"
      name="${skill_names[$i]}"
      if [[ "$partial" == "1" ]] && ! contains "$name" "${selected[@]}"; then
        continue
      fi
      if ! uninstall_link "$target" "$name" "$skill_dir"; then
        failures=$((failures + 1))
      fi
    done
  done

  kept_lines=()
  if [[ -f "$MANIFEST" ]]; then
    while IFS=$'\t' read -r old_target old_name old_source extra; do
      [[ -n "$old_target" && -n "$old_name" && -n "$old_source" && -z "${extra:-}" ]] || continue
      if [[ "$partial" == "1" ]] && ! contains "$old_name" "${selected[@]}"; then
        kept_lines+=("$old_target"$'\t'"$old_name"$'\t'"$old_source")
        continue
      fi
      if ! uninstall_link "$old_target" "$old_name" "$old_source"; then
        failures=$((failures + 1))
      fi
    done < "$MANIFEST"
  fi

  if [[ "$partial" == "0" ]]; then
    if [[ "$failures" -eq 0 ]]; then
      rm -f "$MANIFEST" "$SELECTION"
    fi
  else
    # 남은 관리 링크만 manifest에 다시 기록한다 (삭제하지 못한 링크 포함).
    ensure_state_dir || exit 1
    manifest_tmp="$(mktemp "$MANIFEST.XXXXXX")"
    {
      for line in ${kept_lines[@]+"${kept_lines[@]}"}; do
        IFS=$'\t' read -r kept_target kept_name kept_source <<< "$line"
        kept_link="$kept_target/$kept_name"
        if [[ -L "$kept_link" && "$(readlink "$kept_link")" == "$kept_source" ]]; then
          printf '%s\t%s\t%s\n' "$kept_target" "$kept_name" "$kept_source"
        fi
      done
      for target in "${TARGETS[@]}"; do
        for i in "${!skill_dirs[@]}"; do
          skill_dir="${skill_dirs[$i]}"
          name="${skill_names[$i]}"
          contains "$name" "${selected[@]}" || continue
          link="$target/$name"
          if [[ -L "$link" && "$(readlink "$link")" == "$skill_dir" ]]; then
            printf '%s\t%s\t%s\n' "$target" "$name" "$skill_dir"
          fi
        done
      done
    } > "$manifest_tmp"

    if [[ -s "$manifest_tmp" ]]; then
      mv "$manifest_tmp" "$MANIFEST"
    else
      rm -f "$manifest_tmp" "$MANIFEST"
    fi
    manifest_tmp=""

    # 제거한 이름을 선택에서 뺀다. 남는 스킬이 없으면 선택 기록도 지운다.
    base_names=()
    if [[ "$stored_mode" == "list" ]]; then
      base_names=("${stored_names[@]}")
    else
      base_names=("${skill_names[@]}")
    fi
    remaining_names=()
    for name in "${base_names[@]}"; do
      contains "$name" "${selected[@]}" && continue
      contains "$name" "${skill_names[@]}" || continue
      contains "$name" ${remaining_names[@]+"${remaining_names[@]}"} || remaining_names+=("$name")
    done
    if [[ ${#remaining_names[@]} -gt 0 ]]; then
      if ! write_selection list "${remaining_names[@]}"; then
        failures=$((failures + 1))
      fi
    else
      rm -f "$SELECTION"
    fi
  fi

  echo
  if [[ "$failures" -gt 0 ]]; then
    error "${failures}개 항목을 삭제하지 못했습니다. 위 경고를 확인하세요."
    exit 1
  fi
  if [[ "$partial" == "1" ]]; then
    echo "완료. 선택한 스킬의 관리 링크를 제거했습니다: $(join_names "${selected[@]}")"
  else
    echo "완료. 관리 중인 스킬 링크를 제거했습니다."
  fi
  exit 0
fi

for target in "${TARGETS[@]}"; do
  if ! mkdir -p "$target"; then
    error "$target 을(를) 만들 수 없습니다. 권한 또는 상위 경로를 확인하세요."
    exit 1
  fi
done

# 이전 실행에서 관리한 링크 중 이제 원본에 없는 것만 안전하게 정리한다.
# 선택 설치에서 빠진 스킬의 링크는 여기서 건드리지 않는다 (제거는 uninstall <이름>).
if [[ -f "$MANIFEST" ]]; then
  while IFS=$'\t' read -r old_target old_name old_source extra; do
    [[ -n "$old_target" && -n "$old_name" && -n "$old_source" && -z "${extra:-}" ]] || continue

    old_link="$old_target/$old_name"
    if is_known_target "$old_target" && contains "$old_name" "${skill_names[@]}"; then
      continue
    fi

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
  for i in "${!skill_dirs[@]}"; do
    skill_dir="${skill_dirs[$i]}"
    name="${skill_names[$i]}"
    in_selection "$name" || continue
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
# 이번에 설치하지 않은 스킬도 링크가 이미 있으면 관리 대상으로 유지한다.
ensure_state_dir || exit 1
manifest_tmp="$(mktemp "$MANIFEST.XXXXXX")"
{
  for target in "${TARGETS[@]}"; do
    for i in "${!skill_dirs[@]}"; do
      skill_dir="${skill_dirs[$i]}"
      name="${skill_names[$i]}"
      link="$target/$name"
      if [[ -L "$link" && "$(readlink "$link")" == "$skill_dir" ]]; then
        printf '%s\t%s\t%s\n' "$target" "$name" "$skill_dir"
      fi
    done
  done
} > "$manifest_tmp"
mv "$manifest_tmp" "$MANIFEST"
manifest_tmp=""

if [[ "$selection_mode" == "all" ]]; then
  write_selection all || failures=$((failures + 1))
else
  write_selection list "${selection_names[@]}" || failures=$((failures + 1))
fi

echo
if [[ ${#excluded_names[@]} -gt 0 ]]; then
  echo "완료. 선택 설치 ${#selection_names[@]}/${#skill_names[@]}개: $(join_names "${selection_names[@]}")"
  echo "  선택 제외: $(join_names "${excluded_names[@]}")"
  echo "  전체 설치: $0 install --all"
else
  echo "완료. 전체 스킬 ${#skill_names[@]}개를 설치했습니다."
fi
echo "다음 도구에서 사용 가능:"
echo "  - Claude Code: ~/.claude/skills"
echo "  - Codex: ~/.agents/skills"
echo "  - GitHub Copilot: ~/.agents/skills"
echo "  - OpenCode: ~/.agents/skills"
echo "  - Hermes Agent: ~/.agents/skills (~/.hermes/config.yaml skills.external_dirs 등록 필요)"

if [[ "$failures" -gt 0 ]]; then
  error "${failures}개 항목을 설치하지 못했습니다. 위 경고를 확인하세요."
  exit 1
fi
