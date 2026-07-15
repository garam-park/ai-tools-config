# 10. install-skills.sh에 nullglob 설정

## 상태
- [x] 시작 전
- [x] 적용
- [x] 검증
- [x] 완료

## 우선순위
⚪ **P3 — 셸 견고성**

## 보강 참조
- ← [24-empty-srcdir-warning.md](24-empty-srcdir-warning.md) — 같은 커밋에 묶어 적용 권장

## 제안 모델
- ✅ claude ([10-add-nullglob.md](../claude/10-add-nullglob.md)) — 구체적
- ✅ codex ([02-fix-skill-source-discovery.md](../codex/02-fix-skill-source-discovery.md)) — 간략
- ❌ m3

## 문제
기본값에서 `nullglob`이 꺼져 있어, `"$SRC_DIR"/*/`가 아무것도 매칭하지 못하면 Bash는 패턴을 그대로 남긴다. 그러면 루프가 `skill_dir = "$SRC_DIR"/*/` 리터럴로 한 번 돌고 `name`이 `*`가 되어 `ln -s`로 `*`라는 이름의 깨진 심링크가 생성된다.

`ln`이 성공하므로 `set -euo pipefail`에서도 중단되지 않아 **조용히** 발생한다.

(실제 트리거되려면 스크립트를 하위 디렉토리 없는 폴더에 두어야 해 드문 경우지만, 방어는 한 줄.)

## 권장 구현

`for` 루프 앞에 추가:

```bash
shopt -s nullglob
```

매칭 없을 때 루프가 0회 실행된다.

## 완료 조건
- [x] 하위 디렉토리가 없는 경우 루프가 0회 돌고 `*` 심링크가 생기지 않는다
- [x] 정상 케이스 동작은 변하지 않는다

## 검증
```sh
TMPDIR=$(mktemp -d)
mkdir -p "$TMPDIR/src" && cp install-skills.sh "$TMPDIR/src/"
HOME="$TMPDIR/home" bash "$TMPDIR/src/install-skills.sh"   # 하위 디렉토리 없는 src
ls "$HOME/.claude/skills" 2>&1     # 비어있거나 없음. '*' 링크 없어야 함
```

## 커밋 메시지 (예시)
```
fix(install-skills): enable nullglob to prevent literal '*' symlink
```