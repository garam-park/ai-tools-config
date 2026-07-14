# 27. SKILL.md — description 필드 축약 (트리거 신호만)

## 상태
- [x] 시작 전
- [x] 적용
- [x] 검증
- [x] 완료

## 우선순위
⚪ **P3 — 토큰 효율**

## 제안
**메타 분석** (세 모델 모두 미발굴)

## 문제
[skills/paced-explainer/SKILL.md:1-3](../../skills/paced-explainer/SKILL.md#L1-L3) 의 YAML frontmatter `description`:

```yaml
description: Control explanation pacing by splitting answers into short, low-overload chunks a user can read in about 20 seconds. Use when the user asks to learn, understand, review, debug, compare, make a decision, or get help without being overwhelmed; especially when they ask for short chunks, step-by-step guidance, optional depth, simpler explanation, examples, or controls such as "next", "more", "simpler", "example", "why", "다음", "더 쉽게", "예시", or "모르겠어".
```

이 description은:
- **150단어 이상** → 모델이 매 호출마다 컨텍스트로 로드
- 본문의 "Triggers" / "User Controls" 섹션과 **대부분 중복**
- 핵심 신호("청크 모드로 설명 요청 신호")가 묻혀 있음

`description`은 모델이 **언제 이 스킬을 선택해야 하는지** 판단하는 데에만 쓰이므로, 가능한 한 짧고 신호성이 강해야 한다.

## 권장 구현

```yaml
description: Pace explanations in short chunks. Trigger on requests like "다음/더 쉽게/예시/모르겠어/왜", or signals of confusion, plus /paced-explainer / $paced-explainer / 천천히 설명.
```

또는 더 짧게:

```yaml
description: Short, paced chunked explanations. Trigger on confusion signals or control keywords ("다음", "더 쉽게", "예시", "모르겠어"), and explicit /paced-explainer or $paced-explainer.
```

핵심 유지 요소:
- 무엇을 하는가: "short chunked explanations"
- 트리거 신호: confusion / control keywords / 명시 호출

제거 가능 요소:
- "20초" 같은 메타 규칙 (본문에 있음)
- "review, debug, compare, make a decision" 같은 광범위 용도 (스킬이 자동으로 적절히 처리)

## 완료 조건
- [x] description이 50단어 이내로 축약
- [x] 핵심 트리거 신호가 모두 보존됨
- [x] 본문의 Triggers / User Controls 섹션은 변경하지 않음 (상세 규칙은 본문 유지)

## 검증
```sh
# YAML 파싱 + 단어 수 확인
python3 -c "import yaml,sys;d=yaml.safe_load(open('skills/paced-explainer/SKILL.md').read().split('---')[1]);print('description words:', len(d['description'].split()))"
# → 50 이하 권장
```

## 커밋 메시지 (예시)
```
docs(skill): trim description to trigger signal only
```