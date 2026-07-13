# agents/

각 파일은 특정 도구/플랫폼에서 스킬을 호출할 때 쓰이는 메타데이터다.

- `codex.yaml` — Codex 전용. `default_prompt`가 슬래시-달러(`$paced-explainer`) 문법을 쓴다.
  이 문법은 Codex만 인식하므로 파일명을 `codex.yaml`로 둔다. (이전 이름: `openai.yaml`)

> ChatGPT/Custom GPT 등 OpenAI 인터페이스는 `$` 슬래시-달러 문법을 인식하지 않는다.
> 해당 플랫폼용 메타데이터가 필요하면 `$paced-explainer` 대신 그 플랫폼의 호출 방식으로
> 작성한 별도 파일(예: `openai.yaml`)을 추가한다.
