# 🎨 Fresh Fish - UI/UX 디자인 시스템

## 📋 개요
**Fresh Fish**는 사용자의 성장을 돕는 자기계발 앱으로, **"부드러운 파스텔 톤의 효율성"**을 디자인 철학으로 합니다.

---

## 🎯 디자인 철학

### 핵심 가치
- **효율성**: 명확한 시각적 계층구조로 정보 전달
- **편안함**: 파스텔 톤과 부드러운 모서리로 친근함
- **접근성**: 높은 명도 대비로 시각적 명확성 확보
- **일관성**: 모든 컴포넌트의 통일된 스타일 적용

---

## 🎨 색상 팔레트

### 배경색 (Background)
```
극도로 밝은 회색: #F8F9FA
├─ 페이지 배경
└─ 베이스 톤

순백색: #FFFFFF
├─ 카드 표면
├─ 모달 및 팝업
└─ 입력 필드 배경

매우 밝은 그레이: #FAFBFC
└─ 대체 표면색 (홀수 행)

밝은 그레이: #F5F6F8
└─ 그룹 섹션 배경
```

### 텍스트색 (Text)
```
짙은 차콜 (#333333)      → 제목, 주요 텍스트 (본문)
중간 그레이 (#666666)    → 보조 텍스트 (부제목)
밝은 그레이 (#999999)    → 비활성/힌트 텍스트
연한 그레이 (#CCCCCC)    → 완전 비활성 요소
```

### 포인트 색상 (Accent - 파스텔 톤)
```
파스텔 민트 (#7DD3C0)
├─ 메인 액션 버튼
├─ 프라이머리 강조색
├─ 카테고리: "건강", "자기계발"
└─ 진행률 지표 (상태: 완료)

밝은 민트 (#81E6D9)
├─ 세컨더리 강조색
└─ 비활성 상태의 밝은 버전

스카이블루 (#87CEEB)
├─ 카테고리: "학업"
├─ 정보 배지
└─ 선택 표시

파스텔 복숭아 (#FFD4A3)
├─ 경고 상태
├─ 진행 중 습관
└─ 중간 우선순위 표시

파스텔 라벤더 (#B4A7D6)
├─ 특별 강조
├─ 카테고리: "업무"
└─ 고급 기능 표시

파스텔 핑크 (#FCA5A5)
├─ 긴급/에러 상태
├─ 특별 보상
└─ 높은 우선순위 표시
```

### 상태 색상 (Semantic)
```
성공 (#6BBF8E)      → 완료, 통과, 성취
경고 (#D4A574)      → 주의 필요, 진행 중
에러 (#C9726A)      → 실패, 미완료, 오류
정보 (#87CEEB)      → 안내, 설명, 팁
```

---

## 🔲 형태 (Shape)

### Border Radius (모서리 둥글기)
```
Border Radius: 20-24px (기본)
├─ 카드 (.card)
├─ 버튼 (.button)
├─ 모달
└─ 주요 컴포넌트

Border Radius: 12px (보조)
├─ 배지
├─ 입력 필드
└─ 작은 컴포넌트

Border Radius: 50% (원형)
└─ 아바타, 원형 진행 표시기
```

### 그림자 (Elevation)
```
elevation: 0 (없음)
└─ 평면 디자인 요소

elevation: 1 (미묘함)
├─ 기본 카드
├─ 입력 필드
└─ 일반 버튼

elevation: 2 (약함)
├─ 높은 엘리베이션 카드
├─ 플로팅 버튼
└─ 모달 초기 상태

BlurRadius: 8px / Offset: (0, 2)
├─ 기본 그림자
└─ 가독성 우선 설계
```

---

## 📏 간격 (Spacing)

### Padding & Margin (최소 16dp)
```
Padding: 16dp (기본)
├─ 카드 내부 여백
├─ 섹션 간격
└─ 컨테이너 내부 공간

Padding: 12dp (압축)
├─ 버튼 내부 텍스트
├─ 작은 요소
└─ 리스트 아이템

Padding: 20-24dp (확대)
├─ 페이지 상단/하단
├─ 섹션 헤더
└─ 주요 구분선
```

### 정보 밀도
- **저밀도**: 섹션 간 24dp 간격
- **중밀도**: 섹션 간 16dp 간격
- **고밀도**: 아이템 간 8-12dp 간격

---

## 🔤 타이포그래피

### 폰트 스택
```
Sans-Serif (기본)
├─ Display Large (32pt, Bold)    → 메인 타이틀
├─ Headline Large (24pt, Semi-Bold) → 섹션 제목
├─ Title Large (16pt, Semi-Bold)   → 카드 제목
├─ Body Large (16pt, Regular)      → 본문 텍스트
└─ Body Small (12pt, Regular)      → 보조 텍스트

Letter Spacing: -0.5 ~ 0.5 (가독성 최적화)
```

---

## 🎯 컴포넌트 가이드

### 버튼

#### Primary Button (메인 액션)
```
배경색: Pastel Mint (#7DD3C0)
텍스트: White
Padding: 24px × 14px
Border Radius: 24px
Elevation: 2
```

#### Secondary Button (보조 액션)
```
배경색: Transparent
테두리: Pastel Mint (#7DD3C0) 1.5px
텍스트: Pastel Mint
Padding: 24px × 14px
Border Radius: 24px
```

#### Text Button (최소 액션)
```
배경색: Transparent
텍스트: Pastel Mint
Padding: 16px × 12px
Border Radius: 24px
```

### 카드

#### 기본 카드
```
배경: White (#FFFFFF)
Border Radius: 20px
Elevation: 1
Border: 0.5px #EEEEEE
Padding: 16dp
```

#### 높은 엘리베이션 카드
```
배경: White (#FFFFFF)
Border Radius: 20px
Elevation: 2
Border: 0.5px #EEEEEE
```

#### 특별 강조 카드
```
배경: White (#FFFFFF)
Border: 1.5px Pastel Lavender (#B4A7D6)
Elevation: 2
Accent Color Shadow
```

### 입력 필드

```
배경: Light Gray (#FAFBFC)
Border: 1px #E0E0E0
Border Radius: 20px
Focus Border: 2px Pastel Mint (#7DD3C0)
Padding: 16px × 14px
```

### 배지 (Badge)

#### 상태 배지
```
배경: 투명 + 색상 15% 불투명도
Border: 0.5px 색상 40% 불투명도
Border Radius: 12px
Padding: 4px × 8px
```

예시:
- 완료: Pastel Mint 배경
- 진행 중: Peach 배경
- 미완료: Light Gray 배경

---

## 🎨 시각적 계층구조

### 중요도 기반 색상 채도
```
높음 (100%)
├─ Primary Actions
├─ 진행률 표시
└─ 완료 상태

중간 (70-80%)
├─ Secondary Elements
├─ Hover States
└─ 경고 상태

낮음 (30-40%)
├─ Disabled States
├─ Hints
└─ 완전 비활성
```

---

## 📐 레이아웃 그리드

### Safe Area
```
Top: 16dp (상태 바 고려)
Bottom: 16dp (네비게이션 바 고려)
Left/Right: 16dp (기본)
```

### 컨테이너 너비
```
Mobile (< 600dp): Full Width - 32dp (좌우 여백)
Tablet (≥ 600dp): 600dp 또는 88% 중 작은 값
```

---

## 🌍 응답성 (Responsiveness)

### 브레이크포인트
```
Mobile:  < 600dp     (핸드폰)
Tablet:  600-1200dp  (태블릿)
Desktop: ≥ 1200dp    (데스크톱)
```

### 레이아웃 조정
- **모바일**: 싱글 칼럼, 풀 너비
- **태블릿**: 투 칼럼, 최대 너비 제한
- **데스크톱**: 멀티 칼럼, 센터 정렬

---

## 🔄 마이크로 인터랙션

### Transition
```
기본 애니메이션: 200ms
├─ 버튼 클릭
├─ 상태 변화
└─ 색상 전환

페이지 전환: 300ms
└─ 라우팅 애니메이션

스크롤: 150ms
└─ 진행 표시기 업데이트
```

### Hover & Focus States
```
Opacity: 80% (Hover)
Scale: 1.02x (살짝 확대)
Elevation: +1 (그림자 강화)
```

---

## 📱 기본 대시보드 구조

### Top Bar
- 앱 로고 또는 제목
- 프로필 / 설정 버튼
- 배경: White (#FFFFFF)
- 높이: 56dp

### Main Content Area
- 여러 섹션 카드로 구성
- 각 섹션은 최소 16dp 간격
- 배경: Light Gray (#F8F9FA)

### Bottom Navigation
- 5개 주요 탭
- 아이콘 + 라벨
- 높이: 56dp (+ 안전 영역)
- 활성 탭: Pastel Mint
- 비활성 탭: Gray

### 섹션 예시
```
1. 진행 상황 요약
   ├─ 오늘의 목표 진행률
   ├─ 주간 활동 그래프
   └─ 포인트/리워드

2. 오늘의 할일
   ├─ 習慣 체크리스트
   ├─ 퀘스트
   └─ 타이머

3. 물고기 / 수족관
   ├─ 애니메이션 렌더링
   └─ 레벨/상태

4. 주간 리뷰
   ├─ 통계
   └─ 배지/성취
```

---

## 🛠️ 구현 가이드

### Color 정의 (app_colors.dart)
```dart
static const Color primary = Color(0xFF7DD3C0); // Pastel Mint
static const Color surface = Color(0xFFFFFFFF); // White
```

### Theme 적용 (app_theme.dart)
```dart
ThemeData get lightTheme {
  return ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      surface: AppColors.surface,
    ),
  );
}
```

### Decoration 사용 (app_decorations.dart)
```dart
Container(
  decoration: AppDecorations.card(),
  child: YourWidget(),
)
```

---

## ✅ 품질 체크리스트

- [ ] 모든 카드의 Border Radius 20-24px 준수
- [ ] 배경 명도 대비 확인 (WCAG AA 이상)
- [ ] 텍스트 색상 대비 확인 (비율 4.5:1 이상)
- [ ] 최소 간격 16dp 준수
- [ ] 페이지 하단에 안전 영역 (bottom: 16dp) 확보
- [ ] 비활성 버튼 투명도 처리
- [ ] 애니메이션 부드러움 (200-300ms)
- [ ] 다크모드 호환성 검토 (향후)

---

## 🔮 향후 개선

- [ ] 다크모드 지원
- [ ] 고대비 모드 (Accessibility)
- [ ] 커스텀 폰트 적용 (예: Pretendard)
- [ ] 애니메이션 라이브러리 통합
- [ ] 컴포넌트 스토리북 구축
- [ ] 색상 접근성 자동 검사

---

## 📞 문의 & 피드백

디자인 시스템에 대한 의견은 언제든 환영합니다.
주요 수정사항은 이 문서를 먼저 업데이트 후 코드에 적용해주세요.
