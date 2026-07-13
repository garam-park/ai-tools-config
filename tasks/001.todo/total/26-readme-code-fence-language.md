# 26. README 코드 펜스 언어 태그 (sh → bash)

## 상태
- [ ] 시작 전
- [ ] 적용
- [ ] 검증
- [ ] 완료

## 우선순위
⚪ **P3 — 문서 정확성**

## 제안
**메타 분석** (세 모델 모두 미발굴)

## 문제
[README.md:22-37](../../README.md#L22-L37) 의 코드 블록이 `sh`로 표기:

````
```sh
# 1) 리포 clone
git clone git@github.com:garam-park/ai-tools-config.git ~/ai-tools-config
...
```
````

하지만 스크립트는 **bash 전용**(`[[ ]]`, `BASH_SOURCE`, `${var%/}`, `declare -a` 등 POSIX 비호환). sh 펜스로 표기하면:
- 사용자가 dash/ash로 실행해 실패할 수 있음
- 문서/코드 시맨틱 불일치
- GitHub의 신택스 하이라이팅도 sh와 bash가 미묘하게 다름

같은 사유로 작업 **18**에서 명시될 WSL/Git Bash 안내와 직접 연결됨.

## 권장 구현

모든 셸 코드 블록의 펜스를 `bash`로 변경:

````
```bash
# 1) 리포 clone
git clone git@github.com:garam-park/ai-tools-config.git ~/ai-tools-config
...
```
````

대상 위치:
- "새 머신에서 사용하기" 섹션의 모든 셸 블록
- "스킬 추가하기"의 `git add . && git commit && git push` 라인
- (있다면) "동기화되는 도구" 아래의 예시

## 완료 조건
- [ ] README의 모든 셸 코드 블록이 `bash` 펜스로 표기
- [ ] GitHub에서 bash 하이라이팅이 정상 동작

## 검증
```sh
grep -n '^```sh' README.md       # 매칭 없어야 함
grep -n '^```bash' README.md     # 모든 셸 블록이 매칭
```

## 커밋 메시지 (예시)
```
docs(readme): use bash fence for shell snippets (scripts are bash-specific)
```