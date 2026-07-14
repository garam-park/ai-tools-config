# agents 메타데이터

`codex.yaml`은 Codex가 스킬의 표시 이름, 짧은 설명, 기본 프롬프트를 읽을 때 사용하는 메타데이터다. `$paced-explainer`는 Codex의 슬래시-달러 명령 문법이며, ChatGPT/Custom GPT 등 다른 OpenAI 계열 클라이언트는 이 문법을 지원하지 않는다. Codex 이외의 도구가 이 파일을 읽을 경우 `$paced-explainer` 호출은 무시되고 표시 이름·설명만 사용된다.
