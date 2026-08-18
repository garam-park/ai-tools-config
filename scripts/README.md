# scripts/

**이 리포에서 작업할 때만** 쓰는 프로젝트 로컬 MCP 런처를 담는다. 글로벌로 배포되지 않는다.

- `mcp/<server>/start.sh` — `mcp-script-builder` 스킬이 강제하는 경로 규약. 프로바이더 설정
  (`.mcp.json`, `.codex/config.toml`, `.vscode/mcp.json`, `opencode.json`)과 `.omm`이 이 경로를
  참조하므로 이 리포에서 임의로 옮기지 않는다.
- 글로벌 배포 하네스는 여기가 아니라 리포 루트의 `install-skills.sh`,
  `install-global-instructions.sh`, `bootstrap.sh`다.

계층 구분 기준은 [docs/repo-layout.md](../docs/repo-layout.md) 참조.
