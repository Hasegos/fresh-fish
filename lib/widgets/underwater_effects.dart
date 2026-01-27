import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/time_based_theme.dart';

/// 수중 효과 위젯 (물 굴절, 신의 빛, 거품 등)
class UnderwaterEffects extends StatefulWidget {
  final AquariumTheme theme;

  const UnderwaterEffects({
    Key? key,
    required this.theme,
  }) : super(key: key);

  @override
  State<UnderwaterEffects> createState() => _UnderwaterEffectsState();
}

class _UnderwaterEffectsState extends State<UnderwaterEffects>
    with SingleTickerProviderStateMixin {
  late AnimationController _causticsController;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _causticsController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _causticsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 물 굴절 레이어 (Caustics)
        _buildCausticsLayer(),

        // 신의 빛 (God Rays)
        if (widget.theme.lightIntensity > 0.3) _buildGodRays(),

        // 배경 거품
        _buildBubbles(count: 8, isLarge: false),

        // 전경 거품 (더 빠름)
        _buildBubbles(count: 4, isLarge: true),
      ],
    );
  }

  Widget _buildCausticsLayer() {
    return AnimatedBuilder(
      animation: _causticsController,
      builder: (context, child) {
        return CustomPaint(
          painter: _CausticsPainter(
            offset: _causticsController.value * 100,
            opacity: widget.theme.causticsOpacity,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildGodRays() {
    return Stack(
      children: List.generate(5, (i) {
        return Positioned(
          left: (10 + i * 20) * MediaQuery.of(context).size.width / 100,
          top: 0,
          bottom: 0,
          child: CustomPaint(
            painter: _GodRayPainter(
              opacity: widget.theme.lightIntensity * 0.3,
              delay: i * 0.5,
            ),
            size: Size(
              50,
              MediaQuery.of(context).size.height,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBubbles({required int count, required bool isLarge}) {
    return Stack(
      children: List.generate(count, (i) {
        final delay = _random.nextDouble() * (isLarge ? 3 : 5);
        final duration = (isLarge ? 5 : 8) + _random.nextDouble() * (isLarge ? 2 : 4);
        final left = _random.nextDouble() * 100;

        return Positioned(
          left: left * MediaQuery.of(context).size.width / 100,
          bottom: 0,
          child: _BubbleWidget(
            delay: delay,
            duration: duration,
            isLarge: isLarge,
          ),
        );
      }),
    );
  }
}

// 물 굴절 페인터
class _CausticsPainter extends CustomPainter {
  final double offset;
  final double opacity;

  _CausticsPainter({
    required this.offset,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity * 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // 파도 모양의 굴절선
    final path1 = Path();
    for (double x = -offset; x < size.width + 200; x += 200) {
      path1.moveTo(x, size.height * 0.25);
      path1.quadraticBezierTo(
        x + 50,
        size.height * 0.15,
        x + 100,
        size.height * 0.25,
      );
      path1.quadraticBezierTo(
        x + 150,
        size.height * 0.35,
        x + 200,
        size.height * 0.25,
      );
    }
    canvas.drawPath(path1, paint);

    paint.strokeWidth = 1.5;
    paint.color = Colors.white.withOpacity(opacity * 0.6);
    final path2 = Path();
    for (double x = -offset; x < size.width + 200; x += 200) {
      path2.moveTo(x, size.height * 0.5);
      path2.quadraticBezierTo(
        x + 50,
        size.height * 0.4,
        x + 100,
        size.height * 0.5,
      );
      path2.quadraticBezierTo(
        x + 150,
        size.height * 0.6,
        x + 200,
        size.height * 0.5,
      );
    }
    canvas.drawPath(path2, paint);

    // 수직 굴절선
    paint.color = Colors.white.withOpacity(opacity * 0.7);
    final path3 = Path();
    for (double y = -offset; y < size.height + 200; y += 200) {
      path3.moveTo(size.width * 0.25, y);
      path3.quadraticBezierTo(
        size.width * 0.35,
        y + 50,
        size.width * 0.25,
        y + 100,
      );
      path3.quadraticBezierTo(
        size.width * 0.15,
        y + 150,
        size.width * 0.25,
        y + 200,
      );
    }
    canvas.drawPath(path3, paint);

    // 타원형 굴절 패턴
    paint.color = Colors.white.withOpacity(opacity * 0.5);
    paint.style = PaintingStyle.stroke;
    for (double x = -offset; x < size.width + 200; x += 200) {
      for (double y = -offset; y < size.height + 200; y += 200) {
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(x + 100, y + 100),
            width: 60,
            height: 80,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// 신의 빛 페인터
class _GodRayPainter extends CustomPainter {
  final double opacity;
  final double delay;

  _GodRayPainter({
    required this.opacity,
    required this.delay,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withOpacity(opacity),
          Colors.white.withOpacity(0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width * 0.3, size.height)
      ..lineTo(size.width * 0.7, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 거품 위젯
class _BubbleWidget extends StatefulWidget {
  final double delay;
  final double duration;
  final bool isLarge;

  const _BubbleWidget({
    required this.delay,
    required this.duration,
    required this.isLarge,
  });

  @override
  State<_BubbleWidget> createState() => _BubbleWidgetState();
}

class _BubbleWidgetState extends State<_BubbleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: (widget.duration * 1000).round()),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    Future.delayed(Duration(milliseconds: (widget.delay * 1000).round()), () {
      if (mounted) {
        _controller.repeat();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.isLarge ? 12.0 : 6.0;
    final screenHeight = MediaQuery.of(context).size.height;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final y = _animation.value * screenHeight;
        final opacity = 1 - _animation.value;

        return Positioned(
          bottom: y,
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.3),
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 1,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
