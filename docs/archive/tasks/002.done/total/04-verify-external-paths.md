# 04. 외부 도구 경로/파일 검증

## 상태
- [x] 시작 전
- [x] 조사
- [x] 결과 반영 (05, 09)
- [x] 완료

## 우선순위
🟡 **P2 — 다른 P2 작업(05, 09)의 전제**

## 제안 모델
- ✅ m3 ([06-verify-external-paths.md](../m3/06-verify-external-paths.md))
- ❌ claude (단정하고 사용)
- ❌ codex (단정하고 사용 — claude와 다른 결론)

## 왜 이 작업이 중요한가
claude와 codex는 **같은 항목에 대해 서로 다른 결론**을 내렸다. m3가 지적한 대로 외부 문서를 실제로 확인하지 않으면 어느 쪽도 검증되지 않는다.

| 항목 | claude 단정 | codex 단정 | 실제 (확인 필요) |
|------|-------------|------------|------------------|
| Copilot 개인 스킬 경로 | `~/.claude/skills` (공유) | `~/.copilot/skills` (별도) | ? |
| OpenCode 글로벌 지침 파일 | `~/.config/opencode/AGENTS.md` | (동일) | ? |
| oh-my-openagent 설정 | `~/.config/opencode/oh-my-openagent.json` | (동일) | ? |

## 검증 대상

### 4-A. GitHub Copilot (VS Code) Personal 스킬 경로
- 확인 출처: VS Code Copilot Chat 공식 문서, 설치된 Copilot 확장의 skill 경로
- 확인 방법: 확장 설정에서 "Skill locations" 검색, 또는 `~/.vscode/extensions/github.copilot-chat-*/package.json`의 contributions

### 4-B. OpenCode 글로벌 지침 파일명
- 확인 출처: OpenCode 공식 문서의 글로벌 컨텍스트 파일 명세
- 확인 방법: OpenCode GitHub README, config schema 문서

### 4-C. oh-my-openagent 설정 파일
- 확인 출처: oh-my-openagent 플러그인 문서
- 확인 방법: 플러그인 README, 설정 schema

## 결과 기록

| 항목 | 확인 결과 (참/거짓) | 출처 | 수정 필요 |
|------|---------------------|------|----------|
| 4-A Copilot 스킬 경로 | `~/.copilot/skills`가 표준 Personal 경로. VS Code는 `~/.claude/skills`도 호환 경로로 지원 | GitHub Docs `About agent skills`, VS Code `Use Agent Skills` (2026-07-14 확인) | Copilot 전용 `~/.copilot/skills` 타깃 추가 |
| 4-B OpenCode AGENTS.md | 참: 글로벌 규칙은 `~/.config/opencode/AGENTS.md` | OpenCode 공식 `Rules` (2026-07-14 확인) | 없음 |
| 4-C oh-my-openagent.json | 참: macOS/Linux 사용자 설정 후보에 `~/.config/opencode/oh-my-openagent.json[c]` 포함 | oh-my-openagent `Configuration Reference` (2026-07-14 확인) | 없음 |

## 변경 파일
- 결과에 따라 [README.md](../../README.md), [SKILL.md](../../skills/paced-explainer/SKILL.md), [opencode.md](../../global-instructions/opencode.md) 업데이트
- 후속 작업 **05, 09**에 결과 반영

## 커밋 메시지 (예시, 변경이 있는 경우)
```
docs: correct external tool paths after verification
```
