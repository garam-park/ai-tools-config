# 23. install-global-instructions.sh — dest가 심볼릭 링크일 때 처리

## 상태
- [ ] 시작 전
- [ ] 적용
- [ ] 검증
- [ ] 완료

## 우선순위
🔴 **P1 — 작업 02 보강 (보안 공백)**

## 제안
**메타 분석** (세 모델 모두 미발굴)

## 의존
- ← 작업 **02**(백업)와 같은 커밋에 묶어 적용 권장

## 문제
[install-global-instructions.sh:49, 52](../../install-global-instructions.sh#L49-L52) 의 `mv "$tmp" "$dest"` 동작이 dest의 종류에 따라 다르다:

| `$dest` 종류 | `mv` 동작 | 결과 |
|--------------|-----------|------|
| 일반 파일 없음 | 새 파일 생성 | ✅ 정상 |
| 일반 파일 있음 | 덮어씀 | ✅ 정상 (작업 02의 백업으로 보호) |
| **심볼릭 링크** | **링크의 타깃 파일을 교체** | ❌ **사용자 링크가 조용히 깨짐** |
| 손상된 심링크 (dangling) | 새 파일 생성 | ⚠️ 사용자 의도와 다를 수 있음 |

시나리오: 사용자가 `~/.claude/CLAUDE.md -> ~/my-configs/claude.md` 같은 심볼릭 링크를 만들어 외부 파일을 참조하게 해뒀다면, 첫 실행 시 그 **링크 자체가 동기화된 새 파일로 교체**되어 외부 연결이 끊어진다. 백업 로직은 일반 파일에만 동작하므로 보호되지 않는다.

## 권장 구현

`dest`가 심볼릭 링크인 경우를 명시적으로 분기:

```bash
dest="${entry%%|*}"

# 심볼릭 링크면 링크를 따라가서 실제 파일을 대상으로 처리
if [[ -L "$dest" ]]; then
  real_target="$(readlink -f -- "$dest")"
  if [[ -e "$real_target" && ! "$real_target" -ef "$dest" ]]; then
    echo "note: $dest 는 심볼릭 링크 (→ $real_target). 링크 타깃 파일에 동기화합니다." >&2
  fi
  # mv가 링크를 따라가지 않도록 링크 자체를 미리 제거 (백업 후)
  # 또는: 링크 타깃 파일을 직접 mv로 교체
  target_for_backup="$real_target"
  target_for_write="$real_target"
elif [[ -e "$dest" ]]; then
  target_for_backup="$dest"
  target_for_write="$dest"
else
  target_for_backup=""
  target_for_write="$dest"
fi

mkdir -p "$(dirname "$target_for_write")"
tmp="$(mktemp "$target_for_write.XXXXXX")"
trap 'rm -f "$tmp"' EXIT

# ... common + delta 조립 ...

# 자동 생성 마커 없는 기존 파일 백업
if [[ -n "$target_for_backup" && -f "$target_for_backup" ]] \
   && ! head -1 "$target_for_backup" | grep -q 'AUTO-GENERATED'; then
  backup="$target_for_backup.bak.$(date +%Y%m%d%H%M%S)"
  cp "$target_for_backup" "$backup"
  echo "backed up: $target_for_backup -> $backup"
fi

mv "$tmp" "$target_for_write"
```

핵심: `dest`가 심볼릭 링크면 그 타깃을 기준으로 백업·쓰기. 사용자가 만든 링크 자체는 건드리지 않음(또는 명시적으로 제거 옵션 제공).

## 완료 조건
- [ ] `dest`가 심볼릭 링크면 링크 타깃 파일을 기준으로 백업·교체
- [ ] 사용자가 만든 링크 자체는 보존
- [ ] dangling 심링크(타깃 없음)에 대해서도 명시적 안내
- [ ] 일반 파일/부재 케이스의 기존 동작 유지

## 검증
```sh
TMPDIR=$(mktemp -d); HOME="$TMPDIR/home"; mkdir -p "$HOME/.claude"
echo "내 외부 설정" > "$TMPDIR/my-claude.md"
ln -s "$TMPDIR/my-claude.md" "$HOME/.claude/CLAUDE.md"
bash install-global-instructions.sh
ls -la "$HOME/.claude/CLAUDE.md"                                # 심볼릭 링크 그대로
cat "$TMPDIR/my-claude.md" | head -1                            # AUTO-GENERATED 마커 존재
ls "$TMPDIR/my-claude.md".bak.* 2>/dev/null                     # 백업 파일 존재
```

## 커밋 메시지 (예시, 작업 02와 통합 시)
```
fix(install-global-instructions): follow symlink dest to preserve user links
```