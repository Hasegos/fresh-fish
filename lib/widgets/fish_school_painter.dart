import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 물고기 떼를 그리는 CustomPainter
/// 애니메이션 값에 따라 물고기들이 함께 이동
class FishSchoolPainter extends CustomPainter {
  final double animationValue; // 0.0 ~ 1.0
  final List<FishSchool> schools;
  
  FishSchoolPainter({
    required this.animationValue,
    required this.schools,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final school in schools) {
      _drawSchool(canvas, size, school);
    }
  }

  /// 물고기 떼 그리기
  void _drawSchool(Canvas canvas, Size size, FishSchool school) {
    for (int i = 0; i < school.fishCount; i++) {
      _drawFish(canvas, size, school, i);
    }
  }

  /// 개별 물고기 그리기
  void _drawFish(Canvas canvas, Size size, FishSchool school, int index) {
    final random = math.Random(school.seed + index);
    
    // 물고기 떼의 기본 위치
    final progress = (animationValue * school.speed + school.offset) % 1.0;
    final baseX = progress * size.width;
    final baseY = school.y * size.height;
    
    // 개별 물고기의 오프셋 (떼 내에서의 위치)
    final offsetX = (random.nextDouble() - 0.5) * school.spread;
    final offsetY = (random.nextDouble() - 0.5) * school.spread * 0.5;
    
    // 물고기 크기
    final fishLength = school.size * (0.8 + random.nextDouble() * 0.4);
    final fishHeight = fishLength * 0.6;
    
    final x = baseX + offsetX;
    final y = baseY + offsetY + 
              math.sin(animationValue * 4 + index) * fishHeight * 0.3;
    
    // 화면 밖으로 나간 경우 스킵
    if (x < -fishLength || x > size.width + fishLength) return;
    
    // 물고기 그리기
    final path = Path();
    
    // 몸통 (타원형)
    final bodyRect = Rect.fromCenter(
      center: Offset(x, y),
      width: fishLength,
      height: fishHeight,
    );
    path.addOval(bodyRect);
    
    // 물고기 색상
    final fishPaint = Paint()
      ..color = school.color
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(path, fishPaint);
    
    // 꼬리 지느러미
    final tailPath = Path();
    final tailX = school.direction > 0 ? x - fishLength * 0.5 : x + fishLength * 0.5;
    
    tailPath.moveTo(tailX, y);
    tailPath.lineTo(
      tailX + (school.direction > 0 ? -1 : 1) * fishLength * 0.4,
      y - fishHeight * 0.4,
    );
    tailPath.lineTo(
      tailX + (school.direction > 0 ? -1 : 1) * fishLength * 0.4,
      y + fishHeight * 0.4,
    );
    tailPath.close();
    
    final tailPaint = Paint()
      ..color = school.color.withOpacity(0.8)
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(tailPath, tailPaint);
    
    // 눈
    final eyeX = school.direction > 0 ? x + fishLength * 0.25 : x - fishLength * 0.25;
    final eyePaint = Paint()
      ..color = Colors.black.withOpacity(0.8)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(eyeX, y - fishHeight * 0.15),
      fishHeight * 0.12,
      eyePaint,
    );
  }

  @override
  bool shouldRepaint(FishSchoolPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

/// 물고기 떼 데이터 클래스
class FishSchool {
  final double y; // 0.0 ~ 1.0 (화면 높이 비율)
  final double speed; // 이동 속도 배율
  final double offset; // 애니메이션 시작 오프셋
  final double spread; // 떼의 퍼짐 정도
  final double size; // 물고기 크기
  final int fishCount; // 물고기 수
  final Color color; // 물고기 색상
  final int seed; // 랜덤 시드
  final int direction; // 1 (오른쪽) 또는 -1 (왼쪽)
  
  FishSchool({
    required this.y,
    required this.speed,
    required this.offset,
    required this.spread,
    required this.size,
    required this.fishCount,
    required this.color,
    required this.seed,
    required this.direction,
  });
}

/// 물고기 떼 생성 헬퍼 함수
List<FishSchool> generateFishSchools() {
  return [
    // 빨간 물고기 떼 (위쪽, 왼쪽으로 이동)
    FishSchool(
      y: 0.25,
      speed: 0.3,
      offset: 0.0,
      spread: 80.0,
      size: 20.0,
      fishCount: 12,
      color: Color(0xFFE57373), // 밝은 빨강
      seed: 100,
      direction: -1,
    ),
    
    // 흰색 물고기 떼 (중간, 오른쪽으로 이동)
    FishSchool(
      y: 0.4,
      speed: 0.25,
      offset: 0.3,
      spread: 100.0,
      size: 18.0,
      fishCount: 15,
      color: Color(0xFFFFFFFF).withOpacity(0.9), // 흰색
      seed: 200,
      direction: 1,
    ),
    
    // 주황 물고기 떼 (아래쪽, 왼쪽으로 이동)
    FishSchool(
      y: 0.6,
      speed: 0.35,
      offset: 0.6,
      spread: 70.0,
      size: 16.0,
      fishCount: 10,
      color: Color(0xFFFF8A65), // 주황
      seed: 300,
      direction: -1,
    ),
  ];
}
