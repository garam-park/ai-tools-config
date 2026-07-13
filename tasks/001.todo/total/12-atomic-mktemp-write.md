# 12. install-global-instructions.sh 원자적 쓰기

## 상태
- [ ] 시작 전
- [ ] 적용
- [ ] 검증
- [ ] 완료

## 우선순위
⚪ **P3 — 셸 견고성**

## 제안 모델
- ✅ claude ([11-atomic-mktemp-write.md](../claude/11-atomic-mktemp-write.md))
- ❌ codex
- ❌ m3

## 문제
[install-global-instructions.sh:33](../../install-global-instructions.sh#L33):

```bash
tmp="$(mktemp)"
```

`mktemp`는 `$TMPDIR`(보통 `/tmp`)에 임시 파일을 만든다. 이후 `mv "$tmp" "$dest"`로 `$HOME` 아래 목적지로 옮기는데, `/tmp`와 `$HOME`이 다른 파일시스템이면 `mv`는 rename(2)이 아니라 **copy-then-unlink**가 되어 목적지 덮어쓰기가 비원자적이 된다.

temp→rename 관용구의 원자성 이점이 사라진다. (영향은 낮음: 단일 사용자·수동 실행. 그래도 관용구 취지를 살리는 게 좋다.)

## 권장 구현

임시 파일을 목적지와 같은 파일시스템(같은 디렉토리)에 만들고, 중단 시 정리 트랩을 둔다.

```bash
mkdir -p "$(dirname "$dest")"
tmp="$(mktemp "$dest.XXXXXX")"
trap 'rm -f "$tmp"' EXIT
```

> `$dest`는 대상별로 다르므로 `tmp` 생성은 루프 안, `dest` 확정 후에 둔다.

## 완료 조건
- [ ] 임시 파일이 목적지와 같은 디렉토리에 생성되어 `mv`가 same-filesystem rename이 된다
- [ ] 스크립트 중간 실패 시 임시 파일이 남지 않는다
- [ ] 멱등성/결과물은 기존과 동일

## 검증
```sh
TMPDIR=$(mktemp -d) HOME="$TMPDIR/home" bash install-global-instructions.sh
ls "$HOME/.claude/CLAUDE.md"                          # 생성 확인
ls "$TMPDIR/home/.claude/*.XXXXXX" 2>/dev/null        # 실패 시 tmp 잔재 없어야 함
```

## 커밋 메시지 (예시)
```
fix(install-global-instructions): make mktemp+mv atomic via same-filesystem tmp
```