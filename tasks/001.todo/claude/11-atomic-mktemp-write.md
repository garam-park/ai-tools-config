# 11. install-global-instructions.sh 원자적 쓰기 (mktemp 위치)

- **우선순위**: P3 (사소한 정리 — 셸 견고성)
- **대상 파일**: `install-global-instructions.sh` (L33, L49/L52)
- **상태**: TODO

## 문제

`tmp="$(mktemp)"`는 `$TMPDIR`(보통 `/tmp`)에 임시 파일을 만든다.
이후 `mv "$tmp" "$dest"`로 `$HOME` 아래 목적지로 옮기는데, `/tmp`와 `$HOME`이 다른 파일시스템이면
`mv`는 rename(2)이 아니라 copy-then-unlink가 되어 **비원자적으로** 목적지를 덮어쓴다.
temp→rename 관용구의 원자성 이점이 사라진다. (영향은 낮음: 단일 사용자·수동 실행. 그래도 관용구 취지를 살리는 게 좋다.)

## 수정 방향

임시 파일을 목적지와 같은 파일시스템(같은 디렉토리)에 만들고, 중단 시 정리 트랩을 둔다.

```bash
mkdir -p "$(dirname "$dest")"
tmp="$(mktemp "$dest.XXXXXX")"
trap 'rm -f "$tmp"' EXIT
```

(`$dest`가 대상별로 바뀌므로 `tmp` 생성은 루프 안, `dest` 확정 후에 둔다.)

## 완료 조건

- [ ] 임시 파일이 목적지와 같은 디렉토리에 생성되어 `mv`가 same-filesystem rename이 된다
- [ ] 스크립트가 중간에 실패해도 임시 파일이 남지 않는다
- [ ] 멱등성/결과물은 기존과 동일하다
