# 05. SKILL.md Platforms 섹션 정정 (원본/심링크 모델 + OpenCode)

- **우선순위**: P2 (문서·기능 일관성)
- **대상 파일**: `skills/paced-explainer/SKILL.md` (L10–L18, "Platforms (Cross-Tool)")
- **상태**: TODO

## 문제

두 가지가 실제 동작과 어긋난다.

1. **원본/심링크 방향이 틀림.** L16은 Codex 경로를 `(원본)`으로, L18은
   "`~/.codex/skills/paced-explainer/`가 원본이고 `~/.claude/…`는 그 심볼릭 링크다"라고 설명한다.
   그러나 `install-skills.sh`는 자기 위치(`~/.local/share/skills/`)를 원본으로 두고
   **세 도구 경로 모두**(claude, codex, opencode)를 그곳을 가리키는 심링크로 만든다.
   → Codex도 심링크이며, claude는 codex의 심링크가 아니다.

2. **OpenCode 누락.** L12는 "다음 도구에서 모두 동작한다"면서 목록(L14–L16)에
   Claude Code / Copilot / Codex만 있고 OpenCode가 없다.
   `install-skills.sh`는 `~/.config/opencode/skills`에도 심링크를 만든다.

## 수정 방향

- 원본을 `~/.local/share/skills/<name>/`로 명시하고, 세 도구 경로 모두 그것의 심링크임을 서술한다.
- Codex 줄의 `(원본)` 라벨을 제거한다.
- Platforms 목록에 OpenCode(`~/.config/opencode/skills/paced-explainer/`) 항목을 추가한다.

예시:
```markdown
원본은 `~/.local/share/skills/paced-explainer/`이며, 아래 도구 경로는 모두 이곳을 가리키는 심볼릭 링크다.

- **Claude Code / GitHub Copilot**: `~/.claude/skills/paced-explainer/`
- **Codex**: `~/.codex/skills/paced-explainer/`
- **OpenCode**: `~/.config/opencode/skills/paced-explainer/`
```

## 완료 조건

- [ ] 원본이 `~/.local/share/skills/`로 서술되고, 모든 도구 경로가 심링크로 설명된다
- [ ] OpenCode가 Platforms 목록에 포함된다
- [ ] `install-skills.sh`의 TARGETS 및 완료 메시지와 서술이 일치한다
