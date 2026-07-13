# 09. 죽은 가드 제거 + SKILL.md 존재로 스킬 필터링

- **우선순위**: P3 (사소한 정리 — 셸 견고성)
- **대상 파일**: `install-skills.sh` (L32–L33)
- **상태**: TODO

## 문제

L32: `for skill_dir in "$SRC_DIR"/*/; do` — 후행 슬래시 글롭이라 **디렉토리만** 매칭한다.
L33: `[[ "$(basename "$skill_dir") == "install-skills.sh" ]] && continue` — 정규 파일을 걸러내려는 가드지만,
디렉토리만 순회하므로 `install-skills.sh` 파일은 애초에 순회 대상이 아니다 → **절대 실행되지 않는 죽은 코드**.

부수 효과: 이 가드는 리포 루트에서 실행 시 `global-instructions/` 같은 비-스킬 디렉토리도 걸러주지 못한다.
(관련 기각 후보 참고 — 문서상 지원 사용법은 아니지만, 필터를 스킬 판별로 바꾸면 함께 방어된다.)

## 수정 방향

죽은 가드를 지우고, **SKILL.md 존재 여부**로 실제 스킬만 링크한다.

```bash
for skill_dir in "$SRC_DIR"/*/; do
  [[ -f "$skill_dir/SKILL.md" ]] || continue   # 스킬이 아닌 디렉토리 건너뜀
  name="$(basename "$skill_dir")"
  ...
```

## 완료 조건

- [ ] 죽은 `install-skills.sh` 비교 가드가 제거됨
- [ ] `SKILL.md`가 없는 디렉토리는 링크되지 않는다
- [ ] `paced-explainer`는 정상적으로 링크된다

## 참고

작업 02, 10, 12와 같은 파일(`install-skills.sh`)의 같은 루프를 수정하므로 한 번에 처리하면 효율적이다.
