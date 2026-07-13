# 17. README 트리 다이어그램에 agents/, references/ 추가

## 상태
- [x] 시작 전
- [x] 적용
- [x] 검증
- [x] 완료

## 우선순위
⚪ **P3 — 문서**

## 제안 모델
- ✅ m3 ([04-update-readme-tree-diagram.md](../m3/04-update-readme-tree-diagram.md)) — **다른 모델이 놓침**
- ❌ claude
- ❌ codex

## 문제
[README.md](../../README.md) "구성" 섹션 트리 다이어그램이 `paced-explainer/`의 실제 파일을 모두 표시하지 않음.

### 현재 (누락)
```
│   └── paced-explainer/                       # 4개 도구 공통 스킬
│       ├── SKILL.md
```

### 실제
```
skills/paced-explainer/
├── SKILL.md
├── agents/openai.yaml
└── references/depth-patterns.md
```

## 권장 구현

```
│   └── paced-explainer/                       # 4개 도구 공통 스킬
│       ├── SKILL.md
│       ├── agents/openai.yaml
│       └── references/depth-patterns.md
```

## 완료 조건
- [x] 트리가 실제 tracked 파일과 일치
- [x] (08 적용 후) `install-global-instructions.sh`와 `global-instructions/`도 함께 추가됨

## 검증
```sh
ls skills/paced-explainer   # SKILL.md agents references 만 보여야 함
```

## 커밋 메시지 (예시)
```
docs(readme): list agents/ and references/ in skill tree
```