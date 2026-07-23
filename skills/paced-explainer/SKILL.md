---
name: paced-explainer
description: Pace explanations in short, low-overload chunks. Trigger on confusion signals or control keywords ("다음", "더 쉽게", "예시", "모르겠어", "왜"), and explicit /paced-explainer, $paced-explainer, or 천천히 설명.
---

# Paced Explainer

Use this skill to regulate response size, sequence, and depth. Optimize for the user's cognitive load rather than for completeness in one message.

## Platforms (Cross-Tool)

원본은 이 리포의 `skills/paced-explainer/`이며, `install-skills.sh`가 아래 도구 경로에 리포 작업 트리를 직접 가리키는 심볼릭 링크를 만든다. 어느 도구에서 호출되든 동작은 동일하다.

- **Claude Code**: `~/.claude/skills/paced-explainer/`
- **Codex / GitHub Copilot / OpenCode**: `~/.agents/skills/paced-explainer/`

`agents/codex.yaml`은 Codex가 사용하는 선택적 UI 메타데이터다. `$paced-explainer`는 Codex 전용 슬래시-달러 문법이라 ChatGPT 등 다른 OpenAI 계열 클라이언트에서는 동작하지 않는다. 다른 도구는 공통 동작을 정의한 `SKILL.md`만 사용한다.

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
- Make progress visible by naming the current main topic, subtopic, chunk position, and estimated remaining time.

## Progress Header

Start every paced explanatory response with a progress header and time estimate:

```markdown
[ {main topic} / {subtopic} ({n}/{m}) ]
종료까지 약 {remaining time} 예상 - {estimated end time} 종료 예정

{content}
```

- `{main topic}` is the broader question or task being explained.
- `{subtopic}` is the current small concept, decision, or obstacle.
- `{m}` is the assistant's planned number of chunks for the current explanation path.
- `{n}` is the current chunk number in that planned path.
- Estimate `{m}` on the first response, then revise it only when the user's direction materially changes the scope.
- Recalculate `{remaining time}` and `{estimated end time}` on each response. This is a rough conversational estimate, not a guarantee.
- When no user pace has been observed yet, estimate from the number of remaining chunks and the current response size. After the user replies, adjust based on whether they are moving quickly, asking follow-up questions, or needing simpler explanations.

For branch answers, keep the same `{n}/{m}` position and append a branch marker:

```markdown
[ {main topic} / {subtopic} ({n}/{m}) - {branch number} {branch topic} ]
종료까지 약 {remaining time} 예상 - {estimated end time} 종료 예정

{content}
```

- A branch is a side question, clarification, example, simpler explanation, or "why" answer that interrupts the planned path.
- Number branches within the current `{n}/{m}` position as `1`, `2`, `3`, and so on.
- After answering a branch, return to the original path unless the user changes the main direction.
- Branch answers do not advance `{n}` unless they also complete the current planned chunk.

## Default Response Shape

Use the user's language. For Korean users, prefer this shape:

```markdown
[ {메인주제} / {서브주제} ({n}/{m}) ]
종료까지 약 {남은 시간} 예상 - {종료 예정 시각} 종료 예정

[2-4 short sentences]

다음 선택:
- 다음
- 더 쉽게
- 예시
- 왜 중요한지
```

For English users, use:

```markdown
[ {main topic} / {subtopic} ({n}/{m}) ]
About {remaining time} left - expected to finish at {estimated end time}

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
[ 데이터 흐름 이해하기 / 데이터 출처 확인 (1/3) ]
종료까지 약 3:00 예상 - 18:14 종료 예정

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
