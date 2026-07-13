# Depth Patterns

Use this reference only when the user asks to simplify, go deeper, see examples, or recover from confusion.

## Simpler

Keep the same concept. Replace technical terms with everyday language.

Shape:

```markdown
더 쉽게:
[1-3 short sentences]

한 줄로:
[single sentence]

다음 선택:

- 다시 예시로
- 다음
- 조금 더 자세히
```

## Example

Give exactly one example first. Prefer a concrete, familiar situation.

Shape:

```markdown
예시:
[one concrete example]

이 예시에서 중요한 점:
[1-2 sentences]
```

## Why It Matters

Explain the practical consequence, not the full theory.

Shape:

```markdown
왜 중요한지:
[1-3 sentences about what breaks, improves, or becomes easier]
```

## One Level Deeper

Add one layer of mechanism. Do not jump to all implementation details.

Shape:

```markdown
조금 더 깊게:
[2-4 sentences]

여기까지만 보면 되는 이유:
[1 sentence]
```

## Line-By-Line Code

Use very small groups. Explain 1-3 lines at a time.

Shape:

````markdown
이번 조각:

```language
[1-3 lines]
```

무슨 뜻인지:
[2-4 sentences]

다음 선택:

- 다음 줄
- 더 쉽게
- 예시
````

## Compare Two Things

Compare only the contrast the user needs right now.

Shape:

```markdown
핵심 차이:
[2-3 sentences]

짧게 말하면:

- A: [short phrase]
- B: [short phrase]
```

## User Still Does Not Understand

### First "모르겠어" (자동 트리거)

`모르겠어`, `이해 안 돼`, `잘 모르겠어요`, `don't know` 가 처음 들어오면 즉시 Simpler 패턴으로 전환한다. 질문 없이 바로 풀어 설명한다.

Shape:

```markdown
더 쉽게 풀어볼게요.

같은 뜻, 다른 표현:
[답변에 등장한 핵심 문장 1개를 더 쉬운 단어로 다시 쓴 버전]

예시 하나:
[방금 답변에 나온 개념과 직접 연결되는 구체적 상황 1개]

다음 선택:

- 다음으로 넘어가기
- 한 단어만 짚어서 더 풀기
- 예시 하나 더
```

### Second "모르겠어" (한 단어만 짚기)

같은 청크에서 두 번째 "모르겠어"가 들어오면:

- 새 용어를 추가하지 않는다.
- 답변에서 이미 등장한 **단어 하나**만 골라 그 단어만 풀어 설명한다.
- 그 단어가 이해되면 청크 흐름으로 돌아온다.

Shape:

```markdown
좋아요, 한 단어만 짚을게요.

지금 막히는 단어: [답변에 등장한 단어 1개]
뜻: [같은 의미를 다른 표현으로 1-2문장]

이 단어가 이해되면 나머지 흐름으로 돌아갈게요.

다음 선택:

- 이 단어 더 풀기
- 다른 단어 짚기
- 다음으로 넘어가기
```

### Third "모르겠어" (범위 축소 + 질문)

같은 청크에서 세 번째 "모르겠어"가 들어오면 **설명을 멈추고** 어디가 막히는지 한 가지만 묻는다.

Shape:

```markdown
좋아요, 범위를 더 줄일게요.

지금은 이것만 보면 됩니다:
[one sentence]

어느 부분이 막히나요?

- [term A]
- [term B]
- 전체 흐름
```
