# 04. README 트리 다이어그램 보강

## 상태
- [ ] 시작 전
- [ ] 수정 적용
- [ ] 검증
- [ ] 완료

## 우선순위
중

## 문제
[README.md "구성" 섹션](../../README.md) 의 트리 다이어그램이 `paced-explainer/`의 실제 파일을 모두 표시하지 않는다.

### 현재 (누락)
```
│   └── paced-explainer/                       # 4개 도구 공통 스킬
│       ├── SKILL.md
```

### 실제 디렉토리
```
skills/paced-explainer/
├── SKILL.md
├── agents/openai.yaml
└── references/depth-patterns.md
```

## 변경 파일
- `README.md`

## 변경 내용
트리 블록의 `paced-explainer/` 부분을 다음으로 교체:

```
│   └── paced-explainer/                       # 4개 도구 공통 스킬
│       ├── SKILL.md
│       ├── agents/openai.yaml
│       └── references/depth-patterns.md
```

## 검증
```sh
ls skills/paced-explainer
# SKILL.md  agents  references  만 보여야 함
```

## 커밋 메시지 (예시)
```
docs(readme): list agents/ and references/ in skill tree
```