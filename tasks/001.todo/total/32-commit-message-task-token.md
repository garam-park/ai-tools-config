# 32. common.md — 커밋 메시지에 작업 카드 토큰 규약

## 상태
- [ ] 시작 전
- [ ] 적용
- [ ] 검증
- [ ] 완료

## 우선순위
🟦 **운영 개선 — 추적 가능성**

## 제안
**메타 분석** (세 모델 모두 다른 곳에 집중)

## 문제
[global-instructions/common.md](../../global-instructions/common.md) 의 "작업 방식" 섹션:

```markdown
- 작업 디렉토리가 git repository인 경우, 의미 단위(논리적으로 완결된 변경)가 완성되면 자동으로 커밋한다
  - 커밋 메시지는 "왜"를 중심으로 1-2문장으로 작성한다
  - 커밋 메시지에 `Co-Authored-By: Claude`, `Generated with Claude Code` 등 AI 관련 트레일러·서명·푸터를 절대 넣지 않는다. 사용자가 명시적으로 요청한 경우에만 예외.
  - 여러 무관한 변경이 섞이지 않도록 분리해서 커밋한다
  - push는 사용자가 명시적으로 요청할 때만 한다
```

→ **현재 작업 카드와 커밋을 연결하는 규약이 없음**.

작업 카드는 `tasks/001.todo/total/NN-*.md`로 명시적 ID를 갖고, 각 카드의 작업 md마다 "커밋 메시지 (예시)"가 적혀 있지만 **정식 규약으로 강제되지 않음**. 결과:

- `git log --grep="task 01"` 같은 추적이 어려움
- 완료 후 `git mv tasks/001.todo/total/01-*.md tasks/002.done/total/` 했을 때 그 커밋이 작업 카드 01을 완료한 것인지 다른 변경인지 매칭이 어려움
- 향후 자동화(이슈 닫기, 보드 업데이트) 불가

## 권장 구현

[global-instructions/common.md](../../global-instructions/common.md) 의 "작업 방식" 섹션 끝에 다음 한 블록 추가:

```markdown
- 작업 카드를 참조하는 경우 커밋 메시지에 다음 토큰을 포함한다 (정확한 형식):
  - 단일 작업: `(task NN)` — 예: `fix(install-skills): guard rm -rf (task 01)`
  - 묶음 작업: `(tasks NN,MM)` — 예: `refactor(install-skills): harden guards (tasks 01,22)`
  - 작업 디렉토리 `tasks/001.todo/total/` 의 카드 번호와 일치시킨다
```

## 완료 조건
- [ ] common.md에 작업 카드 토큰 규약 추가
- [ ] 동기화 후 4개 도구의 글로벌 지침에 반영됨 (검증: ~/.claude/CLAUDE.md 또는 ~/.codex/AGENTS.md)
- [ ] 기존 커밋과의 검색 호환 (`git log --grep="task "`) 고려

## 검증
```sh
bash ~/ai-tools-config/install-global-instructions.sh
grep -A1 '작업 카드를 참조' ~/.claude/CLAUDE.md ~/.codex/AGENTS.md ~/.config/opencode/AGENTS.md
# → 3개 파일 모두 동일 규약 포함 확인
```

## 의존
- ← 작업 **31**(상태 보드)와 함께 운영 개선 묶음

## 커밋 메시지 (예시)
```
docs(common): add task-token convention to commit message policy (task 32)
```