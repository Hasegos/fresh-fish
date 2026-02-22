import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 떠오르는 거품을 그리는 CustomPainter
/// 애니메이션 값에 따라 위로 이동하며 흔들리는 효과
class BubblePainter extends CustomPainter {
  final double animationValue; // 0.0 ~ 1.0
  final List<Bubble> bubbles;
  
  BubblePainter({
    required this.animationValue,
    required this.bubbles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final bubble in bubbles) {
      _drawBubble(canvas, size, bubble);
    }
  }

  /// 개별 거품 그리기
  void _drawBubble(Canvas canvas, Size size, Bubble bubble) {
    // 애니메이션 진행에 따라 Y 위치 계산 (더 느리게)
    final progress = (animationValue * 0.5 + bubble.offset) % 1.0;
    final y = size.height - (progress * size.height);
    
    // 좌우 흔들림 (더 부드럽게)
    final wobble = math.sin(progress * math.pi * 3 + bubble.seed) * 
                   bubble.radius * 1.5;
    final x = bubble.x * size.width + wobble;
    
    // 거품이 수면에 가까워질수록 투명해짐
    final opacity = progress < 0.85 ? 0.5 : (1.0 - progress) * 3.3;
    
    if (opacity <= 0) return;
    
    // 거품 외곽선
    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity * 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    canvas.drawCircle(Offset(x, y), bubble.radius, paint);
    
    // 거품 하이라이트 (반사광)
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(opacity * 0.8)
      ..style = PaintingStyle.fill;
    
    final highlightOffset = Offset(
      x - bubble.radius * 0.3,
      y - bubble.radius * 0.3,
    );
    
    canvas.drawCircle(
      highlightOffset, 
      bubble.radius * 0.3, 
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(BubblePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

/// 거품 데이터 클래스
class Bubble {
  final double x; // 0.0 ~ 1.0 (화면 너비 비율)
  final double radius; // 거품 반지름
  final double offset; // 애니메이션 오프셋 (0.0 ~ 1.0)
  final double seed; // 랜덤 시드
  
  Bubble({
    required this.x,
    required this.radius,
    required this.offset,
    required this.seed,
  });
}

/// 거품 생성 헬퍼 함수
List<Bubble> generateBubbles(int count) {
  final random = math.Random(456); // 시드 고정
  
  return List.generate(count, (index) {
    return Bubble(
      x: random.nextDouble(),
      radius: 3.0 + random.nextDouble() * 8.0, // 3~11 크기
      offset: random.nextDouble(),
      seed: random.nextDouble() * 1000,
    );
  });
}
