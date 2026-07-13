# 04. README에 global-instructions 기능 문서화

- **우선순위**: P2 (문서·기능 일관성)
- **대상 파일**: `README.md` (구성 트리 L7–L17, "새 머신에서 사용하기" L19–L34)
- **상태**: TODO

## 문제

README가 **리포의 절반을 언급하지 않는다.**

- 구성 트리(L7–L17)에 `install-global-instructions.sh`와 `global-instructions/`(common/claude/codex/opencode.md)가 없다.
- "새 머신에서 사용하기" 단계는 스킬만 설치하고 글로벌 지침 동기화 단계가 없다.
- "global-instructions"라는 단어가 README 전체에 한 번도 등장하지 않는다.

결과: README만 따라 하면 **새 머신에 글로벌 지침이 전혀 설치되지 않는다.**

## 수정 방향

1. 구성 트리에 추가:
   ```
   ├── install-global-instructions.sh
   ├── global-instructions/
   │   ├── common.md
   │   ├── claude.md
   │   ├── codex.md
   │   └── opencode.md
   ```
2. "새 머신에서 사용하기"에 단계 추가 (스크립트는 자기 위치에서 SRC_DIR을 잡으므로 클론 위치에서 바로 실행 가능):
   ```sh
   bash ~/ai-tools-config/install-global-instructions.sh
   ```
   설명: `common.md` + 도구별 델타를 결합해 각 도구의 글로벌 지침 경로
   (`~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, `~/.config/opencode/AGENTS.md`)로 동기화한다.

## 완료 조건

- [ ] 구성 트리가 실제 tracked 파일과 일치한다
- [ ] 온보딩 단계만 따라 하면 스킬 + 글로벌 지침이 모두 설치된다
