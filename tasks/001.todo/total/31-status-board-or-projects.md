# 31. 작업 상태 보드 (tasks/STATUS.md) 도입

## 상태
- [ ] 시작 전
- [ ] 방안 결정
- [ ] 적용
- [ ] 검증
- [ ] 완료

## 우선순위
🟦 **운영 개선 — 가시성**

## 제안
**메타 분석** (세 모델 모두 다른 곳에 집중)

## 문제
현재 `tasks/` 구조:
```
tasks/
├── 001.todo/    # 작업 카드 (50+)
└── 002.done/    # 완료된 카드
```

**현재 어느 작업이 진행 중(in-progress)인지 한눈에 보이는 단일 보드가 없음**.

- 작업 카드는 각각 독립 md → 개별 진행 상태는 각 md의 체크박스로 관리됨
- `tasks/001.todo/`에는 50+ 카드가 섞여 있어 **이번 사이클에 무엇을 할지 우선순위가 보이지 않음**
- 다른 사람이 리포를 봐도 "지금 뭐 하고 있지?" 파악 불가

## 방안 비교

### 방안 A: `tasks/STATUS.md` 단일 보드 (간단)
- 수동으로 표 작성, 작업 시작/완료 시 갱신
- 리포만으로 가시성 확보
- 단점: 갱신 잊으면 stale 상태

### 방안 B: GitHub Issues + Projects
- 작업 카드마다 Issue 생성
- Projects 보드로 상태/우선순위 시각화
- 자동 알림, 라벨링 가능
- 단점: GitHub 의존, 외부协作자에게만 유효

### 방안 C: 두 가지 병행
- 단기: `tasks/STATUS.md`로 즉시 가시성 확보
- 중기: GitHub Projects로 자동화

## 권장

**방안 A** (가장 가볍고 즉시 효과).

### 구현 형태

`tasks/STATUS.md`:

```markdown
# 작업 상태 보드

> 마지막 갱신: YYYY-MM-DD
> 이 파일은 작업 시작/완료 시 함께 갱신한다.

## In Progress

| # | 작업 | 시작일 | 예상 완료 |
|---|------|--------|----------|
| 01 | install-skills rm-rf 가드 | 2026-07-13 | 2026-07-13 |

## Next (이번 사이클)

- [작업 02] global-instructions 백업
- [작업 03] rsync --delete 제거

## Backlog

P1, P2, P3, 운영, 장기 순서대로 [total/README.md](README.md) 참조.
```

각 작업 md에는 `상태` 체크박스 외에 `started: YYYY-MM-DD`, `completed: YYYY-MM-DD` 한 줄 추가:

```markdown
# 01. install-skills.sh — rm-rf 가드

started: 2026-07-13
status: in-progress

## 상태
- [x] 시작 전
- [ ] 적용
- ...
```

`STATUS.md`는 작업 완료 시 [total/README.md](README.md)의 권장 순서를 그대로 옮기되, 진척 상황만 표시한다.

## 완료 조건
- [ ] `tasks/STATUS.md` 템플릿 작성
- [ ] 모든 작업 md에 `started`/`status` 헤더 추가 (또는 명시적으로 추가하지 않기로 결정)
- [ ] 첫 작업 시작 시 STATUS.md 갱신 정책 합의

## 검증
- [ ] `tasks/STATUS.md`가 단일 진입점 역할을 하는지
- [ ] 작업 카드의 체크박스와 STATUS.md의 in-progress가 일치하는지

## 의존
- ← 작업 **32**(커밋 메시지 토큰 규약)와 함께 운영 개선으로 묶어 적용

## 커밋 메시지 (예시)
```
chore(tasks): add STATUS.md board for at-a-glance progress
```