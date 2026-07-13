# 01. install-skills.sh — rm-rf 가드 (실제 디렉토리 보호)

## 상태
- [ ] 시작 전
- [ ] 적용
- [ ] 검증
- [ ] 완료

## 우선순위
🔴 **P1 — 데이터 손실 위험**

## 제안 모델
- ✅ claude ([01-guard-destructive-skill-link.md](../claude/01-guard-destructive-skill-link.md), [02-guard-rm-rf-to-symlink-only.md](../claude/02-guard-rm-rf-to-symlink-only.md))
- ✅ codex ([01-safe-skill-collision-handling.md](../codex/01-safe-skill-collision-handling.md))
- ❌ m3 (**놓침** — 가장 치명적 누락 중 하나)

## 문제
[install-skills.sh:37-39](../../install-skills.sh#L37-L39) 는 링크 재생성 전 기존 항목을 무조건 재귀 삭제한다.

```sh
rm -rf "$link"
ln -s "$skill_dir" "$link"
```

`$link`에 **실제 디렉토리**(예: 다른 머신에서 손으로 만든 `~/.claude/skills/paced-explainer/`, 미커밋 로컬 전용 스킬)가 있으면 내부까지 재귀 삭제되어 **복구 불가능한 데이터 손실**이 발생한다. 주석도 "파일/링크/디렉토리 모두"라고 명시.

## 권장 구현 (claude + codex 종합)

심볼릭 링크일 때만 제거하고, 실제 파일/디렉토리는 건드리지 않고 경고 후 건너뛴다. 강제 교체가 필요하면 `--force` 옵션으로 명시적 분리.

```bash
FORCE=0
[[ "${1:-}" == "--force" ]] && FORCE=1

if [[ -L "$link" ]]; then
  rm -f "$link"
elif [[ -e "$link" ]]; then
  if [[ "$FORCE" == "1" ]]; then
    backup="$link.bak.$(date +%Y%m%d%H%M%S)"
    mv "$link" "$backup"
    echo "backed up: $link -> $backup"
  else
    echo "skip: $link 은(는) 실제 파일/디렉토리라 덮어쓰지 않음 (--force 필요)" >&2
    continue
  fi
fi
ln -s "$skill_dir" "$link"
```

> **codex의 추가 제안**: `--force` 사용 시에도 백업 생성. 이 카드는 기본 보호만 구현하고, `--force` UI는 후속 카드에서 다룬다.

## 완료 조건
- [ ] `$link`가 심링크면 정상 교체된다
- [ ] `$link`가 실제 디렉토리/파일이면 삭제되지 않고 경고 후 건너뛴다
- [ ] 멱등성 유지 (여러 번 실행해도 결과 동일)

## 검증
```sh
mkdir -p ~/.claude/skills/paced-explainer && touch ~/.claude/skills/paced-explainer/LOCAL_ONLY
bash install-skills.sh          # skip 경고가 나오고 LOCAL_ONLY 가 살아있어야 함
ls ~/.claude/skills/paced-explainer/LOCAL_ONLY   # 존재 확인
```
> ⚠️ Unix/WSL 환경에서 검증. 테스트 후 임시 디렉토리 정리.

## 커밋 메시지 (예시)
```
fix(install-skills): guard rm -rf so only symlinks are replaced
```