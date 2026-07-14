# 병합 승인 조건 (Merge Requirements)

이 문서는 PR이 `main` 브랜치로 머지되기 위해 **반드시** 충족해야 하는 조건을 정의한다.
모든 조건은 **기계 판정 가능**(exit code 0/1)하거나 **사람 운영자가 명시적으로 확인**할 수 있어야 한다.

## 충돌 해결 원칙

- 어떤 에이전트도 이 조건을 "판정"하지 않는다. CI가 자동 검사하고, 사람이 최종 승인한다.
- 조건을 만족하지 못한 상태에서 머지하려고 하면 CI가 차단한다.
- 자동화된 검사 항목은 [`.github/workflows/shell.yml`](../.github/workflows/shell.yml)에 정의되어 있다.

---

## M-1. CI 자동 검사 (필수, 기계 판정)

| ID | 검사 | 판정 기준 | 실패 시 |
|----|------|-----------|---------|
| M-1.1 | ShellCheck | `shellcheck --severity=warning install-skills.sh install-global-instructions.sh tests/installers_test.sh` exit 0 | PR 차단 |
| M-1.2 | 설치 테스트 | `bash tests/installers_test.sh` exit 0 | PR 차단 |
| M-1.3 | 커밋 메시지 규약 | 모든 커밋이 `(task NN)` 또는 `(tasks NN,MM)` 토큰을 가짐 | PR 차단 |
| M-1.4 | 작업 카드 위치 | `tasks/001.todo/total/` 에 미완료 카드가 남지 않음 (또는 PR 본문에 사유 명시) | 경고 → 운영자 판단 |
| M-1.5 | AI 트레일러 부재 | 커밋 메시지에 `Co-Authored-By: Claude`, `Generated with Claude Code` 등 AI 푸터 없음 | PR 차단 |
| M-1.6 | agents 디렉토리 무결성 | `agents/codex.yaml` 존재 + `agents/openai.yaml` 부재 | PR 차단 |

## M-2. PR 본문 체크리스트 (사람 운영자가 확인)

PR 본문은 [`.github/PULL_REQUEST_TEMPLATE.md`](../.github/PULL_REQUEST_TEMPLATE.md)을 사용하며, 다음을 모두 체크해야 한다.

- [ ] 관련 작업 카드 번호 명시 (`tasks/002.done/total/NN-*.md`)
- [ ] 변경 요약 (코드/스크립트/문서/CI 중 무엇이 바뀌었는지)
- [ ] 위험 평가 (사용자 파일을 건드릴 가능성, 백업 동작, 롤백 방법)
- [ ] 테스트 결과 요약 (어떤 케이스를 추가/실행했는지)
- [ ] 문서/작업 카드 이동 (`git mv` 또는 STATUS.md 갱신 여부)

## M-3. 사람 리뷰어 승인 (필수, 사람 판정)

- 최소 1명의 사람 운영자가 GitHub PR UI에서 명시적으로 **Approve** 해야 한다.
- 자동 approve (예: CODEOWNERS만으로 자동 통과되는 경우)는 인정하지 않는다.

## M-4. 정책 준수 (필수, 사람 판정)

- [ ] 새 머신에서 `bash tests/installers_test.sh` 단독 실행이 가능 (외부 의존성 없음)
- [ ] README에 명시된 절차와 실제 동작이 일치 (사람이 한 번 수동 검증)
- [ ] `install-skills.sh`와 `install-global-instructions.sh`가 실제 사용자 파일을 건드리지 않음 (테스트로 이미 보장되지만 운영자가 재확인)

---

## 머지 차단 알고리즘

```
머지 가능 여부 = (M-1 모두 통과) AND (M-2 모두 체크) AND (M-3 사람 승인) AND (M-4 운영자 확인)
```

하나라도 충족하지 못하면 머지 불가.

---

## 자동 검증 스크립트

다음 명령으로 M-1.1, M-1.2, M-1.3, M-1.5, M-1.6을 로컬에서 검증할 수 있다:

```bash
bash tests/installers_test.sh
shellcheck --severity=warning install-skills.sh install-global-instructions.sh tests/installers_test.sh
git log main..HEAD --pretty='%s' | grep -vE '\(tasks? [0-9, \-]+\)' && echo "FAIL: 누락된 작업 토큰" || echo "OK"
git log main..HEAD --pretty='%s' | grep -iE 'co-authored-by|generated with' && echo "FAIL: AI 트레일러" || echo "OK"
test -f skills/paced-explainer/agents/codex.yaml && ! -e skills/paced-explainer/agents/openai.yaml && echo "OK" || echo "FAIL"
```

---

## 변경 이력

- 2026-07-14: 초안 작성 (1차 사이클 total 머지용)