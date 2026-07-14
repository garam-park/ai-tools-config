# 16. README "4개 도구 경로" 표기 정정

## 상태
- [x] 시작 전
- [x] 적용
- [x] 검증
- [x] 완료

## 우선순위
⚪ **P3 — 문서**

## 보강 참조
- → [30-readme-tool-table-script-source.md](30-readme-tool-table-script-source.md) — 같은 커밋에 묶어 적용 권장

## 제안 모델
- ✅ claude ([13-readme-4-tools-3-paths.md](../claude/13-readme-4-tools-3-paths.md))
- ❌ codex
- ❌ m3

## 문제
[README.md:39](../../README.md#L39) (대략):

> `install-skills.sh`가 자동으로 **4개 도구 경로**(`~/.claude/skills`, `~/.codex/skills`, `~/.config/opencode/skills`)에 심볼릭 링크를 만들어 줌

"4개 도구 경로"라고 하면서 경로는 3개만 나열.
실제로 Claude Code와 GitHub Copilot이 `~/.claude/skills`를 공유하므로 **4개 도구 → 3개 경로**다.

(표 L46–L47과 `install-skills.sh`의 TARGETS 3개와 일치.)

## 권장 구현

도구 수와 경로 수를 구분해 표기:

```markdown
`install-skills.sh`가 자동으로 4개 도구(3개 경로: `~/.claude/skills`, `~/.codex/skills`, `~/.config/opencode/skills`)에 심볼릭 링크를 만들어 줌 (Claude Code와 Copilot은 `~/.claude/skills` 공유)
```

> 작업 **04, 05** 결과에 따라 Copilot 경로 표현이 달라질 수 있음

## 완료 조건
- [x] "도구 수"와 "경로 수"가 혼동 없이 표기됨
- [x] 나열한 경로 수가 실제 TARGETS 수와 일치

## 커밋 메시지 (예시)
```
docs(readme): distinguish 4 tools from 3 paths in install-skills description
```