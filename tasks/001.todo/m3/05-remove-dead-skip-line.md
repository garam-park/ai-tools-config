# 05. install-skills.sh의 dead code 제거

## 상태
- [ ] 시작 전
- [ ] 수정 적용
- [ ] 검증
- [ ] 완료

## 우선순위
하

## 문제
[install-skills.sh:26-28](install-skills.sh#L26-L28) 의 스킵 로직은 절대 매칭되지 않는다.

```bash
for skill_dir in "$SRC_DIR"/*/; do       # 폴더만 매칭 (슬래시로 끝남)
  [[ "$(basename "$skill_dir")" == "install-skills.sh" ]] && continue
```

`"$SRC_DIR"/*/`는 폴더만 매칭하므로 `install-skills.sh`(파일)는 절대 이 분기에 들어오지 않는다. 따라서 continue 라인 자체가 dead code다.

## 변경 파일
- `install-skills.sh`

## 변경 내용
해당 continue 라인 제거:

```bash
for skill_dir in "$SRC_DIR"/*/; do
  name="$(basename "$skill_dir")"
  link="$target/$name"
  # 기존 항목 제거 (파일/링크/디렉토리 모두)
  rm -rf "$link"
  ln -s "$skill_dir" "$link"
  echo "linked: $link -> $skill_dir"
done
```

## 검증
```sh
bash -n install-skills.sh                     # 문법 검사
bash install-skills.sh                        # 실제로 동작 확인 (멱등성)
```

## 커밋 메시지 (예시)
```
chore(install-skills): remove unreachable skip line
```