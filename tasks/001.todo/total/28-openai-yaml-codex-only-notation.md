# 28. agents/openai.yaml — Codex 전용 표기 명시

## 상태
- [ ] 시작 전
- [ ] 적용
- [ ] 검증
- [ ] 완료

## 우선순위
⚪ **P3 — 메타데이터 정확성**

## 제안
**메타 분석** (세 모델 모두 미발굴)

## 문제
[skills/paced-explainer/agents/openai.yaml:4](../../skills/paced-explainer/agents/openai.yaml#L4):

```yaml
default_prompt: "$paced-explainer를 사용해서 내가 따라갈 수 있게 작은 단계로 설명해줘."
```

`$paced-explainer`는 **Codex 전용 슬래시-달러 명령**(글로벌 지침 [codex.md](../../global-instructions/codex.md) 에서도 "$analyze-task TSK-XXXX" 형식으로 명시). 

ChatGPT Custom GPT 인터페이스는 `$` 슬래시-달러 문법을 인식하지 않는다. 파일명이 `openai.yaml`이므로 OpenAI 생태계 전반에서 사용될 수 있는 명명인데, 본문은 Codex 전용 문법을 사용한다.

**이름(`openai.yaml`)과 본문(`$paced-explainer` Codex 전용) 사이의 모순** — 사용자가 ChatGPT에 가져다 쓰면 동작하지 않거나 의도와 다른 결과.

## 권장 구현

### 방안 A: 파일명 변경 (가장 명확)

`agents/openai.yaml` → `agents/codex.yaml`로 변경. Codex만 지원함을 명시.
`install-skills.sh`의 TARGETS는 변경 불필요 (폴더 전체를 심링크하므로 파일명 변경은 자동 반영).

### 방안 B: 본문 정정

`$paced-explainer` → Codex 호환 표현으로 변경:
```yaml
default_prompt: "/paced-explainer를 사용해서 내가 따라갈 수 있게 작은 단계로 설명해줘."
```
→ 그러나 Codex는 `$`만 인식할 가능성. **방안 A가 더 안전**.

### 권장

**방안 A**. 파일명을 `codex.yaml`로 변경하고, agents/README가 있다면 그곳에 사용처 명시.

`agents/` 디렉토리에 README가 없다면 추가 작성:
```markdown
# agents/

각 파일은 특정 도구/플랫폼에서 스킬을 호출할 때 사용되는 메타데이터.

- `openai.yaml` — OpenAI 호환 (ChatGPT Custom GPT 등) — Codex 전용 `$` 표기는 미지원
- `codex.yaml` — Codex 전용 슬래시-달러 명령
```

## 완료 조건
- [ ] 파일명이 실제 사용처와 일치
- [ ] README 또는 SKILL.md에 어떤 플랫폼에서 어떤 파일이 쓰이는지 명시
- [ ] (선택) `openai.yaml`에 ChatGPT 호환 default_prompt 별도 추가

## 검증
```sh
ls skills/paced-explainer/agents/
# 변경 후: codex.yaml (및 openai.yaml이 남으면 ChatGPT 호환임을 확인)
grep -l 'paced-explainer' skills/paced-explainer/agents/*.yaml
```

## 커밋 메시지 (예시)
```
refactor(skill): rename agents/openai.yaml to codex.yaml for clarity
```