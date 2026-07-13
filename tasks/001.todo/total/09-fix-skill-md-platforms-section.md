# 09. SKILL.md Platforms 섹션 정정 (원본/심링크 모델 + OpenCode)

## 상태
- [ ] 시작 전
- [ ] 방안 결정 (작업 04 결과에 의존)
- [ ] 적용
- [ ] 검증
- [ ] 완료

## 우선순위
🟡 **P2 — 문서 정합성**

## 의존
- ← [04-verify-external-paths.md](04-verify-external-paths.md) 결과를 받아 진행 (특히 4-A Copilot)

## 제안 모델
- ✅ claude ([05-skill-md-fix-origin-and-add-opencode.md](../claude/05-skill-md-fix-origin-and-add-opencode.md))
- ✅ codex ([03-correct-tool-target-paths.md](../codex/03-correct-tool-target-paths.md)) — 다른 의견
- ❌ m3

## 문제
[skills/paced-explainer/SKILL.md:10-18](../../skills/paced-explainer/SKILL.md#L10-L18) "Platforms (Cross-Tool)" 섹션에 두 가지 불일치.

### 1. 원본/심링크 방향 오류
L16은 Codex 경로를 `(원본)`으로, L18은 "`~/.codex/skills/paced-explainer/`가 원본이고 `~/.claude/…`는 그 심볼릭 링크"라고 설명.

그러나 [install-skills.sh](../../install-skills.sh) 는 자기 위치(`~/.local/share/skills/`)를 원본으로 두고 **세 도구 경로 모두**(claude, codex, opencode)를 그곳의 심링크로 만든다. → Codex도 심링크이며, claude는 codex의 심링크가 **아님**.

### 2. OpenCode 누락
L12는 "다음 도구에서 모두 동작한다"면서 목록에 Claude Code / Copilot / Codex만 있고 OpenCode가 없다.
`install-skills.sh`는 `~/.config/opencode/skills`에도 심링크를 만든다.

## 권장 구현

```markdown
원본은 `~/.local/share/skills/paced-explainer/`이며, 아래 도구 경로는 모두 이곳을 가리키는 심볼릭 링크다.

- **Claude Code / GitHub Copilot**: `~/.claude/skills/paced-explainer/`
- **Codex**: `~/.codex/skills/paced-explainer/`
- **OpenCode**: `~/.config/opencode/skills/paced-explainer/`
```

> Copilot 경로는 작업 **04, 05** 결과에 따라 조정. (Copilot이 별도 경로면 그 줄 분리)

## 완료 조건
- [ ] 원본이 `~/.local/share/skills/`로 서술되고 모든 도구 경로가 심링크로 설명됨
- [ ] OpenCode가 Platforms 목록에 포함됨
- [ ] `install-skills.sh`의 TARGETS 및 완료 메시지와 서술이 일치

## 커밋 메시지 (예시)
```
docs(skill): correct origin/symlink model and add OpenCode
```