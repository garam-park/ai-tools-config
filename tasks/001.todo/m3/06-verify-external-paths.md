# 06. 외부 도구 경로/파일 검증

## 상태
- [ ] 시작 전
- [ ] 검증
- [ ] 결과 반영
- [ ] 완료

## 우선순위
환경 의존

## 검증 대상
README, SKILL.md, codex.md, opencode.md에서 단정하고 있는 다음 경로/파일이 실제로 존재하고 의도대로 동작하는지 확인.

### 6-A. GitHub Copilot (VS Code) Personal 스킬 경로
- 단정: `~/.claude/skills/`를 Copilot도 인식
- 확인 방법: VS Code Copilot Chat 공식 문서 / 설치된 확장의 스킬 경로

### 6-B. OpenCode 글로벌 지침 파일명
- 단정: `~/.config/opencode/AGENTS.md`를 글로벌 지침으로 인식
- 확인 방법: OpenCode 문서의 글로벌 컨텍스트 파일 명세

### 6-C. oh-my-openagent 설정 파일
- 단정: `~/.config/opencode/oh-my-openagent.json`에서 모델 변경
- 확인 방법: oh-my-openagent 플러그인 문서

## 변경 파일
- `README.md` (필요 시)
- `global-instructions/opencode.md` (필요 시)
- `skills/paced-explainer/SKILL.md` (필요 시)

## 작업 방식
각 항목을 다음 표에 결과를 적는다.

| 항목 | 확인 결과 (참/거짓) | 출처 | 수정 필요 |
|------|---------------------|------|----------|
| 6-A Copilot 스킬 경로 |  |  |  |
| 6-B OpenCode AGENTS.md |  |  |  |
| 6-C oh-my-openagent.json |  |  |  |

"거짓"으로 판명되면 해당 문구를 정정하고 README·SKILL.md를 업데이트.

## 커밋 메시지 (예시, 변경이 있는 경우)
```
docs: correct external tool paths after verification
```