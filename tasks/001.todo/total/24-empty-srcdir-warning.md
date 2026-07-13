# 24. install-skills.sh — 빈 SRC_DIR 명시적 경고

## 상태
- [ ] 시작 전
- [ ] 적용
- [ ] 검증
- [ ] 완료

## 우선순위
🟡 **P2 — 작업 10 보강**

## 제안
**메타 분석** (세 모델 모두 미발굴)

## 의존
- ← 작업 **10**(nullglob) 적용 후 빈 글롭이 0회 루프로 처리됨. 그 상태에서 사용자에게 "아무것도 안 했다"는 명시적 신호가 없음.

## 문제
작업 10 적용 후:
```bash
shopt -s nullglob
for skill_dir in "$SRC_DIR"/*/; do   # 매칭 없으면 루프 0회
  ...
done
echo "완료. 다음 도구에서 사용 가능: ..."
```

`$SRC_DIR`에 `SKILL.md`를 가진 폴더가 하나도 없을 때:
- 스크립트는 **에러 없이 성공 메시지를 출력**한다
- 사용자는 "왜 내 스킬이 안 보이지?" 디버깅에 시간 낭비
- 특히 권한 문제로 SRC_DIR이 비어 보이는 경우(예: 네트워크 마운트 실패) 같은 진짜 문제와 구분 불가

## 권장 구현 (작업 10 패치에 통합)

루프 진입 전 또는 후에 카운트 검증:

```bash
shopt -s nullglob
skill_dirs=( "$SRC_DIR"/*/ )
linked_count=0

if [[ ${#skill_dirs[@]} -eq 0 ]]; then
  echo "warning: $SRC_DIR 에 디렉토리가 없습니다. 스킬 원본 위치를 확인하세요." >&2
  exit 1
fi

# ... 기존 루프에서 linked_count++ 추가 ...
# 루프 종료 후
if [[ $linked_count -eq 0 ]]; then
  echo "warning: $SRC_DIR 에 SKILL.md가 있는 스킬이 없습니다. 디렉토리 구조를 확인하세요." >&2
  exit 1
fi
```

두 단계로 분리하는 이유:
- 첫 번째: 디렉토리 자체가 없음 → 위치 자체가 잘못됨
- 두 번째: 디렉토리는 있지만 스킬이 없음 → 구조가 잘못됨 (예: SKILL.md 빠뜨림)

## 완료 조건
- [ ] `$SRC_DIR`에 디렉토리가 하나도 없으면 stderr 경고 후 비정상 종료 (exit 1)
- [ ] 디렉토리는 있지만 `SKILL.md`를 가진 곳이 없으면 stderr 경고 후 비정상 종료
- [ ] 정상 케이스 동작은 변하지 않음

## 검증
```sh
TMPDIR=$(mktemp -d) && HOME="$TMPDIR/home" bash install-skills.sh
# → "warning: ... 디렉토리가 없습니다" 출력 후 exit 1

mkdir -p "$TMPDIR/src" && cp install-skills.sh "$TMPDIR/src/" && touch "$TMPDIR/src/random.md"
HOME="$TMPDIR/home" bash "$TMPDIR/src/install-skills.sh"
# → "warning: ... SKILL.md가 있는 스킬이 없습니다" 출력 후 exit 1
```

## 커밋 메시지 (예시, 작업 10과 통합 시)
```
fix(install-skills): warn explicitly when source has no skills
```