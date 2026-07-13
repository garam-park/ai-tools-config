# 02. install-global-instructions.sh — 기존 글로벌 지침 백업

## 상태
- [ ] 시작 전
- [ ] 적용
- [ ] 검증
- [ ] 완료

## 우선순위
🔴 **P1 — 데이터 손실 위험**

## 제안 모델
- ✅ claude ([01-backup-before-overwrite-global-instructions.md](../claude/01-backup-before-overwrite-global-instructions.md))
- ✅ codex ([04-protect-global-instructions.md](../codex/04-protect-global-instructions.md))
- ❌ m3 (**놓침**)

## 문제
[install-global-instructions.sh:49, 52](../../install-global-instructions.sh#L49-L52) 에서 `mv "$tmp" "$dest"`로 목적지를 무조건 덮어쓴다.

대상 경로:
- `~/.claude/CLAUDE.md`
- `~/.codex/AGENTS.md`
- `~/.config/opencode/AGENTS.md`

첫 실행 시 손으로 작성한 글로벌 지침이 **복구 불가하게 파괴**된다. 헤더 주석의 "직접 수정해도 다음 실행 시 덮어쓰입니다" 경고는 재실행만 다룰 뿐 **최초 덮어쓰기는 방어하지 못한다**.

## 권장 구현 (claude + codex 종합)

1. **마커 기반 관리 판별** — 자동 생성된 파일(`<!-- 자동 생성 -->`)은 백업 없이 갱신
2. **사용자 원본 백업** — 마커 없는 기존 파일은 타임스탬프 백업 후 덮어쓰기
3. **trap으로 임시 파일 정리** — 실패 시 tmp 파일이 남지 않도록
4. **원자적 이동** — `mv`는 같은 파일시스템에서만 원자적이므로 tmp를 dest와 같은 디렉토리에 생성

```bash
mkdir -p "$(dirname "$dest")"
tmp="$(mktemp "$dest.XXXXXX")"          # dest와 같은 디렉토리 → 원자적 mv
trap 'rm -f "$tmp"' EXIT

# 자동 생성 마커가 없는 기존 파일은 백업
if [[ -f "$dest" ]] && ! head -1 "$dest" | grep -q '자동 생성'; then
  backup="$dest.bak.$(date +%Y%m%d%H%M%S)"
  cp "$dest" "$backup"
  echo "backed up: $dest -> $backup"
fi

# ... 기존 조립 로직 ...
mv "$tmp" "$dest"
```

## 완료 조건
- [ ] 마커 없는 기존 파일은 `.bak.<timestamp>`로 백업 후 덮어써진다
- [ ] 자동 생성 파일(마커 있음)은 백업 없이 그대로 갱신된다
- [ ] 스크립트 실패 시 임시 파일이 남지 않는다 (trap 동작)
- [ ] 멱등성 유지

## 검증
```sh
echo "내 지침" > ~/.claude/CLAUDE.md           # 마커 없는 사용자 파일
bash install-global-instructions.sh
ls ~/.claude/CLAUDE.md.bak.*                   # 백업 존재 확인
head -1 ~/.claude/CLAUDE.md                    # "자동 생성" 마커 확인
```

## 커밋 메시지 (예시)
```
fix(install-global-instructions): back up user-authored files before overwrite
```