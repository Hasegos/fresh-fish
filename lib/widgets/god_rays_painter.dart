import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 수면에서 내려오는 빛 광선(God Rays) 효과를 그리는 CustomPainter
/// 애니메이션 값에 따라 움직이고 깜빡이는 효과
class GodRaysPainter extends CustomPainter {
  final double animationValue; // 0.0 ~ 1.0
  
  GodRaysPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final rayCount = 5;
    
    for (int i = 0; i < rayCount; i++) {
      _drawRay(canvas, size, i, rayCount);
    }
  }

  /// 개별 빛 광선 그리기
  void _drawRay(Canvas canvas, Size size, int index, int total) {
    final path = Path();
    
    // 광선 시작 위치 (수면)
    final startX = (index / total) * size.width + 
                   (size.width / total) * 0.5;
    
    // 애니메이션에 따라 위치 약간 이동 (더 느리고 부드럽게)
    final offset = math.sin(animationValue * math.pi + index) * 15;
    final adjustedStartX = startX + offset;
    
    // 광선의 폭
    final topWidth = size.width * 0.08;
    final bottomWidth = size.width * 0.15;
    
    // 광선 경로 (사다리꼴 형태)
    path.moveTo(adjustedStartX - topWidth / 2, 0);
    path.lineTo(adjustedStartX + topWidth / 2, 0);
    path.lineTo(
      adjustedStartX + bottomWidth / 2 + offset * 0.3,
      size.height * 0.65,
    );
    path.lineTo(
      adjustedStartX - bottomWidth / 2 + offset * 0.3,
      size.height * 0.65,
    );
    path.close();
    
    // 애니메이션에 따라 투명도 변화 (더 미묘하게)
    final opacity = 0.08 + 
                    math.sin(animationValue * math.pi + index * 0.3) * 0.03;
    
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withOpacity(opacity * 0.9),
          Colors.white.withOpacity(opacity * 0.4),
          Colors.transparent,
        ],
        stops: [0.0, 0.4, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.65));
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(GodRaysPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
