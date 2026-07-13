# 29. .gitignore + README — tasks/ 추적 정책 명시

## 상태
- [ ] 시작 전
- [ ] 방안 결정
- [ ] 적용
- [ ] 검증
- [ ] 완료

## 우선순위
⚪ **P3 — 위생 / 정책 명시**

## 제안
**메타 분석** (세 모델 모두 미발굴)

## 문제
[.gitignore](../../.gitignore) 에는 `*.bak`, `*.tmp`, `*.swp`, `.DS_Store` 등 일반 노이즈만 등록되어 있고 **`tasks/`에 대한 정책이 없음**.

현재 상태:
- `tasks/001.todo/`에는 50+ 작업 카드 md가 있음
- 모두 명시적으로 `git add`되어 추적됨
- **다른 사람이 이 리포를 clone했을 때 작업 카드가 함께 딸려옴** (개인 작업 메모인데)

또는 반대로:
- 향후 누군가 임시 메모를 `tasks/scratch/`에 두고 `git add .`하면 그대로 들어감

→ **`tasks/`가 추적 대상인지 아닌지, 어느 부분만 추적하는지 정책 부재**.

## 권장 방안

### 방안 A: tasks/ 전체를 추적 (현재 상태 유지)
- README에 "이 리포는 개인 작업 카드도 함께 추적한다" 명시
- `.gitignore` 변경 없음
- 외부 사용자는 작업 카드를 무시하면 됨

### 방안 B: tasks/ 전체를 비추적
- `.gitignore`에 `tasks/` 추가
- 작업 카드는 로컬에서만 관리
- **단, 현재 추적 중인 작업 카드 50+개가 모두 추적 해제됨** → 마이그레이션 필요

### 방안 C: 구조 분리 (가장 깔끔)
- 작업 카드는 `.tasks/` (숨김) 또는 `private/tasks/`로 이동
- 공개 추적 대상에서 제외
- `.gitignore`에 해당 경로 추가

## 권장

**방안 A** (변경 최소). README에 정책을 한 줄 명시:

```markdown
> 참고: `tasks/` 디렉토리의 작업 카드(`001.todo`, `002.done`)도 추적 대상이다.
> 이 리포를 fork하거나 clone한 경우, 작업 카드는 자유롭게 삭제해도 무방하다.
```

그리고 `.gitignore`에는 손상 방지를 위한 항목만 유지(현狀).

## 완료 조건
- [ ] README에 `tasks/` 추적 정책 명시
- [ ] `.gitignore`는 의도적으로 변경하지 않음 (방안 A 기준)

## 검증
```sh
git ls-files tasks/ | head -5    # 추적되고 있음을 확인
grep -i 'tasks' README.md        # README에 정책 명시 확인
grep -E '^tasks/?$' .gitignore   # 매칭 없어야 함 (방안 A)
```

## 커밋 메시지 (예시)
```
docs: clarify tasks/ tracking policy in README
```