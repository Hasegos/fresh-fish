import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 수족관 배경을 그리는 CustomPainter
/// 배경 그라디언트, 산호, 바위, 해초 등 정적 요소를 렌더링
class AquariumPainter extends CustomPainter {
  AquariumPainter();

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawSeaFloor(canvas, size);
    _drawCoral(canvas, size);
    _drawSeaweed(canvas, size);
    _drawRocks(canvas, size);
    _drawShells(canvas, size);
  }

  /// 배경 그라디언트 (위: 밝은 청록색 → 아래: 어두운 청색)
  void _drawBackground(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF4DD0E1), // 밝은 청록색 (수면 근처)
          Color(0xFF26C6DA),
          Color(0xFF00ACC1),
          Color(0xFF0097A7),
          Color(0xFF00838F), // 어두운 청색 (깊은 곳)
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  /// 해저 바닥 (모래)
  void _drawSeaFloor(Canvas canvas, Size size) {
    final path = Path();
    final floorHeight = size.height * 0.15;
    
    // 물결 모양 바닥
    path.moveTo(0, size.height - floorHeight);
    
    for (double x = 0; x <= size.width; x += 20) {
      final y = size.height - floorHeight + 
                math.sin(x / 50) * 8;
      path.lineTo(x, y);
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFD7CCC8), // 밝은 모래색
          Color(0xFFBCAAA4), // 어두운 모래색
        ],
      ).createShader(Rect.fromLTWH(0, size.height - floorHeight, 
                                     size.width, floorHeight));
    
    canvas.drawPath(path, paint);
  }

  /// 산호 그리기
  void _drawCoral(Canvas canvas, Size size) {
    final random = math.Random(42); // 시드 고정으로 일관된 배치
    
    // 왼쪽 산호 그룹
    _drawCoralCluster(
      canvas,
      Offset(size.width * 0.15, size.height * 0.82),
      size.height * 0.12,
      Colors.purple.shade400,
      random,
    );
    
    // 중앙 산호 그룹
    _drawCoralCluster(
      canvas,
      Offset(size.width * 0.5, size.height * 0.85),
      size.height * 0.10,
      Colors.orange.shade400,
      random,
    );
    
    // 오른쪽 산호 그룹
    _drawCoralCluster(
      canvas,
      Offset(size.width * 0.8, size.height * 0.80),
      size.height * 0.14,
      Colors.blue.shade300,
      random,
    );
  }

  /// 산호 클러스터 그리기
  void _drawCoralCluster(Canvas canvas, Offset center, double height, 
                         Color color, math.Random random) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    // 여러 개의 산호 가지
    for (int i = 0; i < 5; i++) {
      final angle = (i / 5) * math.pi - math.pi / 2;
      final branchHeight = height * (0.6 + random.nextDouble() * 0.4);
      final branchWidth = branchHeight * 0.3;
      
      final path = Path();
      path.moveTo(center.dx, center.dy);
      
      // 타원형 산호 가지
      final endX = center.dx + math.cos(angle) * branchWidth;
      final endY = center.dy - branchHeight;
      
      path.quadraticBezierTo(
        center.dx + math.cos(angle) * branchWidth * 0.3,
        center.dy - branchHeight * 0.5,
        endX,
        endY,
      );
      
      // 산호 끝 부분 (둥글게)
      final circleRadius = branchWidth * 0.4;
      canvas.drawCircle(Offset(endX, endY), circleRadius, paint);
      
      // 가지 그리기
      final branchPaint = Paint()
        ..color = color.withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = branchWidth * 0.6
        ..strokeCap = StrokeCap.round;
      
      canvas.drawPath(path, branchPaint);
    }
  }

  /// 해초 그리기
  void _drawSeaweed(Canvas canvas, Size size) {
    final random = math.Random(123);
    
    // 여러 위치에 해초 배치
    final positions = [
      Offset(size.width * 0.1, size.height * 0.88),
      Offset(size.width * 0.3, size.height * 0.85),
      Offset(size.width * 0.65, size.height * 0.87),
      Offset(size.width * 0.9, size.height * 0.84),
    ];
    
    for (final pos in positions) {
      _drawSeaweedStrand(canvas, pos, size.height * 0.15, random);
    }
  }

  /// 해초 가닥 그리기
  void _drawSeaweedStrand(Canvas canvas, Offset base, double height, 
                          math.Random random) {
    final paint = Paint()
      ..color = Color(0xFF66BB6A).withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;
    
    final path = Path();
    path.moveTo(base.dx, base.dy);
    
    // 물결치는 해초
    final segments = 8;
    for (int i = 1; i <= segments; i++) {
      final t = i / segments;
      final x = base.dx + math.sin(t * math.pi * 2) * (height * 0.2);
      final y = base.dy - (height * t);
      path.lineTo(x, y);
    }
    
    canvas.drawPath(path, paint);
  }

  /// 바위 그리기
  void _drawRocks(Canvas canvas, Size size) {
    final rocks = [
      (Offset(size.width * 0.25, size.height * 0.90), size.width * 0.08),
      (Offset(size.width * 0.6, size.height * 0.92), size.width * 0.06),
      (Offset(size.width * 0.85, size.height * 0.91), size.width * 0.07),
    ];
    
    for (final rock in rocks) {
      _drawRock(canvas, rock.$1, rock.$2);
    }
  }

  /// 개별 바위 그리기
  void _drawRock(Canvas canvas, Offset center, double size) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Color(0xFF78909C),
          Color(0xFF546E7A),
          Color(0xFF37474F),
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: size));
    
    // 불규칙한 타원형 바위
    final path = Path();
    final random = math.Random(center.dx.toInt());
    
    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * math.pi;
      final radius = size * (0.8 + random.nextDouble() * 0.4);
      final x = center.dx + math.cos(angle) * radius;
      final y = center.dy + math.sin(angle) * radius * 0.7; // 납작한 형태
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    
    canvas.drawPath(path, paint);
  }

  /// 조개 그리기
  void _drawShells(Canvas canvas, Size size) {
    final shells = [
      Offset(size.width * 0.35, size.height * 0.93),
      Offset(size.width * 0.7, size.height * 0.94),
    ];
    
    for (final pos in shells) {
      _drawShell(canvas, pos, size.width * 0.03);
    }
  }

  /// 개별 조개 그리기
  void _drawShell(Canvas canvas, Offset center, double size) {
    final paint = Paint()
      ..color = Color(0xFFFFAB91)
      ..style = PaintingStyle.fill;
    
    final path = Path();
    
    // 부채꼴 모양 조개
    for (int i = 0; i < 6; i++) {
      final angle = (i / 6) * math.pi - math.pi / 2;
      final radius = size * (1.2 - (i % 2) * 0.2);
      final x = center.dx + math.cos(angle) * radius;
      final y = center.dy + math.sin(angle) * radius;
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    
    canvas.drawPath(path, paint);
    
    // 조개 줄무늬
    final stripePaint = Paint()
      ..color = Color(0xFFFF8A65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    for (int i = 1; i < 5; i++) {
      final arcPath = Path();
      final arcRadius = size * (i / 5);
      arcPath.addArc(
        Rect.fromCircle(center: center, radius: arcRadius),
        -math.pi / 2,
        math.pi,
      );
      canvas.drawPath(arcPath, stripePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
