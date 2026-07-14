# 11. install-skills.sh SRC_DIR 주석 정정

## 상태
- [x] 시작 전
- [x] 적용
- [x] 검증
- [x] 완료

## 우선순위
⚪ **P3 — 주석**

## 제안 모델
- ✅ claude ([08-fix-src-dir-comment.md](../claude/08-fix-src-dir-comment.md))
- ❌ codex
- ❌ m3

## 문제
[install-skills.sh:14](../../install-skills.sh#L14) 의 주석:

```bash
# 원본 폴더 (이 스크립트가 있는 곳의 부모)
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
```

주석은 "부모(parent)"라고 설명하지만 코드는 실제로 **스크립트 자기 폴더**를 반환한다(`..` 없음). `install-global-instructions.sh:12`는 같은 관용구를 올바른 주석과 함께 쓴다.

## 권장 구현

```bash
# 원본 폴더 (이 스크립트가 있는 폴더)
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
```

## 완료 조건
- [x] 주석이 SRC_DIR의 실제 값(스크립트 자기 폴더)을 정확히 설명

## 커밋 메시지 (예시)
```
docs(install-skills): correct SRC_DIR comment to match implementation
```