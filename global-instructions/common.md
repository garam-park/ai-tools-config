# 공통 지침 (모든 도구)

> 이 파일은 Claude Code, GitHub Copilot (VS Code), Codex, OpenCode 네 도구 모두에 공통으로 적용되는 글로벌 지침이다.
> 도구별 파일(`claude.md` / `codex.md` / `opencode.md`)이 있으면 common 뒤에 결합되어 각 도구의 글로벌 지침 경로로 동기화된다.
> 동기화 스크립트: `~/ai-tools-config/install-global-instructions.sh`

## 커뮤니케이션

- 한국어로 대화한다
- 코드 변경 전에 계획을 먼저 설명한다
- 확실하지 않으면 추정하지 말고 질문한다

## 코딩 원칙

- 함수는 하나의 일만 한다 (단일 책임 원칙)
- 변수명은 의도가 드러나게 짓는다
- 주석은 "무엇이" 아니라 "왜"를 설명한다

## 작업 방식

- 작업 디렉토리가 git repository인 경우, 의미 단위(논리적으로 완결된 변경)가 완성되면 자동으로 커밋한다
  - 커밋 메시지는 "왜"를 중심으로 1-2문장으로 작성한다
  - 커밋 메시지에 `Co-Authored-By: Claude`, `Generated with Claude Code` 등 AI 관련 트레일러·서명·푸터를 절대 넣지 않는다. 사용자가 명시적으로 요청한 경우에만 예외.
  - 여러 무관한 변경이 섞이지 않도록 분리해서 커밋한다
  - push는 사용자가 명시적으로 요청할 때만 한다
  - 작업 카드(`tasks/001.todo/total/NN-*.md`)를 참조하는 경우 커밋 메시지에 다음 토큰을 포함한다
    - 단일 작업: `(task NN)` — 예: `fix(install-skills): guard rm -rf (task 01)`
    - 묶음 작업: `(tasks NN,MM)` — 예: `refactor(install-skills): harden guards (tasks 01,22)`
    - 번호는 작업 디렉토리의 카드 번호와 일치시킨다
- 큰 변경은 작은 단계로 나눠서 진행한다
