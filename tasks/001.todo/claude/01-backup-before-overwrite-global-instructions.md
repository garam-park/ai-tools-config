# 01. 글로벌 지침 덮어쓰기 전 기존 파일 백업

- **우선순위**: P1 (데이터 손실 위험)
- **대상 파일**: `install-global-instructions.sh` (L31 부근, L49 / L52)
- **상태**: TODO

## 문제

각 대상에 대해 `common.md`(+ 도구별 델타)를 `$tmp`에 조립한 뒤 목적지를 **무조건 덮어쓴다**.

대상은 `$HOME/.claude/CLAUDE.md`, `$HOME/.codex/AGENTS.md`, `$HOME/.config/opencode/AGENTS.md`.
이미 손으로 작성한 글로벌 지침이 있는 머신에서 **첫 실행 시 그 파일이 복구 불가하게 파괴**된다.
생성 파일 상단의 "직접 수정해도 다음 실행 시 덮어쓰입니다" 경고는 재실행만 다룰 뿐, **최초 덮어쓰기를 막지 못한다.**

## 근거 (현재 코드)

```bash
mv "$tmp" "$dest"    # L49, L52 — 존재 여부 확인/백업 없이 덮어씀
```

## 수정 방향

목적지를 만들기 전에, **자동 생성 마커가 없는 기존 파일**을 타임스탬프 백업한다.
`mkdir -p "$(dirname "$dest")"` 바로 다음(L31 부근)에 삽입하면 두 `mv` 분기를 모두 커버한다.

```bash
mkdir -p "$(dirname "$dest")"

# 덮어쓰기 전 백업: 자동 생성 마커가 없는 사용자 원본은 보존
if [[ -f "$dest" ]] && ! head -1 "$dest" | grep -q '자동 생성'; then
  backup="$dest.bak.$(date +%Y%m%d%H%M%S)"
  cp "$dest" "$backup"
  echo "backed up: $dest -> $backup"
fi
```

## 완료 조건

- [ ] 기존에 마커 없는 `CLAUDE.md`가 있으면 `.bak.*`로 백업된 뒤 덮어써진다
- [ ] 자동 생성 파일(마커 있음)은 백업 없이 그대로 덮어써진다 (노이즈 방지)
- [ ] 여러 번 실행해도 백업이 매번 무한 누적되지 않는다(마커 있는 생성 파일은 백업 대상 아님)
