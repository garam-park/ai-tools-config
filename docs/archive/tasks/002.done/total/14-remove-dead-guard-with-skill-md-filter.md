# 14. install-skills.sh — 죽은 가드 제거 + SKILL.md 필터

## 상태
- [x] 시작 전
- [x] 적용
- [x] 검증
- [x] 완료

## 우선순위
⚪ **P3 — 셸 견고성 + 구조 개선**

## 제안 모델
- ✅ claude ([09-remove-dead-guard-filter-by-skill-md.md](../claude/09-remove-dead-guard-filter-by-skill-md.md)) — **가장 완성도 높은 해결**
- ✅ codex ([02-fix-skill-source-discovery.md](../codex/02-fix-skill-source-discovery.md))
- ✅ m3 ([05-remove-dead-skip-line.md](../m3/05-remove-dead-skip-line.md)) — 단순 제거만 (부족)

## 문제
[install-skills.sh:32-33](../../install-skills.sh#L32-L33):

```bash
for skill_dir in "$SRC_DIR"/*/; do
  [[ "$(basename "$skill_dir")" == "install-skills.sh" ]] && continue
```

- 후행 슬래시 글롭이라 **디렉토리만** 매칭한다
- 따라서 `install-skills.sh`(파일)는 절대 순회 대상이 아니다 → **절대 실행되지 않는 죽은 코드**

부수 효과: 이 가드는 리포 루트에서 실행 시 `global-instructions/` 같은 비-스킬 디렉토리도 걸러주지 못한다.

## 권장 구현 (claude안 채택)

죽은 가드를 지우고, **SKILL.md 존재 여부**로 실제 스킬만 링크:

```bash
for skill_dir in "$SRC_DIR"/*/; do
  [[ -f "$skill_dir/SKILL.md" ]] || continue   # 스킬이 아닌 디렉토리 건너뜀
  name="$(basename "$skill_dir")"
  ...
```

## 완료 조건
- [x] 죽은 `install-skills.sh` 비교 가드 제거
- [x] `SKILL.md`가 없는 디렉토리는 링크되지 않음
- [x] `paced-explainer`는 정상적으로 링크됨

## 검증
```sh
# 리포 루트에 global-instructions/ 등이 있어도 스킬로 잘못 링크되지 않아야 함
bash install-skills.sh
ls ~/.claude/skills/                        # paced-explainer만 있어야 함
ls ~/.config/opencode/skills/               # paced-explainer만 있어야 함
```

## 참고
- 작업 **01**(rm-rf 가드), **10**(nullglob), **13**(후행 슬래시)와 같은 파일/루프 → 한 번에 묶어 커밋하면 효율적

## 커밋 메시지 (예시)
```
refactor(install-skills): filter skills by SKILL.md, drop dead guard
```