# Fresh Fish

## 📁 프로젝트 개요

+ **Fresh Fish**는 “루틴을 게임처럼” 관리하는 모바일 자기계발 앱입니다.
+ 사용자는 **퀘스트/할 일/집중 타이머**를 통해 하루의 목표를 수행하고, 보상(경험치/골드)을 얻어 수족관을 성장시키는 흐름으로 동기부여를 받습니다.
+ 앱은 **온보딩(카테고리 선택)**, **데일리 퀘스트**, **포모도로 타이머**, **업적/캘린더 통계**, **설정(알림 모드 등)** 기능을 제공합니다.
+ Flutter + Firebase 기반 개인 프로젝트 구조로 구성되어 있으며, Provider 상태관리와 로컬 저장소를 함께 사용합니다.

## 🤝 팀 소개

<table border="1">
    <thead>
        <tr><td colspan="1" align="center">Fresh Fish</td></tr>
    </thead>
    <tr align="center">
        <td>팀장 박영수</td>
        <td>팀원 한구윤</td>
        <td>팀원 박수민</td>
        <td>팀원 박형열</td>
        <td>팀원 최수호</td>
    </tr>
    <tr>
        <td>
            <a href=https://github.com/xuxtaku7610-del>
                <img object-fit=fill src=https://avatars.githubusercontent.com/u/245087152?v=4 width="200" height="200" alt="깃허브 페이지 바로가기">
            </a>
        </td>    
    </tr>
    <tr>
        <td>
            <a href=https://github.com/Hanguyun>
                <img object-fit=fill src=https://avatars.githubusercontent.com/u/207668924?v=4 width="200" height="200" alt="깃허브 페이지 바로가기">
            </a>
        </td>    
    </tr>
    <tr>
        <td>
            <a href=https://github.com/psm7288>
                <img object-fit=fill src=https://avatars.githubusercontent.com/u/164441790?v=4 width="200" height="200" alt="깃허브 페이지 바로가기">
            </a>
        </td>    
    </tr>
    <tr>
        <td>
            <a href=https://github.com/qkrgudduf7273-beep>
                <img object-fit=fill src=https://avatars.githubusercontent.com/u/252962964?v=4 width="200" height="200" alt="깃허브 페이지 바로가기">
            </a>
        </td>    
    </tr>
    <tr>
        <td>
            <a href=https://github.com/Hasegos>
                <img object-fit=fill src=https://avatars.githubusercontent.com/u/93961708?v=4 width="200" height="200" alt="깃허브 페이지 바로가기">
            </a>
        </td>    
    </tr>
</table>

## 🛠️ 기술 스택

+ **Frontend (Mobile)**:
<img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
<img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
+ **State Management**:
<img src="https://img.shields.io/badge/Provider-4A90E2?style=for-the-badge" />
+ **Backend / BaaS**:
<img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" />
<img src="https://img.shields.io/badge/Firebase%20Auth-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" />
<img src="https://img.shields.io/badge/Cloud%20Firestore-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" />
<img src="https://img.shields.io/badge/Cloud%20Functions-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" />
+ **Local Data / Utility**:
<img src="https://img.shields.io/badge/SharedPreferences-5C6BC0?style=for-the-badge" />
<img src="https://img.shields.io/badge/Hive-F9A825?style=for-the-badge" />
<img src="https://img.shields.io/badge/HTTP-607D8B?style=for-the-badge" />
+ **Notifications / Chart**:
<img src="https://img.shields.io/badge/flutter__local__notifications-03A9F4?style=for-the-badge" />
<img src="https://img.shields.io/badge/fl__chart-7E57C2?style=for-the-badge" />
<img src="https://img.shields.io/badge/table__calendar-26A69A?style=for-the-badge" />

## 📁 디렉토리 구조

```text
fresh-fish/
├── lib/
│   ├── constants/           # 앱 전역 상수
│   ├── data/                # 업적/퀘스트 템플릿, 타이머 카테고리 정적 데이터
│   ├── models/              # UserData, Quest, Timer, Fish 등 도메인 모델
│   ├── providers/           # AppProvider, UserDataProvider 상태관리
│   ├── screens/
│   │   ├── auth/            # 로그인/회원가입
│   │   ├── onboarding/      # 온보딩/카테고리 선택
│   │   ├── main/            # 메인(수족관 + 탭 구조)
│   │   ├── quests/          # 퀘스트/데일리 화면
│   │   ├── timer/           # 집중 타이머
│   │   ├── calendar/        # 캘린더/통계
│   │   ├── achievements/    # 업적
│   │   ├── settings/        # 설정
│   │   └── menu/            # 메뉴 허브 화면
│   ├── services/            # Firebase, 로컬 스토리지, 알림 서비스
│   ├── theme/               # 테마/컬러/텍스트 스타일
│   ├── utils/               # 성장/레벨/퀘스트/시간 관련 유틸
│   ├── widgets/             # 공통 위젯 + 수족관 커스텀 페인터
│   ├── firebase_options.dart
│   └── main.dart            # 앱 시작점
├── assets/                  # 이미지/물고기 스프라이트/비주얼 리소스
├── android/                 # Android 네이티브 설정
├── ios/                     # iOS 네이티브 설정
├── firestore.rules          # Firestore 보안 규칙
├── firebase.json            # Firebase 설정
└── pubspec.yaml             # 의존성/에셋/프로젝트 설정
```

## ✨ 핵심 기능

### 1) 온보딩 & 사용자 흐름
앱 첫 실행 시 온보딩과 카테고리 선택을 거쳐 초기 사용자 데이터를 생성합니다.
로그인/회원가입 화면이 분리되어 있으며, 인증 완료 후 메인 앱 화면으로 이동합니다.

### 2) 퀘스트 / 데일리 루틴
퀘스트 생성/수정/삭제 및 완료 처리를 지원합니다.
퀘스트 완료 시 경험치/골드를 보상으로 지급하고, 업적 조건과 연동됩니다.

### 3) 타이머(집중 세션)
카테고리 기반 타이머로 집중 시간을 기록합니다.
백그라운드 복귀 시 타이머 상태를 반영하며, 세션 완료 시 히스토리/보상에 반영됩니다.

### 4) 수족관 성장 UX
메인 화면에서 수족관 비주얼(물고기/버블/빛 효과 등)을 제공합니다.
사용자의 활동 결과가 성장 시스템과 연결되어 게임화된 피드백을 제공합니다.

### 5) 캘린더 / 통계 / 업적
날짜별 활동 기록 조회 및 통계 모달(총 집중시간, 카테고리별 분포 등)을 제공합니다.
누적 행동 데이터 기반 업적 달성 현황을 확인할 수 있습니다.

### 6) 설정 & 알림
알림 모드(소리/진동/무음) 설정을 제공합니다.
설정 화면에서 업적 화면 진입 등 사용자 관리 동선을 제공합니다.

## 📱 화면 구성

**Auth**: 로그인, 회원가입
**Onboarding**: 앱 가이드, 카테고리 선택
**Main**: 수족관 메인 + 하단 네비게이션
**Quests**: 퀘스트 목록/데일리 루틴
**Timer**: 집중 타이머 실행/완료
**Calendar**: 날짜별 활동 기록 및 통계
**Achievements**: 업적 목록
**Settings**: 알림/일반 설정

## 🚀 실행 방법

### 1) 사전 요구사항
Flutter SDK (Dart 포함)
Android Studio 또는 Xcode
Firebase 프로젝트(현재 리포의 `firebase_options.dart`, `google-services.json` 등과 매칭 필요)

+### 2) 의존성 설치

```bash
flutter pub get
```

### 3) 앱 실행

```bash
+flutter run
```

### 4) 테스트

```bash
+flutter test
```

## 🔐 Firebase 관련 참고

Firebase 초기화는 `main.dart`에서 수행합니다.
인증/데이터 연동은 `lib/services/firebase_service.dart` 중심으로 구성되어 있습니다.
로컬 저장소(`StorageService`)와 병행 사용하여 오프라인/초기 구동 안정성을 보완합니다.

## 📝 비고

이 README는 현재 브랜치 기준 코드 구조/화면/기능을 바탕으로 정리되었습니다.
추후 OAuth 연동 고도화, 알림 설정 영속화, 기능별 문서 분리(API/데이터 모델/아키텍처) 등을 진행하면 문서를 확장하기 좋습니다.