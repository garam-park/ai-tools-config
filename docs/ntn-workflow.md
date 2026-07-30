---
title: "ntn-* 워크플로"
date: 2026-07-18
author: GitHub Copilot
tags: [ntn, notion, workflow, skills]
description: "Notion TSK 작업을 analyze부터 PR 후속 처리까지 단계별로 연결해 설명한다."
---

# ntn-* 워크플로

`ntn-*`는 Notion의 `TSK-*` 작업을 분석부터 PR 후속 처리까지 단계별로 나눈 스킬 묶음이다. 각 스킬은 같은 안전 원칙을 공유하지만, 허용되는 부작용과 종료 지점이 다르다.

## 한눈에 보는 흐름

1. `ntn-analyze-task`: 작업 의미, 범위, 리스크를 읽기 전용으로 해석한다.
2. `ntn-spec-task`: 구현 가능한 요구사항과 인수 조건으로 명세를 구체화한다.
3. `ntn-start-task`: Notion 상태를 `진행 중`으로 바꾸고 브랜치 또는 워크트리를 준비한 뒤 구현을 시작한다.
4. `ntn-create-pr`: 작업 브랜치를 검증하고 최초 PR을 생성하거나 재사용한다.
5. `ntn-review-pr`: 리뷰, CI, 후속 수정, merge readiness를 처리한다.

```mermaid
flowchart LR
  A[ntn-analyze-task] --> B[ntn-spec-task]
  B --> C[ntn-start-task]
  C --> D[ntn-create-pr]
  D --> E[ntn-review-pr]
```

## 공통 계약

- 입력으로 받은 숫자 ID는 `TSK-<number>` 형식으로 정규화한다.
- 작업 식별이 애매하면 짧은 확인 질문 한 번으로 좁힌다.
- 사용자 작업 트리와 관련 없는 변경은 건드리지 않는다.
- `stash`, `reset`, `rebase`, 브랜치 삭제처럼 파괴적인 Git 동작은 명시 승인 없이 하지 않는다.
- Notion, 코드, PR에 대한 쓰기 권한은 단계별로 다르게 제한된다.
- Notion task database 설정은 프로젝트 루트 `.env.tsk`의 `NOTION_DATABASE_ID`, `NOTION_DATA_SOURCE_ID`를 기준으로 한다.
- `.env.tsk`에 필요한 값이 없으면 기본값을 쓰지 않는다. 확인 가능한 Notion database 또는 task 링크를 사용자에게 받아 값을 확인한 뒤 `.env.tsk`를 생성하거나 업데이트한다.
- 모든 `ntn-*` 스킬은 `ntn` CLI가 설치·인증·접근 가능하다고 전제하고 실제 Notion 작업 명령을 먼저 실행한다. 환경 확인만을 위한 `command -v ntn`, `ntn --version`, `ntn doctor` 같은 사전 점검은 하지 않는다.
- 실제 `ntn` 명령이 없거나 인증되지 않았거나 워크스페이스에 접근할 수 없어 실패하면, 그 실패 지점을 설명하고 설치, 로그인, 검증 절차를 안내한다. 현재 도구가 설치를 대신 수행할 수 있으면 실제 실패 이후 사용자 승인을 받은 뒤 설치한다.
- `ntn` 명령 실패 원인을 확인한 뒤에만 다른 Notion 통합이나 사용자가 제공한 Notion 본문처럼 Notion을 읽을 수 있는 경로를 fallback으로 찾는다.
- Notion 접근 경로가 없으면 먼저 사용자에게 실패 원인과 가능한 대안을 알린다. 로컬 task 파일, 브랜치, PR, 저장소 파일을 Notion 작업 출처로 대체하지 않는다.

## 단계별 선택 기준

| 상황 | 사용할 스킬 | 읽는 대상 | 쓰는 대상 |
|------|-------------|-----------|-----------|
| 작업이 무엇을 요구하는지 먼저 알고 싶다 | `ntn-analyze-task` | Notion, 필요한 저장소 문맥 | 없음 |
| 구현 전에 요구사항과 인수 조건을 고정하고 싶다 | `ntn-spec-task` | Notion, 필요한 저장소 문맥 | 승인 전 없음, 승인 후 Notion |
| 실제 구현을 시작해야 한다 | `ntn-start-task` | Notion, 저장소 README, 규칙 문서 | Notion 상태, 브랜치/워크트리 |
| 구현이 끝났고 첫 PR을 열어야 한다 | `ntn-create-pr` | 브랜치 상태, diff, 커밋, README, 필요 시 Notion task 문맥 | 커밋, push, PR |
| 이미 열린 PR의 리뷰나 CI를 처리해야 한다 | `ntn-review-pr` | PR 메타데이터, 리뷰 스레드, 체크 결과, 로컬 상태 | 후속 커밋, push, PR 업데이트 |

## 단계별 종료 지점

### `ntn-analyze-task`

- 목적: 작업을 설명 가능한 상태로 만든다.
- 멈추는 지점: 구현 방향, 리스크, 불명확한 점, 추천 다음 단계를 정리하면 끝난다.
- 하지 않는 일: 상태 변경, 브랜치 생성, 코드 수정, PR 조작.

### `ntn-spec-task`

- 목적: 작업을 구현 가능한 명세 초안으로 만든다.
- 멈추는 지점: 문제, 목표, 비목표, 요구사항, 인수 조건, 테스트 계획, 가정이 정리되면 끝난다.
- 하지 않는 일: 사용자 승인 전 쓰기, 구현 시작, PR 생성.

### `ntn-start-task`

- 목적: 작업을 실제 구현 가능한 작업 상태로 전환한다.
- 멈추는 지점: Notion 상태가 적절히 반영되고, 안전한 브랜치 또는 워크트리가 준비되어 구현이 시작되면 된다.
- 특징: `ntn` CLI로 작업을 조회하고 상태를 갱신한다. REST fallback 스크립트와 프로젝트 로컬 `notion` MCP를 기본 경로로 쓰지 않는다.

### `ntn-create-pr`

- 목적: 구현 결과를 리뷰 가능한 PR로 올린다.
- 멈추는 지점: 검증, 커밋, push, PR 생성 또는 재사용, merge criteria 정리가 끝나면 멈춘다.
- 하지 않는 일: merge.

### `ntn-review-pr`

- 목적: 열린 PR을 merge decision 직전까지 끌고 간다.
- 멈추는 지점: 리뷰 코멘트, CI 실패, 보강 검증, 잔여 리스크가 정리되면 끝난다.
- 하지 않는 일: 사용자가 명시하지 않은 merge.

## 자주 갈리는 판단

### analyze와 spec의 차이

- `ntn-analyze-task`는 작업을 해석한다.
- `ntn-spec-task`는 구현자가 바로 움직일 수 있도록 명세를 고정한다.
- 요구사항이 이미 충분히 구체적이면 analyze를 건너뛰고 spec 또는 start로 갈 수 있다.

### start와 create-pr의 경계

- `ntn-start-task`는 구현을 시작하는 단계다.
- `ntn-create-pr`는 이미 구현된 변경을 검증하고 리뷰 절차에 올리는 단계다.
- 현재 브랜치가 `main`이거나 task branch가 없으면 create-pr가 아니라 start에 가깝다.

### create-pr와 review-pr의 경계

- PR이 아직 없거나 최초 설명이 비어 있으면 `ntn-create-pr`를 쓴다.
- PR이 이미 있고 리뷰, CI, 후속 수정이 남아 있으면 `ntn-review-pr`를 쓴다.

## 현재 설계에서 알아둘 점

- `ntn-analyze-task`, `ntn-spec-task`, `ntn-start-task`는 모두 `ntn` CLI가 준비되어 있다고 보고 필요한 Notion 조회나 갱신 명령을 바로 실행한다.
- `ntn-create-pr`, `ntn-review-pr`도 task metadata가 필요할 때만 `ntn` 조회 명령을 실행하고, 실패하면 사용자에게 설치/로그인/접근권한 설정을 안내한다. 이미 준비된 PR/브랜치/diff만으로 요청한 PR 작업을 처리할 수 있으면 Notion task metadata 없이 계속할 수 있다.
- 여기서 fallback은 Notion을 읽기 위한 대체 경로를 뜻한다. Notion이 아닌 로컬 task 파일, 브랜치, PR, 저장소 파일을 작업 출처로 대체하지 않는다.
- REST 직접 호출 fallback 스크립트는 두지 않는다. Notion 접근이 없으면 `ntn` 설치와 로그인, `.env.tsk` 설정, 확인 가능한 Notion 링크, 워크스페이스 접근권한 설정을 안내한다.
- `ntn-create-pr`, `ntn-review-pr`는 `gh`가 준비되어 있다고 보고 필요한 PR 명령을 바로 실행한다. 실제 `gh` 명령이 실패할 때만 설치·인증·remote 설정 절차를 안내한다.
- GitHub Copilot은 이 리포에서 스킬은 받지만 글로벌 지침은 받지 않는다. 도구별 체감 일관성은 다를 수 있다.
- `skills/<name>/agents/codex.yaml`은 모든 ntn 스킬에 존재하지만, 현재 문서 기준으로는 family 전체 무결성 검사가 강하게 걸려 있지 않다.

## 관련 문서

- [README.md](../README.md)
- [docs/concepts.md](concepts.md)
- [docs/extending.md](extending.md)
- [docs/platform-mapping.md](platform-mapping.md)
- [skills/ntn-analyze-task/SKILL.md](../skills/ntn-analyze-task/SKILL.md)
- [skills/ntn-spec-task/SKILL.md](../skills/ntn-spec-task/SKILL.md)
- [skills/ntn-start-task/SKILL.md](../skills/ntn-start-task/SKILL.md)
- [skills/ntn-create-pr/SKILL.md](../skills/ntn-create-pr/SKILL.md)
- [skills/ntn-review-pr/SKILL.md](../skills/ntn-review-pr/SKILL.md)
