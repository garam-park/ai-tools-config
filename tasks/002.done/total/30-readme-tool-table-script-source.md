# 30. README 도구 표에 "스크립트 소스" 컬럼 추가

## 상태
- [x] 시작 전
- [x] 적용
- [x] 검증
- [x] 완료

## 우선순위
⚪ **P3 — 작업 16 확장 (가독성)**

## 제안
**메타 분석** (작업 16을 보강)

## 의존
- ← 작업 **16**(4-3 표기)과 같은 커밋에 묶어 적용 권장

## 문제
[README.md:48-53](../../README.md#L48-L53) 의 "동기화되는 도구" 표:

```
| 도구 | 경로 |
|------|------|
| Claude Code | `~/.claude/skills/` |
| GitHub Copilot (VS Code) | `~/.claude/skills/` (Claude와 동일 위치 사용) |
| Codex | `~/.codex/skills/` |
| OpenCode | `~/.config/opencode/skills/` |
```

→ 설치자는 어떤 도구가 어떤 스크립트 분기에 영향을 주는지 즉시 알 수 없다. 특히 작업 **05**(도구별 타깃 경로 정렬) 변경 시 **어떤 행이 바뀌는지** 명시되지 않으면 동기화 시 혼동.

## 권장 구현

"스크립트 소스" 컬럼 추가 (TARGETS 배열의 인덱스):

```
| 도구 | 경로 | 스크립트 소스 | 비고 |
|------|------|-------------|------|
| Claude Code | `~/.claude/skills/` | `install-skills.sh` TARGETS[0] | |
| GitHub Copilot (VS Code) | `~/.claude/skills/` | TARGETS[0]과 동일 | Claude와 공유 |
| Codex | `~/.codex/skills/` | `install-skills.sh` TARGETS[1] | |
| OpenCode | `~/.config/opencode/skills/` | `install-skills.sh` TARGETS[2] | |
```

또는 더 친숙하게:

```
| 도구 | 경로 | 동기화 코드 | 비고 |
|------|------|-----------|------|
| Claude Code | `~/.claude/skills/` | `TARGETS[0]` | |
| GitHub Copilot (VS Code) | `~/.claude/skills/` | `TARGETS[0]` 공유 | Claude와 동일 위치 |
| Codex | `~/.codex/skills/` | `TARGETS[1]` | |
| OpenCode | `~/.config/opencode/skills/` | `TARGETS[2]` | |
```

이렇게 하면:
- 작업 **05**에서 타깃이 추가/이동될 때 README 표도 함께 갱신해야 함이 명확
- 작업 **04**(외부 경로 검증) 결과로 Copilot 행이 분리될 때 어느 슬롯을 쓰는지 즉시 인지

## 완료 조건
- [x] 표에 "스크립트 소스" 컬럼이 추가됨
- [x] 각 행이 `install-skills.sh`의 TARGETS 어느 인덱스와 연결되는지 명시
- [x] Copilot 행의 "공유" 사실이 별도 컬럼이 아닌 비고로 처리됨

## 커밋 메시지 (예시, 작업 16과 통합 시)
```
docs(readme): add script-source column to tool table
```