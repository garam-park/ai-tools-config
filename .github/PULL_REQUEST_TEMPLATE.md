## 무엇을 바꿨나

<!-- 구현자(implementer) 또는 문서 담당자(documenter)가 작성.
     평가성 단어("좋다/나쁘다/완벽하다") 사용 금지. 사실만 기술. -->

- **대상 파일**: (예: `install-skills.sh`, `README.md`)
- **변경 요약**: (한두 문장)

## 위험 평가

<!-- 사용자 파일을 건드릴 가능성, 백업 동작, 롤백 방법. -->

- 사용자 파일 영향: 있음 / 없음
- 백업 동작: (예: `.bak.<timestamp>` 자동 생성) / 없음
- 롤백 방법: (예: `git revert <commit>`)

## 테스트

<!-- 테스터(tester) 또는 구현자가 작성.
     테스트 이름과 결과(exit code)만 명시. 평가성 단어 금지. -->

- [ ] `bash tests/installers_test.sh` 실행 (exit 0)
- [ ] `shellcheck --severity=warning ...` 실행 (clean)

추가된/변경된 테스트 케이스:

- (예: "task 23 심링크 dest 보존 케이스 — PASS")

## 머지 승인 조건 확인

머지 승인 조건은 [`.github/MERGE_REQUIREMENTS.md`](MERGE_REQUIREMENTS.md) 참조. 다음은 사람 운영자가 확인:

- [ ] M-1 CI 자동 검사 모두 통과
- [ ] M-2 PR 본문 체크리스트 모두 체크
- [ ] M-3 사람 리뷰어 승인
- [ ] M-4 정책 준수 확인

> **자동 승인 금지**: 어떤 자동화(에이전트·CODEOWNERS 자동 통과 등)도 사람 운영자의 명시적 Approve를 대체하지 않는다.