import 'package:flutter/material.dart';

/// 앱 전역 색상 팔레트 (심해 테마)
class AppColors {
  // 기본 색상
  static const Color primary = Color(0xFF4FC3F7); // 심해 파란색
  static const Color secondary = Color(0xFF81C784); // 물풀 초록색
  static const Color accent = Color(0xFFFFD54F); // 모래 노란색
  
  // 배경 색상
  static const Color background = Color(0xFF0A1929); // 깊은 심해
  static const Color surface = Color(0xFF1A2332); // 카드 배경
  static const Color surfaceLight = Color(0xFF2D3A4D); // 밝은 카드
  
  // 텍스트 색상
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color textDisabled = Color(0xFF607D8B);
  
  // 카테고리 색상
  static const Map<String, Color> category = {
    '학업': Color(0xFF4FC3F7),
    '건강': Color(0xFF81C784),
    '자기계발': Color(0xFFFFB74D),
    '생활': Color(0xFFE57373),
  };
  
  // 난이도 색상
  static const Color easyColor = Color(0xFF81C784);
  static const Color normalColor = Color(0xFFFFD54F);
  static const Color hardColor = Color(0xFFE57373);
  
  // 상태 색상
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // 물고기 색상
  static const Map<String, Color> fishColors = {
    'goldfish': Color(0xFFFFD700),
    'bluefish': Color(0xFF4169E1),
    'redfish': Color(0xFFDC143C),
  };
  
  // 그라데이션
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0A1929), // 어두운 상단
      Color(0xFF1A2F3F), // 중간
      Color(0xFF0D1B2A), // 하단
    ],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A2332),
      Color(0xFF2D3A4D),
    ],
  );
  
  // 투명도
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
}
