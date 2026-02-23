import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/level_utils.dart';

/// 픽셀 아트 스타일의 물고기 위젯
class PixelFish extends StatelessWidget {
  final FishType fishType;
  final GrowthStage growthStage;
  final double size;
  final int? level; // 레벨 기반 진화 렌더링용

  const PixelFish({
    Key? key,
    required this.fishType,
    required this.growthStage,
    this.size = 64,
    this.level,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 물고기 타입별 색상 스키마
    final colors = _getFishColors(fishType);

    // 레벨이 제공되면 진화 단계 기반, 아니면 성장 단계 기반
    final evolutionStage = level != null
        ? getEvolutionStage(level!)
        : (growthStage == GrowthStage.egg
            ? EvolutionStage.egg
            : growthStage == GrowthStage.juvenile
                ? EvolutionStage.small
                : EvolutionStage.adult);

    // 진화 단계별 크기 배율
    final scaleMap = {
      EvolutionStage.egg: 0.6,
      EvolutionStage.small: 0.8,
      EvolutionStage.adult: 1.0,
      EvolutionStage.legendary: 1.3,
    };

    final scale = scaleMap[evolutionStage] ?? 1.0;
    final actualSize = size * scale;

    // 단계별 렌더링
    switch (evolutionStage) {
      case EvolutionStage.egg:
        return _buildEgg(colors, actualSize);
      case EvolutionStage.small:
        return _buildSmallFish(colors, actualSize);
      case EvolutionStage.legendary:
        return _buildLegendaryFish(colors, actualSize, fishType);
      default:
        return _buildAdultFish(colors, actualSize);
    }
  }

  Map<String, Color> _getFishColors(FishType type) {
    switch (type) {
      case FishType.goldfish:
        return {
          'primary': const Color(0xFFFFD700),
          'secondary': const Color(0xFFFFA500),
          'accent': const Color(0xFFFFEC8B),
        };
      case FishType.bluefish:
        return {
          'primary': const Color(0xFF4169E1),
          'secondary': const Color(0xFF1E90FF),
          'accent': const Color(0xFF87CEEB),
        };
      case FishType.redfish:
        return {
          'primary': const Color(0xFFDC143C),
          'secondary': const Color(0xFFFF6347),
          'accent': const Color(0xFFFFB6C1),
        };
      default:
        return {
          'primary': const Color(0xFFFFD700),
          'secondary': const Color(0xFFFFA500),
          'accent': const Color(0xFFFFEC8B),
        };
    }
  }

  Widget _buildEgg(Map<String, Color> colors, double size) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _EggPainter(colors),
        size: Size(size, size),
      ),
    );
  }

  Widget _buildSmallFish(Map<String, Color> colors, double size) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SmallFishPainter(colors),
        size: Size(size, size),
      ),
    );
  }

  Widget _buildAdultFish(Map<String, Color> colors, double size) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _AdultFishPainter(colors),
        size: Size(size, size),
      ),
    );
  }

  Widget _buildLegendaryFish(
      Map<String, Color> colors, double size, FishType type) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _LegendaryFishPainter(colors, type),
        size: Size(size, size),
      ),
    );
  }
}

// 알 페인터
class _EggPainter extends CustomPainter {
  final Map<String, Color> colors;

  _EggPainter(this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final scale = size.width / 32;

    // 알 기본
    paint.color = colors['primary']!;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(16 * scale, 18 * scale),
        width: 24 * scale,
        height: 28 * scale,
      ),
      paint,
    );

    // 알 내부
    paint.color = colors['secondary']!;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(16 * scale, 18 * scale),
        width: 20 * scale,
        height: 24 * scale,
      ),
      paint,
    );

    // 반점들
    paint.color = colors['accent']!.withOpacity(0.6);
    canvas.drawCircle(Offset(12 * scale, 15 * scale), 2 * scale, paint);
    canvas.drawCircle(Offset(18 * scale, 20 * scale), 2.5 * scale, paint);
    canvas.drawCircle(Offset(14 * scale, 22 * scale), 1.5 * scale, paint);

    // 반짝임
    paint.color = Colors.white.withOpacity(0.5);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(18 * scale, 12 * scale),
        width: 6 * scale,
        height: 8 * scale,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 작은 물고기 페인터
class _SmallFishPainter extends CustomPainter {
  final Map<String, Color> colors;

  _SmallFishPainter(this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final scale = size.width / 32;

    // 몸통
    paint.color = colors['primary']!;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(16 * scale, 16 * scale),
        width: 16 * scale,
        height: 12 * scale,
      ),
      paint,
    );

    paint.color = colors['secondary']!;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(16 * scale, 16 * scale),
        width: 12 * scale,
        height: 8 * scale,
      ),
      paint,
    );

    // 꼬리
    final tailPath = Path()
      ..moveTo(8 * scale, 16 * scale)
      ..lineTo(2 * scale, 14 * scale)
      ..lineTo(4 * scale, 16 * scale)
      ..lineTo(2 * scale, 18 * scale)
      ..close();
    paint.color = colors['primary']!;
    canvas.drawPath(tailPath, paint);

    // 위 지느러미
    final topFinPath = Path()
      ..moveTo(16 * scale, 10 * scale)
      ..lineTo(14 * scale, 6 * scale)
      ..lineTo(16 * scale, 8 * scale)
      ..lineTo(18 * scale, 6 * scale)
      ..close();
    paint.color = colors['accent']!;
    canvas.drawPath(topFinPath, paint);

    // 눈
    paint.color = Colors.white;
    canvas.drawCircle(Offset(20 * scale, 15 * scale), 2 * scale, paint);
    paint.color = Colors.black;
    canvas.drawCircle(Offset(21 * scale, 15 * scale), 1 * scale, paint);

    // 입
    paint.color = colors['secondary']!;
    canvas.drawCircle(Offset(23 * scale, 17 * scale), 0.5 * scale, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 성체 물고기 페인터
class _AdultFishPainter extends CustomPainter {
  final Map<String, Color> colors;

  _AdultFishPainter(this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final scale = size.width / 32;

    // 몸통
    paint.color = colors['primary']!;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(18 * scale, 16 * scale),
        width: 20 * scale,
        height: 14 * scale,
      ),
      paint,
    );

    paint.color = colors['secondary']!;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(18 * scale, 16 * scale),
        width: 16 * scale,
        height: 10 * scale,
      ),
      paint,
    );

    // 꼬리
    final tailPath = Path()
      ..moveTo(8 * scale, 16 * scale)
      ..lineTo(2 * scale, 12 * scale)
      ..lineTo(4 * scale, 16 * scale)
      ..lineTo(2 * scale, 20 * scale)
      ..close();
    paint.color = colors['primary']!;
    canvas.drawPath(tailPath, paint);

    final tailAccentPath = Path()
      ..moveTo(8 * scale, 16 * scale)
      ..lineTo(3 * scale, 13 * scale)
      ..lineTo(5 * scale, 16 * scale)
      ..lineTo(3 * scale, 19 * scale)
      ..close();
    paint.color = colors['accent']!;
    canvas.drawPath(tailAccentPath, paint);

    // 위 지느러미
    final topFinPath = Path()
      ..moveTo(18 * scale, 9 * scale)
      ..lineTo(16 * scale, 4 * scale)
      ..lineTo(18 * scale, 7 * scale)
      ..lineTo(20 * scale, 4 * scale)
      ..close();
    paint.color = colors['accent']!;
    canvas.drawPath(topFinPath, paint);

    // 아래 지느러미
    final bottomFinPath = Path()
      ..moveTo(16 * scale, 21 * scale)
      ..lineTo(14 * scale, 25 * scale)
      ..lineTo(16 * scale, 23 * scale)
      ..lineTo(18 * scale, 25 * scale)
      ..close();
    paint.color = colors['accent']!.withOpacity(0.8);
    canvas.drawPath(bottomFinPath, paint);

    // 옆 지느러미
    final sideFinPath = Path()
      ..moveTo(20 * scale, 18 * scale)
      ..lineTo(22 * scale, 22 * scale)
      ..lineTo(21 * scale, 19 * scale)
      ..close();
    paint.color = colors['accent']!.withOpacity(0.6);
    canvas.drawPath(sideFinPath, paint);

    // 눈
    paint.color = Colors.white;
    canvas.drawCircle(Offset(24 * scale, 14 * scale), 2.5 * scale, paint);
    paint.color = Colors.black;
    canvas.drawCircle(Offset(25 * scale, 14 * scale), 1.5 * scale, paint);
    paint.color = Colors.white;
    canvas.drawCircle(Offset(25.5 * scale, 13.5 * scale), 0.5 * scale, paint);

    // 입
    final mouthPath = Path()
      ..moveTo(28 * scale, 16 * scale)
      ..quadraticBezierTo(27 * scale, 17 * scale, 26 * scale, 17 * scale);
    paint.color = colors['secondary']!;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 0.5 * scale;
    canvas.drawPath(mouthPath, paint);

    // 비늘 패턴
    paint.style = PaintingStyle.fill;
    paint.color = colors['accent']!.withOpacity(0.3);
    canvas.drawCircle(Offset(16 * scale, 14 * scale), 1.5 * scale, paint);
    canvas.drawCircle(Offset(19 * scale, 15 * scale), 1.5 * scale, paint);
    canvas.drawCircle(Offset(16 * scale, 17 * scale), 1.5 * scale, paint);
    canvas.drawCircle(Offset(19 * scale, 18 * scale), 1.5 * scale, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 전설의 물고기 페인터
class _LegendaryFishPainter extends CustomPainter {
  final Map<String, Color> colors;
  final FishType fishType;

  _LegendaryFishPainter(this.colors, this.fishType);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final scale = size.width / 32;

    // 글로우 효과
    final glowGradient = RadialGradient(
      colors: [
        colors['primary']!.withOpacity(0.8),
        colors['accent']!.withOpacity(0.0),
      ],
    );
    paint.shader = glowGradient.createShader(
      Rect.fromCircle(
        center: Offset(18 * scale, 16 * scale),
        radius: 14 * scale,
      ),
    );
    canvas.drawCircle(
      Offset(18 * scale, 16 * scale),
      14 * scale,
      paint,
    );

    paint.shader = null;

    // 몸통 - 더 크고 웅장하게
    paint.color = colors['primary']!;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(18 * scale, 16 * scale),
        width: 24 * scale,
        height: 16 * scale,
      ),
      paint,
    );

    paint.color = colors['secondary']!;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(18 * scale, 16 * scale),
        width: 20 * scale,
        height: 12 * scale,
      ),
      paint,
    );

    // 꼬리 - 더 크고 흐르는 듯한
    final tailPath = Path()
      ..moveTo(6 * scale, 16 * scale)
      ..lineTo(0, 10 * scale)
      ..lineTo(2 * scale, 16 * scale)
      ..lineTo(0, 22 * scale)
      ..close();
    paint.color = colors['primary']!;
    canvas.drawPath(tailPath, paint);

    final tailAccentPath = Path()
      ..moveTo(6 * scale, 16 * scale)
      ..lineTo(1 * scale, 11 * scale)
      ..lineTo(3 * scale, 16 * scale)
      ..lineTo(1 * scale, 21 * scale)
      ..close();
    paint.color = colors['accent']!;
    canvas.drawPath(tailAccentPath, paint);

    // 위 지느러미 - 강화됨
    final topFinPath = Path()
      ..moveTo(18 * scale, 8 * scale)
      ..lineTo(16 * scale, 2 * scale)
      ..lineTo(18 * scale, 5 * scale)
      ..lineTo(20 * scale, 2 * scale)
      ..close();
    paint.color = colors['accent']!;
    canvas.drawPath(topFinPath, paint);

    final topFin2Path = Path()
      ..moveTo(22 * scale, 10 * scale)
      ..lineTo(21 * scale, 6 * scale)
      ..lineTo(22 * scale, 8 * scale)
      ..lineTo(23 * scale, 6 * scale)
      ..close();
    paint.color = colors['accent']!.withOpacity(0.7);
    canvas.drawPath(topFin2Path, paint);

    // 아래 지느러미
    final bottomFinPath = Path()
      ..moveTo(16 * scale, 22 * scale)
      ..lineTo(14 * scale, 27 * scale)
      ..lineTo(16 * scale, 24 * scale)
      ..lineTo(18 * scale, 27 * scale)
      ..close();
    paint.color = colors['accent']!.withOpacity(0.8);
    canvas.drawPath(bottomFinPath, paint);

    // 옆 지느러미들
    final sideFin1Path = Path()
      ..moveTo(20 * scale, 19 * scale)
      ..lineTo(24 * scale, 24 * scale)
      ..lineTo(22 * scale, 20 * scale)
      ..close();
    paint.color = colors['accent']!.withOpacity(0.6);
    canvas.drawPath(sideFin1Path, paint);

    final sideFin2Path = Path()
      ..moveTo(14 * scale, 13 * scale)
      ..lineTo(10 * scale, 10 * scale)
      ..lineTo(13 * scale, 13 * scale)
      ..close();
    paint.color = colors['accent']!.withOpacity(0.6);
    canvas.drawPath(sideFin2Path, paint);

    // 눈 - 더 크게
    paint.color = Colors.white;
    canvas.drawCircle(Offset(25 * scale, 14 * scale), 3 * scale, paint);
    paint.color = Colors.black;
    canvas.drawCircle(Offset(26 * scale, 14 * scale), 2 * scale, paint);
    paint.color = Colors.white;
    canvas.drawCircle(Offset(26.5 * scale, 13 * scale), 0.8 * scale, paint);

    // 입
    final mouthPath = Path()
      ..moveTo(29 * scale, 17 * scale)
      ..quadraticBezierTo(28 * scale, 18 * scale, 27 * scale, 18 * scale);
    paint.color = colors['secondary']!;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 0.8 * scale;
    canvas.drawPath(mouthPath, paint);

    // 강화된 비늘 패턴
    paint.style = PaintingStyle.fill;
    paint.color = colors['accent']!.withOpacity(0.4);
    canvas.drawCircle(Offset(14 * scale, 13 * scale), 2 * scale, paint);
    canvas.drawCircle(Offset(18 * scale, 14 * scale), 2 * scale, paint);
    canvas.drawCircle(Offset(22 * scale, 15 * scale), 2 * scale, paint);
    canvas.drawCircle(Offset(14 * scale, 17 * scale), 2 * scale, paint);
    canvas.drawCircle(Offset(18 * scale, 18 * scale), 2 * scale, paint);
    canvas.drawCircle(Offset(22 * scale, 19 * scale), 2 * scale, paint);

    // 왕관 - 전설의 표시
    final crownPath = Path()
      ..moveTo(14 * scale, 8 * scale)
      ..lineTo(15 * scale, 5 * scale)
      ..lineTo(16 * scale, 7 * scale)
      ..lineTo(17 * scale, 5 * scale)
      ..lineTo(18 * scale, 7 * scale)
      ..lineTo(19 * scale, 5 * scale)
      ..lineTo(20 * scale, 8 * scale);
    paint.color = const Color(0xFFFFD700);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1 * scale;
    canvas.drawPath(crownPath, paint);

    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(15 * scale, 5 * scale), 0.8 * scale, paint);
    canvas.drawCircle(Offset(17 * scale, 5 * scale), 0.8 * scale, paint);
    canvas.drawCircle(Offset(19 * scale, 5 * scale), 0.8 * scale, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
