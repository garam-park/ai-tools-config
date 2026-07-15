# 멀티에이전트 운영 규약

이 리포는 **4개 역할의 에이전트**로 작업을 분담한다. 각 에이전트는 자기 영역의 구현만 수행하며, 다른 에이전트의 작업이나 PR에 대해 **평가/승인/거부 권한이 없다**.

## 역할 매트릭스

| 에이전트 | 파일 | 할 수 있는 것 | 절대 할 수 없는 것 |
|----------|------|---------------|-------------------|
| `implementer` | [implementer.agent.md](implementer.agent.md) | 코드/스크립트/마크다운/YAML 작성 | 리뷰, 승인, 머지, 다른 에이전트 평가 |
| `tester` | [tester.agent.md](tester.agent.md) | 테스트 작성/실행, 사실 기반 결과 보고 | 코드 수정, 리뷰, 승인, 주관적 품질 평가 |
| `documenter` | [documenter.agent.md](documenter.agent.md) | README/STATUS/작업 카드/CHANGELOG 갱신 | 코드 수정, 리뷰, 승인, "충분하다" 판정 |
| `ci-runner` | [ci-runner.agent.md](ci-runner.agent.md) | `.github/workflows/*.yml` 작성/유지 | 자동 approve, 사람의 리뷰 대체, 머지 |

## 핵심 원칙

1. **승인 권한의 분리** — 어떤 에이전트도 PR을 approve/merge할 수 없다. 머지 결정은 사람 운영자가 한다.
2. **자기 영역만** — 각 에이전트는 자신의 산출물 범위(코드/테스트/문서/CI)를 벗어난 수정을 하지 않는다.
3. **사실 기반 보고** — 평가성 단어("좋다/나쁘다/충분하다")를 쓰지 않는다. 측정값과 사실만 보고한다.
4. **기계 판정 가능** — CI 룰은 exit code로 판정 가능해야 한다. 사람의 주관 판단이 필요한 검사는 정의하지 않는다.
5. **체인 가능** — implementer → tester → documenter → ci-runner 순서로 작업이 흐른다. 각 단계는 이전 단계의 산출물을 입력으로만 받고, 평가하지 않는다.

## 작업 흐름 예시

```
[작업 요청 또는 작업 카드]
        │
        ▼
   implementer (코드 작성 + 커밋)
        │
        ▼
   tester (테스트 작성/실행 + 사실 보고)
        │
        ▼
   documenter (README·STATUS·작업 카드 갱신)
        │
        ▼
   ci-runner (자동 검사 워크플로우 보강)
        │
        ▼
   사람 운영자 (리뷰 + 승인 + 머지)
```

## 머지 승인 조건

자세한 조건은 [MERGE_REQUIREMENTS.md](../MERGE_REQUIREMENTS.md) 참조.

요약:
- CI 자동 검사 모두 통과 (ShellCheck clean + 테스트 exit 0)
- 커밋 메시지 규약 준수 (작업 카드 관련 커밋에 한해 `(task NN)` 또는 `(tasks NN,MM)`)
- 사람 운영자 리뷰 승인

**에이전트는 위 조건을 "판정"하지 않는다. CI 룰이 판정하고, 사람이 최종 승인한다.**