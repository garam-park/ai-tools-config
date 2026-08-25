# 설계 프레임워크 7종

> 출처: vault `00 Inbox/설계 잘하기/01-설계-프레임워크-7종.md`
> 이 파일은 vault의 정리본을 작업용으로 복사한 것입니다. 원전이 갱신되면 이 사본도 갱신해야 합니다.

---


서버 및 인프라 아키텍처 설계서를 쓸 때 참조할 만한 잘 알려진 프레임워크 7가지다.
각 프레임워크는 *어디에 초점*을 맞추는지에 따라 다르며, 한 문서가 모두를 만족시킬 필요는 없다.

## 7종 요약

| 프레임워크 | 초점 | 매핑 시 다루는 것 |
| --- | --- | --- |
| [TOGAF ADM](#1-togaf) | 엔터프라이즈 전체 | Business / Data / Application / Technology 4계층 |
| [AWS Well-Architected](#2-aws-well-architected) | 클라우드 워크로드 | 6개 기둥 (운영·보안·신뢰성·성능·비용·지속가능성) |
| [Kruchten 4+1 View](#3-kruchten-4+1-view) | 다중 관점 | Logical / Development / Process / Physical + Scenarios |
| [C4 Model](#4-c4-model) | 다이어그램 추상화 | Context / Container / Component / Code 4단계 |
| [IEEE 1471 / ISO 42010](#5-ieee-1471--iso-42010) | 문서 구조 | Stakeholder → Concern → Viewpoint → View |
| [12-Factor App](#6-12-factor-app) | 애플리케이션 | 코드·의존성·설정·프로세스·로그 등 12요인 |
| [ADR](#7-adr) | 결정 기록 | Context · Decision · Consequences |

## 1. TOGAF

The Open Group Architecture Framework. 1995년부터 유지된 엔터프라이즈 아키텍처 프레임워크.
ADM(Architecture Development Method) 사이클로 비전·비즈니스·정보시스템·기술·전환 설계·변경 관리 단계를 돈다.

핵심 개념은 **Business / Data / Application / Technology 4계층**.
설계서가 8장으로 평탄화되어 있어도, 각 장이 이 4계층 중 어디에 속하는지 떠올리면 책임이 섞이지 않는다.

## 2. AWS Well-Architected

사실상 업계 표준. 클라우드 워크로드가 만족시켜야 할 6개 기둥을 정의한다.

| 기둥 | 의미 |
| --- | --- |
| Operational Excellence | 운영 자동화·관측·개선 사이클 |
| Security | 기밀성·무결성·가용성·트래스트 |
| Reliability | 장애 복구·변경·재해 복구 |
| Performance Efficiency | 자원 선택·스케일·모니터링 |
| Cost Optimization | 가치 전달 중심의 비용 관리 |
| Sustainability | 환경 영향 최소화 |

Azure·GCP도 각자의 변형이 있다 (Azure는 5개, GCP도 5개 + Sustainability 등).

## 3. Kruchten 4+1 View

Philippe Kruchten, 1995. 한 시스템을 5가지 관점으로 묘사한다.

| 뷰 | 묘사 | 본 설계서의 흡수 위치 |
| --- | --- | --- |
| Logical | 기능·책임 분리 | 장 2 (논리 아키텍처) |
| Development | 모듈·빌드 의존 | 장 2 일부 |
| Process | 런타임 동시성 | 장 6 (가용성)에 흡수 |
| Physical | 노드·배치 | 장 3 (배포 토폴로지) · 장 4 (네트워크) |
| Scenarios (+1) | 핵심 유스케이스 | 다른 4뷰를 검증 |

## 4. C4 Model

Simon Brown, 2018. 다이어그램의 *추상화 레벨*만 정의한다.

| 레벨 | 묘사 |
| --- | --- |
| Context | 시스템과 외부 행위자 |
| Container | 프로세스·데이터 저장소 |
| Component | 모듈 내부 구조 |
| Code | 클래스 다이어그램 (보통 생략) |

핵심 규칙: *한 다이어그램은 한 레벨만 다룬다.*

## 5. IEEE 1471 / ISO 42010

아키텍처 **문서 자체**의 구조를 정의하는 표준.

> Stakeholder → Concern → Viewpoint → View

즉 *누가 무엇이 걱정되는지에 따라 어떤 도식을 보여줄지*를 먼저 결정한다.
설계서를 쓸 때 "이 도식은 *누구의 어떤 걱정*에 답하는가?"를 먼저 묻는 규칙이다.

## 6. 12-Factor App

Heroku, 2011. 애플리케이션·런타임 구성의 12가지 원칙.

1. **Codebase** — 하나의 코드베이스, 여러 배포
2. **Dependencies** — 의존성 명시 선언
3. **Config** — 설정을 환경에 분리
4. **Backing Services** — 자원을 연결된 자원으로 취급
5. **Build, Release, Run** — 세 단계 엄격히 분리
6. **Processes** — Stateless 프로세스
7. **Port Binding** — 포트로 서비스 노출
8. **Concurrency** — 프로세스 모델로 확장
9. **Disposability** — 빠른 시작·우아한 종료
10. **Dev/Prod Parity** — 개발·운영 환경 일치
11. **Logs** — 이벤트 스트림으로 취급
12. **Admin Processes** — 일회성 관리 작업을 일반 프로세스로

설계서가 런타임 구성을 다룰 때, 이 12요인 중 어디에 해당하는지 묻는 게 빠르다.

## 7. ADR

Architecture Decision Records (Michael Nygard, 2011).

| 항목 | 의미 |
| --- | --- |
| Context | 결정을 둘러싼 상황·제약 |
| Decision | 무엇을 결정했나 |
| Consequences | 결과 (긍정·부정·중립) |
| Status | 제안 / 결정 / 폐기 / 대체됨 |

설계서와 ADR의 역할 분담:

- **설계서** — *현재 상태*를 보여준다.
- **ADR** — *왜 그렇게 결정했나*의 근거를 보관한다.
