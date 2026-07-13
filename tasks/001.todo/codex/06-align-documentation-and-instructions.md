# 문서와 지침의 불일치 정리

## 목적

README, 설치 스크립트, 스킬 설명, 전역 지침이 동일한 설치 구조와 기능을 설명하도록 정리한다.

## 작업

- README 구조도에 `global-instructions/`와 `install-global-instructions.sh`를 추가한다.
- 전역 지침 설치 및 갱신 방법을 README에 작성한다.
- 스킬 원본 위치를 저장소의 `skills/`로 통일한다.
- `paced-explrainer` 오타를 `paced-explainer`로 수정한다.
- 저장소에 없는 `graphify`, `ask-step-by-step`, `analyze-task`, `spec-task`, `start-task`가 외부 의존성이라면 이를 명시한다.
- 외부 의존성이 아니라면 존재하지 않는 트리거 지침을 제거한다.
- Copilot 전역 지침 지원 범위를 실제 설치 동작에 맞게 설명한다.

## 완료 조건

- 문서의 명령만 따라 새 머신에서 설치 과정을 이해할 수 있다.
- 원본 위치, 대상 경로, 지원 도구에 관한 설명이 파일마다 충돌하지 않는다.
- 존재하지 않는 기능을 내장 기능처럼 안내하지 않는다.
