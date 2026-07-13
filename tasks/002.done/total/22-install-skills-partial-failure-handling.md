# 22. install-skills.sh — 부분 실패 처리 (set -e + 부분 상태)

## 상태
- [x] 시작 전
- [x] 적용
- [x] 검증
- [x] 완료

## 우선순위
🔴 **P1 — 작업 01 보강 (보안 공백)**

## 제안
**메타 분석** (세 모델 모두 미발굴)

## 의존
- ← 작업 **01**의 `[[ -L ]]` 가드와 같은 커밋에 묶어 적용 권장

## 문제
작업 01은 "실제 디렉토리를 `rm -rf`로 지우지 않는다"를 보장하지만, **연산 자체가 실패하는 시나리오**는 다뤄지지 않음.

[install-skills.sh:5](../../install-skills.sh#L5) 는 `set -euo pipefail`을 켜놓고 L37에서 다음을 수행:
```bash
rm -rf "$link"
ln -s "$skill_dir" "$link"
```

가능한 부분 실패 시나리오:

1. **`mkdir -p "$target"` 실패** (권한 부족, read-only 상위): 스크립트 시작 시점에서 즉시 종료 → 후속 타깃도 처리 안 됨
2. **`rm -f "$link"` 실패** (권한 부족, 읽기 전용 FS): `set -e`로 즉시 중단. **그러나 그 직전의 다른 타깃/스킬은 이미 링크됨 → 부분 상태로 남음**
3. **`ln -s` 실패** (이미 다른 타입의 항목 존재, 권한 부족): 중단. **이전 성공한 링크는 그대로**, 일부 스킬만 미설치 상태로 남음

결과: 한 번의 실패로 **도구별/스킬별로 비대칭 상태**가 만들어져 사용자가 인지하기 어렵다.

## 권장 구현 (작업 01 패치에 통합)

```bash
set -euo pipefail

# 최상위 가드: SRC_DIR에 SKILL.md가 하나도 없으면 명시적 경고 후 종료
shopt -s nullglob
skill_dirs=( "$SRC_DIR"/*/ )
[[ ${#skill_dirs[@]} -gt 0 ]] || { echo "warning: $SRC_DIR 에 스킬 디렉토리(SKILL.md 포함)가 없습니다" >&2; exit 1; }

for target in "${TARGETS[@]}"; do
  if ! mkdir -p "$target"; then
    echo "error: cannot create $target — 권한 또는 상위 경로 확인 필요" >&2
    exit 1
  fi

  for skill_dir in "${skill_dirs[@]}"; do
    [[ -f "$skill_dir/SKILL.md" ]] || continue
    name="$(basename "$skill_dir")"
    link="$target/$name"

    if [[ -L "$link" ]]; then
      rm -f "$link" || { echo "error: cannot remove existing link $link" >&2; continue; }
    elif [[ -e "$link" ]]; then
      echo "skip: $link 은(는) 실제 파일/디렉토리라 덮어쓰지 않음" >&2
      continue
    fi

    if ! ln -s "$skill_dir" "$link"; then
      echo "error: cannot create link $link -> $skill_dir" >&2
      continue
    fi
    echo "linked: $link -> $skill_dir"
  done
done
```

핵심 변경:
- `mkdir -p` 실패를 명시적으로 검사하고 전체 종료
- `rm -f`/`ln -s` 실패 시 `continue`로 **다른 스킬은 계속 진행** (전체 중단 대신 부분 성공)
- 상단에 작업 **24**의 빈 SRC_DIR 가드도 함께 통합

## 완료 조건
- [x] `mkdir` 실패는 명확한 에러와 함께 전체 종료
- [x] 개별 `rm`/`ln` 실패는 다른 스킬 진행을 막지 않음
- [x] 실패한 항목은 stderr로 명시되어 사용자가 즉시 인지 가능
- [x] 부분 성공 시 어떤 스킬이 설치됐는지 출력으로 확인 가능

## 검증
```sh
# 권한 없는 부모 디렉토리로 mkdir 실패 시뮬레이션
TMPDIR=$(mktemp -d); chmod 555 "$TMPDIR"; HOME="$TMPDIR/home" bash install-skills.sh   # 명확한 에러

# 정상 케이스
bash install-skills.sh                            # 모든 스킬 linked
ls ~/.claude/skills/ ~/.codex/skills/ ~/.config/opencode/skills/   # 3개 경로 모두 paced-explainer 심링크
```

## 커밋 메시지 (예시, 작업 01과 통합 시)
```
fix(install-skills): guard destructive ops and harden against partial failure
```