---
name: obsidian-docs
description: >
  Write project documentation into the user's Obsidian vault at
  ~/obsidians/1/Projects/{project-name}/, with project name derived from the
  current working directory's CLAUDE.md and filename following the vault's PARA
  prefix convention (ref_/note_/manage_/plan_). Trigger when (a) the user
  explicitly asks to save/document/log something to Obsidian (옵시디언/노트/볼트로 정리,
  obsidian에 남겨줘 등), or (b) a meaningful project artifact has just been
  produced — decision record, incident note, reference compilation, plan, or
  analysis — that the user would plausibly want preserved across sessions.
  Skip for ephemeral chat, trivial fixes, or content that belongs under
  Areas/Resources/Archives instead of Projects.
---

# obsidian-docs

이 스킬은 현재 작업 중인 프로젝트의 결과물(결정·분석·계획·레퍼런스)을 사용자 Obsidian 볼트의 `Projects/{project-name}/` 하위에 일관된 위치·네이밍으로 저장한다.

**범위**: `~/obsidians/1/Projects/{name}/` 만. `Inbox`, `Areas`, `Resources`, `Archives`, `.obsidian/`, daily-notes 흐름은 다루지 않는다.

## 발동 경로

1. **명시 호출** — 사용자가 `/obsidian-docs`, "옵시디언에 정리해줘", "노트로 남겨줘" 등으로 요청.
2. **자동 제안** — 의미 단위 작업이 끝났고, 보존 가치가 있는 산출물이 생긴 경우. 한 줄로 "이거 Obsidian에 정리할까요?" 정도만 묻고, 거절되면 같은 턴에서 재시도하지 않는다. 자잘한 버그 픽스, 일회성 명령, 단순 리뷰는 자동 제안하지 않는다.

## 절차

### 1. 프로젝트 이름 식별

- 현재 cwd의 `CLAUDE.md`를 읽는다 (프로젝트 루트 + 상위로 올라가며, 그리고 `~/.claude/CLAUDE.md`).
- 명시된 프로젝트명을 LLM이 식별. 예시 패턴:
  - `# 이 프로젝트는 '월동작물'` → `월동작물`
  - `이 저장소는 X 프로젝트` → `X`
  - 헤더든 본문이든 위치는 자유.
- **추측 금지**. 식별 실패하거나 후보가 둘 이상이면 `AskUserQuestion`으로 사용자에게 확인.
- 디렉토리명, git remote 이름은 **신뢰하지 않는다** — CLAUDE.md에 명시된 이름이 단일 출처.

### 2. 저장 위치 확보

- 경로: `~/obsidians/1/Projects/{project-name}/`
- 폴더가 없으면 `mkdir -p`로 자동 생성. 추가 README 같은 부속 파일은 만들지 않는다.
- 한글 폴더명 허용 (볼트 기존 관행 — 예: `월동작물`).

### 3. 파일명 결정

`{prefix}_{slug}.md` 형식. prefix는 내용 성격에 따라 선택:

| prefix | 의미 |
| ------ | ---- |
| `ref_` | 참고 자료, 외부 기술 레퍼런스, API/툴 사용법 정리 |
| `note_` | 개인 노트, 분석, PoC, 결정 기록, 회고 |
| `manage_` | 관리 문서 (앱·인원·리소스 목록 등) |
| `plan_` | 사전 준비/계획 문서 (실행 전 단계) |

원칙:

- prefix가 애매하면 `AskUserQuestion`으로 후보 2~3개를 보여주고 사용자가 고르게 한다.
- 사용자가 다른 prefix(예: `quiz_`)나 prefix 없는 파일명을 명시 요청하면 그대로 따른다.
- slug는 한글/영문 모두 허용. 띄어쓰기는 `-`로 대체. 날짜가 의미 있으면 `note_<topic>-2026-04-30.md`처럼 끝에 붙인다.
- 동일 파일명이 이미 있으면 사용자에게 "덮어쓸지 / 다른 이름으로 저장할지" 확인. **무단 덮어쓰기 금지**.

### 4. YAML frontmatter

볼트의 마크다운 메타 컨벤션을 따르되, 최소 다음을 포함:

```yaml
---
created: YYYY-MM-DD
tags: []
---
```

볼트에 `rule_markdown-meta.md` 같은 룰 파일이 있으면 그걸 우선 따른다 (`~/obsidians/1/`에서 검색).

### 5. 본문 작성

- 한국어 기본. 사용자가 영어로 작성한 내용은 그대로 보존.
- 코드 블록은 언어 태그 포함.
- 외부 참조 URL은 본문에 명시.
- 너무 길어질 것 같으면 한 파일에 욱여넣지 말고 사용자에게 분할 제안.

## 권위 있는 출처

이 스킬은 컨벤션을 복제하지 않는다. 항상 다음을 단일 출처로 참조하라:

- `~/obsidians/1/CLAUDE.md` — PARA 구조, 네이밍 컨벤션, 동기화 주의사항
- 볼트 안 `rule_logging.md`, `rule_markdown-meta.md`, `rule_para-convention.md` (존재할 때)

볼트 CLAUDE.md가 갱신되면 이 스킬도 그 변경을 따른다.

## 금지 사항

- `Inbox/`, `Areas/`, `Resources/`, `Archives/`에 직접 쓰지 않는다. 그 위치가 적절하다고 판단되면 사용자에게 알리고 종료하라 — 이 스킬은 `Projects/` 전용이다.
- 기존 파일은 명시 요청 없으면 수정·덮어쓰지 않는다.
- `.obsidian/` 디렉토리에 손대지 않는다 (Syncthing/git에서 의도적으로 제외됨).
- 볼트 쪽 git 작업(커밋·푸시)은 이 스킬에서 하지 않는다. 사용자 글로벌 룰을 따르되 cwd가 볼트 git repo일 때만 자동 커밋이 트리거된다.

## 확인이 필요한 케이스 (`AskUserQuestion` 사용)

- CLAUDE.md에 프로젝트명이 명시되어 있지 않거나 후보가 여러 개
- prefix 선택이 애매 (예: 분석이자 동시에 계획성)
- 파일명 충돌
- 사용자가 자동 제안을 받았을 때, 정말 저장할지 한 줄 확인

## 검증 (스킬 작성자가 실행할 셀프 체크)

스킬 동작이 의심스러우면 다음을 점검:

1. cwd = 프로젝트 루트에서 스킬 발동 → CLAUDE.md에서 이름이 올바르게 추출되는가
2. 새 프로젝트명으로 호출 시 폴더가 자동 생성되는가
3. `Areas/`나 `Inbox/`에 쓰려는 시도가 있을 때 거부하는가
4. 기존 파일 충돌 시 사용자에게 묻는가
