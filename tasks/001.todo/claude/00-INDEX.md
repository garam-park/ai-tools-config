# ai-tools-config 수정 작업 목록

리포지토리(11개 파일)를 4개 렌즈(셸 정확성 · 문서 일관성 · 크로스툴 설정 · 이식성)로 분석한 뒤,
수정이 필요한 항목을 작업 단위로 분해한 목록이다. 우선순위 순서대로 처리한다.

## P1 — 데이터 손실 / 파괴적 연산 (우선)

- [ ] [01](01-backup-before-overwrite-global-instructions.md) — `install-global-instructions.sh`: 기존 글로벌 지침 파일을 백업 없이 덮어씀
- [ ] [02](02-guard-rm-rf-to-symlink-only.md) — `install-skills.sh`: `rm -rf`에 심링크 가드가 없어 실제 디렉토리를 삭제할 수 있음
- [ ] [03](03-rsync-delete-footgun.md) — `README.md`: 온보딩 `rsync --delete`가 로컬 전용 스킬을 지움

## P2 — 문서·기능 일관성

- [ ] [04](04-readme-document-global-instructions.md) — `README.md`: global-instructions 기능 전체가 문서화되지 않음
- [ ] [05](05-skill-md-fix-origin-and-add-opencode.md) — `SKILL.md`: 원본/심링크 모델 설명이 틀렸고 OpenCode 누락
- [ ] [06](06-claude-md-remove-nonexistent-skill-triggers.md) — `claude.md`: 존재하지 않는 스킬(graphify, ask-step-by-step) 트리거
- [ ] [07](07-codex-md-fix-contradictory-line.md) — `codex.md`: line 10 문구가 자기모순 + 오타

## P3 — 사소한 정리 (셸 견고성 · 오타 · 문서)

- [ ] [08](08-fix-src-dir-comment.md) — `install-skills.sh`: SRC_DIR 주석이 "부모"라고 잘못 설명
- [ ] [09](09-remove-dead-guard-filter-by-skill-md.md) — `install-skills.sh`: 죽은 가드 제거 + SKILL.md 존재로 필터
- [ ] [10](10-add-nullglob.md) — `install-skills.sh`: `nullglob` 미설정으로 빈 폴더 시 `*` 심링크 생성
- [ ] [11](11-atomic-mktemp-write.md) — `install-global-instructions.sh`: mktemp+mv 비원자적 쓰기
- [ ] [12](12-strip-trailing-slash-symlink.md) — `install-skills.sh`: 심링크 타깃에 후행 슬래시
- [ ] [13](13-readme-4-tools-3-paths.md) — `README.md`: "4개 도구 경로"라며 3개만 나열
- [ ] [14](14-remove-stale-parenthetical-codex.md) — `codex.md`: line 4 낡은 잔재 주석
- [ ] [15](15-readme-platform-prerequisite.md) — `README.md`: Unix/WSL 전제 환경 미명시

## 참고 — 기각한 후보

- "리포 루트에서 `install-skills.sh`를 직접 실행하면 `global-instructions/`를 스킬로 잘못 심링크한다" → 문서상 지원하지 않는 사용법이라 독립 결함으로 보지 않음. 다만 작업 09의 가드 개선으로 함께 방어된다.
