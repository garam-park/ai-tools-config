# 01. install-skills.sh — 파괴적 링크 교체 방어

## 상태
- [ ] 시작 전
- [ ] 적용
- [ ] 검증
- [ ] 완료

## 우선순위
🔴 상 (데이터 손실 위험)

## 문제
[install-skills.sh:37-39](../../install-skills.sh#L37-L39) 는 링크를 재생성하기 전에 기존 항목을 **무조건 재귀 삭제**한다.

```sh
# 기존 항목 제거 (파일/링크/디렉토리 모두)
rm -rf "$link"
ln -s "$skill_dir" "$link"
```

`$link`(`$target/$name`)에 **실제 디렉토리**가 있을 때(예: 다른 머신에서 손으로 편집한 `~/.claude/skills/paced-explainer/`, 아직 커밋 안 된 로컬 전용 스킬)에도 `rm -rf`가 내부까지 재귀 삭제한다. 주석 스스로 "파일/링크/디렉토리 모두"라고 인정하고 있어, **복구 불가능한 로컬 데이터 손실**이 발생할 수 있다. 안전한 경우는 기존 항목이 심볼릭 링크일 때뿐이다.

## 변경 파일
- `install-skills.sh`

## 작업
- [ ] 기존 항목이 심볼릭 링크(`[[ -L "$link" ]]`)일 때만 `rm -f`로 제거한다.
- [ ] 실제 파일/디렉토리(`-e` 이지만 `-L` 아님)면 삭제하지 않고 건너뛰며 `stderr`로 명확히 경고한다.
- [ ] 이미 올바른 대상을 가리키는 링크면 재생성을 생략(또는 무해하게 재생성)해 멱등성을 유지한다.
- [ ] 링크 생성 후 실제로 대상이 해석되는지 간단히 확인한다(선택).

## 권장 구현 (예시)
```sh
if [[ -L "$link" ]]; then
  rm -f "$link"
elif [[ -e "$link" ]]; then
  echo "skip: $link 은(는) 실제 파일/디렉토리라 덮어쓰지 않음 (수동 확인 필요)" >&2
  continue
fi
ln -s "$skill_dir" "$link"
```

## 완료 조건
- 대상에 실제 디렉토리가 있으면 삭제되지 않고 경고 후 건너뛴다.
- 대상이 심볼릭 링크이거나 비어 있으면 기존처럼 링크가 재생성된다.
- 여러 번 실행해도 결과가 동일하다(멱등).

## 검증
```sh
# 실제 디렉토리를 만들어 두고 보호되는지 확인
mkdir -p ~/.claude/skills/paced-explainer && touch ~/.claude/skills/paced-explainer/LOCAL_ONLY
bash install-skills.sh          # skip 경고가 나오고 LOCAL_ONLY 가 살아있어야 함
ls ~/.claude/skills/paced-explainer/LOCAL_ONLY
```
> ⚠️ Unix/WSL 환경에서 검증. 테스트 후 임시로 만든 디렉토리는 정리한다.

## 커밋 메시지 (예시)
```
fix(install-skills): 실제 디렉토리를 rm -rf 로 지우지 않도록 심링크만 교체
```
