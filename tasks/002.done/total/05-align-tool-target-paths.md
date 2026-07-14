# 05. 도구별 타깃 스킬 경로 정렬

## 상태
- [x] 시작 전
- [x] 방안 결정 (작업 04 결과에 의존)
- [x] 적용
- [x] 검증
- [x] 완료

## 우선순위
🟡 **P2 — 문서 정합성**

## 의존
- ← [04-verify-external-paths.md](04-verify-external-paths.md) 결과를 받아 진행

## 제안 모델
- ✅ claude (현재 코드와 README 일치: `~/.claude/skills` 공유)
- ✅ codex (별도 경로 `~/.copilot/skills` 추가 제안)
- ❌ m3

## 문제
[install-skills.sh](../../install-skills.sh) TARGETS는 3개 경로:
```
~/.claude/skills
~/.codex/skills
~/.config/opencode/skills
```

claude와 codex는 **Copilot의 Personal 스킬 경로**에 대해 서로 다른 결론을 내렸다.
- **claude**: Claude Code와 Copilot이 `~/.claude/skills`를 공유 (현행 유지)
- **codex**: Copilot은 `~/.copilot/skills` 별도 경로 사용 (`~/.claude/skills` 공유 설명 제거)

작업 **04**로 실제 Copilot 동작을 확인한 뒤 어느 쪽을 채택할지 결정한다.

## 권장 절차

1. 작업 **04** 결과로 다음 표 채우기:
   | 4-A 결과 | 채택안 |
   |----------|--------|
   | Copilot이 `~/.claude/skills` 사용 (참) | 현행 유지. 문구만 정정 |
   | Copilot이 `~/.copilot/skills` 사용 (참) | codex안 채택. TARGETS에 한 줄 추가 |
2. 결정된 안을 다음 파일에 일관되게 반영:
   - `install-skills.sh` (TARGETS 배열 + 완료 메시지)
   - `README.md` (동기화 표)
   - `skills/paced-explainer/SKILL.md` (Platforms 섹션)

## 완료 조건
- [x] 코드, 주석, 출력 메시지, README, SKILL.md의 경로가 모두 일치
- [x] Copilot 경로가 실제 동작과 일치

## 커밋 메시지 (예시)
```
docs: align Copilot skill path documentation with verified behavior
```