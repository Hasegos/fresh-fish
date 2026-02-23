import 'package:flutter/material.dart';

/// 앱 전역 색상 팔레트 (부드러운 파스텔 톤의 효율성)
/// 
/// 디자인 시스템 가이드라인:
/// - 배경: 극도로 밝은 회색 (#F8F9FA)
/// - 카드: 순백색 (#FFFFFF)
/// - 텍스트: 짙은 차콜 (#333333)
/// - 포인트: 파스텔 민트, 스카이블루, 핑크
/// - 채도: 중간~낮음 (가독성과 편안함 우선)
class AppColors {
  // ============ 기본 색상 (파스텔 톤 포인트) ============
  static const Color primary = Color(0xFF7DD3C0); // 파스텔 민트 (메인 액션)
  static const Color primaryPastel = Color(0xFF7DD3C0); // 파스텔 민트 (메인 액션)
  static const Color secondary = Color(0xFF81E6D9); // 밝은 민트 (보조)
  static const Color secondaryPastel = Color(0xFF81E6D9); // 밝은 민트 (보조)
  static const Color accent = Color(0xFFB4A7D6); // 파스텔 라벤더 (강조)
  static const Color accentPastel = Color(0xFFB4A7D6); // 파스텔 라벤더 (강조)
  static const Color highlight = Color(0xFFFCA5A5); // 파스텔 핑크 (특별 강조)
  static const Color highlightPink = Color(0xFFFCA5A5); // 파스텔 핑크 (특별 강조)
  
  // ============ 배경 색상 ============
  static const Color background = Color(0xFFF8F9FA); // 극도로 밝은 회색
  static const Color surface = Color(0xFFFFFFFF); // 순백색 (카드 배경)
  static const Color surfaceLight = Color(0xFFFAFBFC); // 매우 밝은 그레이
  static const Color surfaceAlt = Color(0xFFF5F6F8); // 대체 표면색
  
  // ============ 텍스트 색상 ============
  static const Color textPrimary = Color(0xFF333333); // 짙은 차콜 (제목/주요 텍스트)
  static const Color textSecondary = Color(0xFF666666); // 중간 그레이 (보조 텍스트)
  static const Color textTertiary = Color(0xFF999999); // 밝은 그레이 (비활성 텍스트)
  static const Color textDisabled = Color(0xFFCCCCCC); // 비활성 색상
  
  // ============ 테두리 색상 ============
  static const Color borderLight = Color(0xFFE0E0E0); // 밝은 테두리
  static const Color borderMedium = Color(0xFFBDBDBD); // 중간 테두리
  static const Color borderDark = Color(0xFF9E9E9E); // 어두운 테두리
  
  // ============ 카테고리 색상 (파스텔 톤) ============
  static const Map<String, Color> categoryColors = {
    '학업': Color(0xFF87CEEB), // 스카이블루
    '건강': Color(0xFFA7E6C0), // 민트
    '자기계발': Color(0xFFFFD4A3), // 복숭아색
    '생활': Color(0xFFFCA5A5), // 파스텔 핑크
    '업무': Color(0xFFB4A7D6), // 라벤더
  };
  
  // ============ 난이도 색상 ============
  static const Color easyColor = Color(0xFFA7E6C0); // 파스텔 민트 (쉬움)
  static const Color normalColor = Color(0xFFFFD4A3); // 파스텔 복숭아 (보통)
  static const Color hardColor = Color(0xFFFCA5A5); // 파스텔 핑크 (어려움)
  
  // ============ 상태 색상 ============
  static const Color success = Color(0xFF6BBF8E); // 성공 (초록)
  static const Color statusSuccess = Color(0xFF6BBF8E); // 성공 (초록)
  static const Color warning = Color(0xFFD4A574); // 경고 (갈색)
  static const Color error = Color(0xFFC9726A); // 에러 (붉은색)
  static const Color info = Color(0xFF87CEEB); // 정보 (스카이블루)
  
  // ============ 습관 추적 색상 ============
  static const Color completedHabit = Color(0xFFA7E6C0); // 완료됨 (민트)
  static const Color pendingHabit = Color(0xFFFFD4A3); // 진행중 (복숭아)
  static const Color missedHabit = Color(0xFFF0F0F0); // 미완료 (연한 그레이)
  
  // ============ 진행률 표시 색상 ============
  static const Map<String, Color> progressColors = {
    'tier1': Color(0xFFA7E6C0), // 0-25% - 민트
    'tier2': Color(0xFFFFD4A3), // 25-50% - 복숭아
    'tier3': Color(0xFFB4A7D6), // 50-75% - 라벤더
    'tier4': Color(0xFF87CEEB), // 75-100% - 스카이블루
  };
  
  // ============ 물고기 색상 (파스텔 톤) ============
  static const Map<String, Color> fishColors = {
    'goldfish': Color(0xFFFFD700), // 금붕어
    'bluefish': Color(0xFF87CEEB), // 파란물고기
    'redfish': Color(0xFFFCA5A5), // 빨간물고기
    'greenfish': Color(0xFFA7E6C0), // 초록물고기
  };
  
  // ============ 그라데이션 ============
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF8F9FA), // 맨 위
      Color(0xFFFFFFFF), // 중간
    ],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF), // 순백색
      Color(0xFFFAFBFC), // 매우 밝은 그레이
    ],
  );
  
  static const LinearGradient progressGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF7DD3C0), // 파스텔 민트
      Color(0xFF81E6D9), // 밝은 민트
    ],
  );
  
  // ============ 투명도 유틸리티 ============
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
  
  /// 라이트/다크 모드에 따른 색상 반환
  /// 현재는 라이트 모드만 지원
  static Color adaptive(Color light, Color dark) {
    return light; // 라이트 모드 우선
  }
}
