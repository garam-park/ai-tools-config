---
name: lc-archive-task
description: 완료된 로컬 planning 작업(T0xx) 문서를 planning/archive/tasks/mNNN/로 아카이브하고 index 영향을 보고합니다. 사용자가 `$lc-archive-task` 또는 `/lc-archive-task`를 호출할 때, 완료된 작업을 planning 아카이브로 옮겨 달라고 요청할 때, 또는 끝난 작업 문서를 정리해 달라고 요청할 때 사용합니다. 사용자가 승인한 문서만 이동하며 제품 코드, 후보, 생성 파일은 전혀 수정하지 않습니다.
---

# 작업 아카이브 (Local Lifecycle)

완료된 planning 문서를 프로젝트의 `planning/archive/` 트리로 옮기면서 이력을 보존합니다. 문서 이동 워크플로이며 작업 내용, 상태의 의미, 제품 코드는 전혀 변경하지 않습니다.

## 작업 출처

- 진입 순서: `docs/.agents/planning-guide.md`(존재 시) → `planning/milestones/index.md` → `planning/tasks/index.md`.
- 활성 작업 문서는 `planning/tasks/` 바로 아래 또는 `mNNN/` 하위 폴더에 있고, 아카이브는 `planning/archive/tasks/mNNN/`에 마일스톤 단위로 묶입니다. 완료 마일스톤 문서는 `planning/archive/milestones/`에 있습니다.
- 작업 ID는 `T001`, 마일스톤 ID는 `M001` 형식이며 ID는 재사용하지 않습니다.
- 상태 값: `todo`, `doing`, `done`, `blocked`. frontmatter에 기록하고 index 현황판과 동기 유지합니다.

## 프로젝트 루트와 대상 해석

1. 사용자가 제공한 프로젝트 경로를 사용합니다. 없으면 현재 디렉터리에서 상위로 올라가며 에이전트 안내 문서(`AGENTS.md` 또는 동등 문서)와 `planning/`을 모두 포함하는 첫 디렉터리를 찾습니다. planning 진입점이 없으면 프로젝트가 로컬 planning 규약을 따르지 않는다고 알리고 중단합니다.
2. 작업 ID(마일스톤 문서 아카이브면 마일스톤 ID)를 받아 정규화합니다.
3. 문서를 찾아 frontmatter, 소속 마일스톤, 두 index 현황판을 읽습니다.
4. 문서를 찾을 수 없거나, 모호하거나, 이미 `planning/archive/` 아래에 있으면 보고하고 중단합니다.

## 아카이브 조건

다음 조건이 모두 충족될 때만 아카이브합니다. 하나라도 어긋나면 중단하고 어떤 조건이 실패했는지 설명합니다.

- 작업 문서가 활성 경로에 있을 것(이미 아카이브된 상태가 아닐 것).
- 작업 `status`가 frontmatter와 `planning/tasks/index.md` 양쪽에서 `done`일 것. `todo`, `doing`, `blocked` 작업은 아카이브하지 않습니다.
- 대상 디렉터리 `planning/archive/tasks/mNNN/`이 작업의 소속 마일스톤과 일치하고, 대상 파일이 이미 존재하지 않을 것.

마일스톤 문서는 사용자가 명시적으로 요청하고 해당 마일스톤의 모든 작업이 `done`이자 아카이브된 상태(또는 index 행이 히스토리화된 상태)일 때만 아카이브합니다. 후보 `MC*` 문서는 아카이브하지 않으며 승격 전까지 `planning/candidates/`에 남습니다.

## 계획과 이동

1. 어떤 것도 이동하기 전에 정확한 변경 계획을 먼저 제시합니다. 원본 경로, 대상 경로, 이동 후 더 이상 해석되지 않는 모든 index 링크를 포함합니다.
2. 승인된 문서는 `git mv`로 이동해 이력이 rename으로 보존되게 합니다. 이동 중 문서 내용을 고치지 않습니다.
3. `planning/tasks/index.md`와 `planning/milestones/index.md`의 히스토리 행은 기본값으로 그대로 유지합니다. 프로젝트의 기존 패턴은 완료 행을 링크가 아카이브를 가리키게 되더라도 히스토리로 보존합니다. index 행을 몰래 다시 쓰거나 삭제하지 않습니다.
4. 사용자가 링크 수정이나 stale 행 제거를 명시적으로 요청하면 그 승인된 편집만 수행하고 먼저 diff를 보여줍니다.
5. 이동 후 대상 파일 존재, 원본 경로 제거, 다른 파일 미변경을 확인합니다.

## 가드레일

- `done`이 아닌 작업은 아카이브하지 않습니다.
- 아카이브 중 작업·마일스톤 문서의 내용, frontmatter, 상태를 편집하지 않습니다.
- 명시적 승인 없이 index 행, 링크, 이력을 다시 쓰지 않습니다. 대신 영향을 보고합니다.
- 제품 코드, `planning/candidates/`, 생성 파일, 승인된 이동 외의 어떤 파일도 건드리지 않습니다.
- 사용자가 명시적으로 요청하지 않으면 stash, reset, rebase, 브랜치 삭제, 커밋/push를 하지 않습니다. 커밋이 요청되면 저장소 커밋 메시지 컨벤션을 따르고 AI 귀속 트레일러를 추가하지 않습니다.
