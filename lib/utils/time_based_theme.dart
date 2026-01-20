import 'package:flutter/material.dart'; // [필수] Color, LinearGradient 사용을 위해 필요

/// 하루 중 시간대 (플러터 기본 TimeOfDay와 충돌 방지를 위해 이름 변경)
enum AquariumTime {
  dawn,      // 새벽 (5-8시)
  morning,   // 아침 (8-12시)
  afternoon, // 오후 (12-17시)
  evening,   // 저녁 (17-20시)
  night;     // 밤 (20-5시)
}

/// 수족관 테마 모델
class AquariumTheme {
  final AquariumTime timeOfDay;
  final Color gradientTop;
  final Color gradientMiddle;
  final Color gradientBottom;
  final double lightIntensity;    // 0-1 (신의 빛)
  final double causticsOpacity;  // 0-1 (물 굴절)

  AquariumTheme({
    required this.timeOfDay,
    required this.gradientTop,
    required this.gradientMiddle,
    required this.gradientBottom,
    required this.lightIntensity,
    required this.causticsOpacity,
  });

  LinearGradient get gradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [gradientTop, gradientMiddle, gradientBottom],
    stops: const [0.0, 0.5, 1.0],
  );
}

/// 현재 시간대에 따른 AquariumTime 반환
AquariumTime getAquariumTime() {
  final hour = DateTime.now().hour;
  if (hour >= 5 && hour < 8) return AquariumTime.dawn;
  if (hour >= 8 && hour < 12) return AquariumTime.morning;
  if (hour >= 12 && hour < 17) return AquariumTime.afternoon;
  if (hour >= 17 && hour < 20) return AquariumTime.evening;
  return AquariumTime.night;
}

/// 시간대에 따른 테마 데이터 가져오기
AquariumTheme getAquariumTheme([AquariumTime? time]) {
  final currentTime = time ?? getAquariumTime();

  switch (currentTime) {
    case AquariumTime.dawn:
      return AquariumTheme(
        timeOfDay: AquariumTime.dawn,
        gradientTop: const Color(0xFFFFB6C1),
        gradientMiddle: const Color(0xFFA2D9FF),
        gradientBottom: const Color(0xFF5DADE2),
        lightIntensity: 0.6,
        causticsOpacity: 0.12,
      );
  // ... 나머지 case들도 AquariumTime.morning 등으로 이름을 맞춰 수정하세요.
    default:
      return AquariumTheme(
        timeOfDay: AquariumTime.night,
        gradientTop: const Color(0xFF2C3E50),
        gradientMiddle: const Color(0xFF1B4F72),
        gradientBottom: const Color(0xFF0B1A2A),
        lightIntensity: 0.2,
        causticsOpacity: 0.05,
      );
  }
}