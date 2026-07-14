# 25. install-global-instructions.sh — 자동 생성 마커 단순화

## 상태
- [x] 시작 전
- [x] 적용
- [x] 검증
- [x] 완료

## 우선순위
🟡 **P2 — 작업 02 보강 (정확성)**

## 제안
**메타 분석** (세 모델 모두 미발굴)

## 의존
- ← 작업 **02**(백업)와 같은 커밋에 묶어 적용 권장

## 문제
작업 02의 권장 백업 로직:
```bash
head -1 "$dest" | grep -q '자동 생성'
```

하지만 [install-global-instructions.sh:30-32](../../install-global-instructions.sh#L30-L32) 가 출력하는 헤더는 3줄에 걸쳐 있음:

```
<!-- 자동 생성. 원본: ~/ai-tools-config/global-instructions/ -->
<!-- 동기화: install-global-instructions.sh -->
<!-- 이 파일을 직접 수정해도 다음 실행 시 덮어쓰입니다. -->
```

문제:
1. **`head -1`로는 첫 번째 줄만 봄**. 만약 누군가 첫 줄을 살짝 수정하면 백업 로직이 무력화됨 → 사용자 파일이 보호 없이 덮어써짐
2. **"자동 생성"이라는 한국어 구문이 모든 사용자에게 친숙하지 않음**. 영어 환경/혼합 환경에서 grep이 깨질 수 있음
3. **3줄 헤더는 사용자에게 보이는 노이즈**. 스크립트가 관리한다는 사실을 1줄로 충분히 전달 가능

## 권장 구현

### 1단계: 마커를 단일 토큰으로 통일

생성부:
```bash
{
  echo "<!-- AUTO-GENERATED-DO-NOT-EDIT -->"
  echo "# 원본: ~/ai-tools-config/global-instructions/ (install-global-instructions.sh 로 동기화)"
  echo
  cat "$COMMON"
} > "$tmp"
```

판별부:
```bash
grep -qF 'AUTO-GENERATED-DO-NOT-EDIT' "$dest"
```

→ `grep -qF`(fixed string)로 첫 줄 외 다른 위치에 있어도 판별 가능. 토큰이 길고 고유하므로 오탐 위험 없음.

### 2단계: 헤더를 2줄로 축약 (선택)

```bash
{
  echo "<!-- AUTO-GENERATED-DO-NOT-EDIT -->"
  echo "<!-- 동기화: install-global-instructions.sh — 직접 수정 시 다음 실행에 덮어써짐 -->"
  echo
  cat "$COMMON"
} > "$tmp"
```

사용자 가독성과 관리 효율을 모두 잡는다.

## 완료 조건
- [x] 마커가 단일 토큰 `AUTO-GENERATED-DO-NOT-EDIT`로 통일
- [x] 마커 판별이 라인 위치와 무관하게 동작
- [x] 사용자 안내 문구가 명확
- [x] 첫 실행(빈 파일 → 자동 생성)에서도 정상 동작

## 검증
```sh
TMPDIR=$(mktemp -d); HOME="$TMPDIR/home"
bash install-global-instructions.sh
head -1 "$HOME/.claude/CLAUDE.md"             # <!-- AUTO-GENERATED-DO-NOT-EDIT -->

# 사용자가 첫 줄을 지웠을 때도 보호받는지 확인
echo "내 지침" > "$HOME/.claude/CLAUDE.md"
bash install-global-instructions.sh
ls "$HOME/.claude/CLAUDE.md.bak.*"             # 백업 생성 확인
```

## 커밋 메시지 (예시, 작업 02와 통합 시)
```
fix(install-global-instructions): use single robust marker for managed files
```