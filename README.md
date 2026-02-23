# Fresh Fish

# 📁 프로젝트 개요

+ **Fresh Fish**는 “루틴을 게임처럼” 관리하는 모바일 자기계발 앱입니다.
+ 사용자는 **퀘스트/할 일/집중 타이머**를 통해 하루의 목표를 수행하고, 보상(경험치/골드)을 얻어 수족관을 성장시키는 흐름으로 동기부여를 받습니다.
+ 앱은 **온보딩(카테고리 선택)**, **데일리 퀘스트**, **포모도로 타이머**, **업적/캘린더 통계**, **설정(알림 모드 등)** 기능을 제공합니다.
+ Flutter + Firebase 기반 개인 프로젝트 구조로 구성되어 있으며, Provider 상태관리와 로컬 저장소를 함께 사용합니다.

# 🤝 팀 소개

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
        <td>
            <a href=https://github.com/Hanguyun>
                <img object-fit=fill src=https://avatars.githubusercontent.com/u/207668924?v=4 width="200" height="200" alt="깃허브 페이지 바로가기">
            </a>
        </td>  
        <td>
            <a href=https://github.com/psm7288>
                <img object-fit=fill src=https://avatars.githubusercontent.com/u/164441790?v=4 width="200" height="200" alt="깃허브 페이지 바로가기">
            </a>
        </td>    
        <td>
            <a href=https://github.com/qkrgudduf7273-beep>
                <img object-fit=fill src=https://avatars.githubusercontent.com/u/252962964?v=4 width="200" height="200" alt="깃허브 페이지 바로가기">
            </a>
        </td>    
        <td>
            <a href=https://github.com/Hasegos>
                <img object-fit=fill src=https://avatars.githubusercontent.com/u/93961708?v=4 width="200" height="200" alt="깃허브 페이지 바로가기">
            </a>
        </td>    
    </tr>
</table>

# 🛠️ 기술 스택

+ **Frontend (Mobile)**:<img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" /><img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
+ **State Management**:<img src="https://img.shields.io/badge/Provider-4A90E2?style=for-the-badge" />
+ **Backend / BaaS**:<img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" /><img src="https://img.shields.io/badge/Firebase%20Auth-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" /><img src="https://img.shields.io/badge/Cloud%20Firestore-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" /><img src="https://img.shields.io/badge/Cloud%20Functions-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" />
+ **Local Data / Utility**:<img src="https://img.shields.io/badge/SharedPreferences-5C6BC0?style=for-the-badge" /><img src="https://img.shields.io/badge/Hive-F9A825?style=for-the-badge" /><img src="https://img.shields.io/badge/HTTP-607D8B?style=for-the-badge" />
+ **Notifications / Chart**:<img src="https://img.shields.io/badge/flutter__local__notifications-03A9F4?style=for-the-badge" /><img src="https://img.shields.io/badge/fl__chart-7E57C2?style=for-the-badge" /><img src="https://img.shields.io/badge/table__calendar-26A69A?style=for-the-badge" />

# 📁 디렉토리 구조

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

# 📊 ERD (Entity Relationship Diagram)

## 👤 Users (사용자)
|필드명 (Field)| 타입 (Type) | 설명       |
|---|----------|----------|
|id| String   | 사용자 고유 UID (Document ID), |
|gold| int      | 보유 재화    |
|waterQuality| int      | 수질 수치 (기본값 100) |
|currentDate| String   | 현재 날짜 (YYYY-MM-DD) |
|onboardingCompleted| bool     | 온보딩 완료 여부 |
|fish| Map      | "Fish 객체 (id, type, level, exp, hp, maxHp, eggHatchedAt)" |
|pomodoroSettings,Map,"포모도로 설정 (enabled, focusMinutes, shortBreak, etc.)"|
|achievements| Array<Map>| "업적 리스트 (id, title, description, icon, unlocked)" |
|history| Array<Map> | "일일 기록 (date, totalQuests, completedQuests, status)" |
|selectedCategories| Array<String> | 선택된 카테고리 목록 |

## ⚔️ Quests (퀘스트)
|필드명 (Field)| 타입 (Type) | 설명     |
|---|-------|--------|
|id| String | 퀘스트 고유 ID |
|title| String | 제목     |
|questType| String | "타입 (main, sub, habit, todo, daily)" |
|category| String | "카테고리 (study, health, etc.)" |
|difficulty| String | "난이도 (easy, normal, hard)" |
|completed| bool  | 완료 여부  |
|isBigQuest| bool  | 큰 퀘스트 판정 여부 (스냅샷) |
|durationMinutes| int   | 집중 타이머 시간(분) |
|completedAt| int| 완료 시각 (timestamp) |

## ⏱️ TimerSessions (타이머 세션)
|필드명 (Field)| 타입 (Type)       | 설명                |
|---|-----------------|-------------------|
|id| String          | 세션 고유 ID          |
|category| String          | 집중한 카테고리 명칭       |
|durationSeconds| int             | 총 집중 시간(초)        |
|startTime| int             | 시작 시각 (timestamp) |
|endTime| int             | 종료 시각 (timestamp) |
|completed| bool| 세션 정상 종료 여부       |

## ✅ Todos (할 일)
| 필드명 (Field)               | 타입 (Type) | 설명                 |
|---------------------------|-----------|--------------------|
| id| String    | 할 일 고유 ID          |
 | title| String    | 제목                 |
 | description| String    | 상세 설명              |
 | dueDate| String    | 마감 기한 (YYYY-MM-DD) |
 | completed| bool      | 완료 상태              |
| createdAt| int       | 생성 시각     |

# 📱 화면 구성

### 로그인 / 회원가입 UI (Auth)
<img width="342" height="648" alt="Image" src="https://github.com/user-attachments/assets/c2145471-2778-4189-88fa-9c4a7acc3f5d" />
<img width="367" height="651" alt="Image" src="https://github.com/user-attachments/assets/18aa1610-342b-4daf-85cd-b1d184004082" />

- 메인 담당자 : 한구윤
- 인증 세션 관리 및 실시간 업적 매핑 알고리즘 최적화

### 온보딩 UI (Onboarding)
<img width="444" height="968" alt="Image" src="https://github.com/user-attachments/assets/77b956a0-a3c9-481a-b439-cff11fe4ba2c" />
<img width="446" height="957" alt="Image" src="https://github.com/user-attachments/assets/cc086c88-6d9e-4cc1-973c-d160d225f7c4" />

- 메인 담당자 :
-

### 메인 UI (Home)
<img width="364" height="653" alt="Image" src="https://github.com/user-attachments/assets/90e597cf-45a8-49b1-91f6-86cdece0c628" />

- 메인 담당자 : 한구윤, 박영수
- 프레임 저하 없는 최적화된 수족관 애니메이션 구현, 실시간 데이터 연동을 통한 사용자 맞춤형 성장형 UI 완성

### 퀘스트 UI (Quests)
<img width="359" height="653" alt="Image" src="https://github.com/user-attachments/assets/29fbb8c8-c317-4a72-a20d-29899bb91d10" />
<img width="356" height="653" alt="Image" src="https://github.com/user-attachments/assets/bd98acd5-94be-4dfc-8c10-12bcbdc73302" />

- 메인 담당자 : 박수민
- 인증 세션 및 실시간 업적 알고리즘 최적화, 보상 기반 성장 로직 구현, 데이터 동기화와 프로젝트 통합 운영 관리

### 타이머 UI (Timer)
<img width="357" height="654" alt="Image" src="https://github.com/user-attachments/assets/7d76c8eb-673c-4850-a9aa-cbe2fb2e7189" />
<img width="352" height="656" alt="Image" src="https://github.com/user-attachments/assets/bf92990b-34eb-4cae-80a2-3f759bf8b016" />

- 메인 담당자 :
- 사용자 데이터 기반 실시간 업적 매핑 알고리즘 최적화, 인증 세션 안정화 구현

### 캘린더 UI (Calendar)
<img width="352" height="656" alt="Image" src="https://github.com/user-attachments/assets/ff863e67-c3cf-46a8-8a68-fd9609582162" />
<img width="340" height="653" alt="Image" src="https://github.com/user-attachments/assets/9d722061-501b-4de8-9158-80519dc126c8" />
<img width="371" height="652" alt="Image" src="https://github.com/user-attachments/assets/7912ce97-0182-4381-9b12-46423d792cde" />

- 메인 담당자 :
- 날짜별 활동 기록 캘린더와 카테고리별 집중 분포 차트를 활용한 맞춤형 통계 대시보드 및 세션 리포트 구현

### 업적 UI (Achievements)
<img width="361" height="649" alt="Image" src="https://github.com/user-attachments/assets/8594098c-42b2-4d04-aaee-6c83cebe7339" />

- 메인 담당자 :
-

### 셋팅 UI (Settings)
<img width="361" height="652" alt="Image" src="https://github.com/user-attachments/assets/d1dbeeb8-7050-46aa-9b07-6bc88adebcb9" />
<img width="358" height="647" alt="Image" src="https://github.com/user-attachments/assets/572b6f8e-d7b3-494c-9449-824e76c204f8" />
<img width="361" height="651" alt="Image" src="https://github.com/user-attachments/assets/cf184781-fe14-4308-87c3-b5c0720d4e52" />

- 메인 담당자 :
- 활동 기록 캘린더 및 카테고리별 집중 데이터 시각화 차트 구현, Provider 상태 관리 구조 설계 및 도메인 간 의존성 정립

# ✨ 핵심 기능

### 1) 온보딩 & 사용자 흐름
+ 앱 첫 실행 시 온보딩과 카테고리 선택을 거쳐 초기 사용자 데이터를 생성합니다.
+ 로그인/회원가입 화면이 분리되어 있으며, 인증 완료 후 메인 앱 화면으로 이동합니다.

### 2) 퀘스트 / 데일리 루틴
+ 퀘스트 생성/수정/삭제 및 완료 처리를 지원합니다.
+ 퀘스트 완료 시 경험치/골드를 보상으로 지급하고, 업적 조건과 연동됩니다.

### 3) 타이머(집중 세션)
+ 카테고리 기반 타이머로 집중 시간을 기록합니다.
+ 백그라운드 복귀 시 타이머 상태를 반영하며, 세션 완료 시 히스토리/보상에 반영됩니다.

### 4) 수족관 성장 UX
+ 메인 화면에서 수족관 비주얼(물고기/버블/빛 효과 등)을 제공합니다.
+ 사용자의 활동 결과가 성장 시스템과 연결되어 게임화된 피드백을 제공합니다.

### 5) 캘린더 / 통계 / 업적
+ 날짜별 활동 기록 조회 및 통계 모달(총 집중시간, 카테고리별 분포 등)을 제공합니다.
+ 누적 행동 데이터 기반 업적 달성 현황을 확인할 수 있습니다.

### 6) 설정 & 알림
+ 알림 모드(소리/진동/무음) 설정을 제공합니다.
+ 설정 화면에서 업적 화면 진입 등 사용자 관리 동선을 제공합니다.

# 📌 API 명세표
| 분류 | 기능명 | 메서드/경로 | 입력 데이터 | 설명 |
| --- | --- | --- | --- | --- |
| 인증 | 익명 로그인 | signInAnonymously | - | Firebase 익명 인증을 수행하고 유저 UID를 발급받음 |
| 데이터 | 유저 정보 저장 | set / users/{uid} | UserData (Object) | 로컬의 유저 데이터를 Firestore 서버에 전체 저장 |
| 데이터 | 유저 정보 로드 | get / users/{uid} | uid (String) | 서버에서 데이터를 가져와 앱 모델(UserData)로 변환 |
| 데이터 | 실시간 동기화 | snapshots / users/{uid} | - | 서버 데이터 변경 시 실시간으로 앱 UI를 업데이트(Stream) |
| 통계 | 집중 시간 누적 | Transaction / users/{uid} | category, duration | 트랜잭션을 사용해 stats 필드의 누적 시간/세션을 안전하게 업데이트 |
| 관리 | 데이터 초기화 | delete / users/{uid} | uid (String) | 서버와 로컬에 저장된 모든 사용자 데이터를 삭제 |