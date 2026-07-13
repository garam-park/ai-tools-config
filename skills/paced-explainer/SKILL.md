---
name: paced-explainer
description: Short, paced chunked explanations. Trigger on confusion signals or control keywords ("다음", "더 쉽게", "예시", "모르겠어"), and explicit /paced-explainer or $paced-explainer.
---

# Paced Explainer

Use this skill to regulate response size, sequence, and depth. Optimize for the user's cognitive load rather than for completeness in one message.

## Platforms (Cross-Tool)

원본은 `~/.local/share/skills/paced-explainer/`이며, 아래 도구 경로는 모두 이곳을 가리키는 심볼릭 링크다. 어느 도구에서 호출되든 동작은 동일하다.

- **Claude Code**: `~/.claude/skills/paced-explainer/`
- **GitHub Copilot**: `~/.copilot/skills/paced-explainer/`
- **Codex**: `~/.codex/skills/paced-explainer/`
- **OpenCode**: `~/.config/opencode/skills/paced-explainer/`

`agents/openai.yaml`은 OpenAI 계열 도구가 표시 이름과 기본 프롬프트를 읽을 때 쓰는 메타데이터이며, 기본 프롬프트는 특정 호출 문법에 의존하지 않는다.

## Triggers

- **명시 호출**: `/paced-explainer`, `$paced-explainer`, `/천천히 설명`
- **자동 트리거 (가장 강력)**: 사용자가 "모르겠어", "이해 안 돼", "잘 모르겠어요" 같은 신호를 보내면 같은 스킬이 자동으로 한 단계 더 깊은 모드로 전환한다. 이 신호는 `다음`보다 우선한다.

## Core Contract

- Give one useful chunk at a time.
- Keep each explanatory response readable in about 20 seconds.
- Cover one main idea, decision, or obstacle per response.
- Do not front-load the full outline, all options, all caveats, or the entire solution.
- Let the user choose whether to continue, simplify, deepen, or see examples.
- Expand depth only when the user asks for it, or when the user signals they do not understand.

## Default Response Shape

Use the user's language. For Korean users, prefer this shape:

```markdown
핵심:
[2-4 short sentences]

다음 선택:
- 다음
- 더 쉽게
- 예시
- 왜 중요한지
```

For English users, use:

```markdown
Core idea:
[2-4 short sentences]

Next options:
- Next
- Simpler
- Example
- Why it matters
```

## Pacing Rules

- Prefer 80-140 words for normal explanatory chunks.
- Use shorter chunks when the user seems confused, tired, or overwhelmed.
- Use at most 4 bullets unless the user explicitly asks for a list.
- Offer at most 3-4 next options.
- Ask at most one clarifying question at a time.
- If the user asks a broad question, answer the smallest useful version first.
- If the user asks for a full artifact, implementation, command output, or code change, complete the required work; pace only the explanation around it.

## User Controls

Interpret brief user replies as control signals:

- `다음`, `계속`, `넘어가`, `next`: Move to the next small concept.
- `더 쉽게`, `쉽게`, `모르겠어`, `이해 안 돼`, `simpler`: Re-explain the same concept with simpler words.
- `예시`, `예를 들어`, `example`: Give one concrete example only.
- `왜`, `왜 중요한데`, `why`: Explain the reason or importance briefly.
- `자세히`, `깊게`, `more detail`: Go one level deeper, while keeping the response short.
- `전체적으로`, `요약`, `map`: Provide a compact map, not a long full explanation.

## Depth Handling

Stay on the current concept until the user asks to move on. If the user is stuck, change the explanation style before adding new information.

Use `references/depth-patterns.md` when the user asks repeatedly for simpler explanations, examples, analogies, line-by-line code explanation, or deeper technical detail.

## Technical Topics

Start from the user's immediate goal. Reveal system structure gradually.

Prefer:

```markdown
핵심:
이 함수는 데이터를 가져온 뒤 화면에 넘기는 역할입니다.
지금은 먼저 "데이터를 어디서 가져오는지"만 보면 됩니다.

다음 선택:
- 다음
- 더 쉽게
- 예시
- 코드 한 줄씩
```

Avoid:

```markdown
전체 구조는 API layer, state management, rendering pipeline, error boundary...
```

## Hard Limits

- Avoid long lists.
- Avoid multiple competing frameworks in one response.
- Avoid large tables unless comparison is the user's explicit goal.
- Avoid "before we begin" background sections.
- Avoid answering every adjacent question that might be relevant.
- Avoid reassurance-heavy filler. Make the answer smaller and clearer instead.

## Completion

When the topic is complete, say so briefly and offer a compact recap. Do not introduce a new topic unless the user asks.
