import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../providers/user_data_provider.dart';
import '../../models/user_data_model.dart';
import '../../models/fish_model.dart';
import '../../theme/app_colors.dart';
import '../../widgets/habit_progress_section.dart';
import '../../widgets/pixel_fish.dart';

enum FishRenderStyle {
  pixelArt,   // B) 픽셀 아트
  smooth,     // C) 부드러운 일러스트 (그라디언트)
  minimalist, // C) 미니멀 (이모지)
}

/// 메인 어항 화면 - 새로운 아키텍처
class AquariumScreen extends StatefulWidget {
  final Function(int)? onNavChanged;

  const AquariumScreen({super.key, this.onNavChanged});

  @override
  State<AquariumScreen> createState() => _AquariumScreenState();
}

class _AquariumScreenState extends State<AquariumScreen>
    with TickerProviderStateMixin {
  late AnimationController _positionController;
  late Offset _fishPosition;
  late Offset _targetPosition;
  String? _displayedMessage;
  bool _showMessage = false;
  late FishRenderStyle _renderStyle;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _renderStyle = FishRenderStyle.pixelArt; // B) 기본값: 픽셀 아트
  }

  void _initializeAnimation() {
    _positionController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _fishPosition = const Offset(50, 50);
    _targetPosition = _generateRandomTarget();

    _positionController.addListener(() {
      setState(() {
        _fishPosition = Offset(
          _fishPosition.dx +
              (_targetPosition.dx - _fishPosition.dx) * 0.02,
          _fishPosition.dy +
              (_targetPosition.dy - _fishPosition.dy) * 0.02,
        );
      });
    });

    _positionController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _targetPosition = _generateRandomTarget();
        _positionController.reset();
        _positionController.forward();
      }
    });

    _positionController.forward();
  }

  Offset _generateRandomTarget() {
    final random = Random();
    return Offset(
      random.nextDouble() * 280,
      random.nextDouble() * 220,
    );
  }

  void _onFishTapped() {
    final hour = DateTime.now().hour;
    String message;

    if (hour < 12) {
      message = "Fresh start! Let's do this!";
    } else if (hour >= 18) {
      message = "You've done well. Rest up for tomorrow.";
    } else {
      // Check progress
      // For now, using random threshold
      final isGoodProgress = Random().nextBool();
      message = isGoodProgress
          ? "You're doing amazing!"
          : "Need a little boost?";
    }

    setState(() {
      _displayedMessage = message;
      _showMessage = true;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showMessage = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _positionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<UserDataProvider>(
        builder: (context, provider, child) {
          final userData = provider.userData;

          if (userData == null) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryPastel,
              ),
            );
          }

          return Stack(
            children: [
              Column(
                children: [
                  // Top 60% - Aquarium Section
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.60,
                    child: _buildAquariumSection(context, userData),
                  ),

                  // Bottom 40% - Task List Section
                  Expanded(
                    child: _buildMissionArea(context, userData),
                  ),
                ],
              ),

            ],
          );
        },
      ),
    );
  }

  Widget _buildAquariumSection(BuildContext context, UserData userData) {
    final fish = userData.fish;
    
    // 오늘 완료된 미션 수 계산
    final todayQuests = userData.quests
        .where((quest) => quest.date == userData.currentDate)
        .toList();
    final completedCount = todayQuests.where((q) => q.completed).length;
    final shouldShowFish = completedCount >= 4;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFE0F2F1), // Soft Mint
            const Color(0xFFE3F2FD), // Sky Blue
          ],
        ),
      ),
      child: Stack(
        children: [
          // HUD (Top-Left)
          Positioned(
            top: 16,
            left: 16,
            child: _buildHUD(context, fish, userData.gold),
          ),

          // Render Style Toggle (Top-Right) - B & C Options
          Positioned(
            top: 16,
            right: 16,
            child: _buildRenderStyleToggle(),
          ),

          // Aquarium with animated fish
          Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final aquariumWidth = (constraints.maxWidth - 24).clamp(340.0, 420.0);
                final aquariumHeight = (constraints.maxHeight - 28).clamp(280.0, 360.0);

                return GestureDetector(
                  onTap: shouldShowFish ? _onFishTapped : null,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: aquariumWidth,
                        height: aquariumHeight,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: AppColors.primaryPastel.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: SizedBox.expand(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            switchInCurve: Curves.easeOutBack,
                            switchOutCurve: Curves.easeIn,
                            transitionBuilder: (child, animation) {
                              final scale = Tween<double>(begin: 0.9, end: 1.0).animate(animation);
                              return FadeTransition(
                                opacity: animation,
                                child: ScaleTransition(scale: scale, child: child),
                              );
                            },
                            child: shouldShowFish
                                ? _buildHatchedFish(fish)
                                : _buildEggPlaceholder(completedCount),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEggPlaceholder(int completedCount) {
    final crackLevel = completedCount.clamp(0, 3);

    return Center(
      key: const ValueKey<String>('egg'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 96,
            height: 96,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Text(
                  '🥚',
                  style: TextStyle(fontSize: 74),
                ),
                if (crackLevel > 0)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _EggCrackPainter(crackLevel: crackLevel),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '미션 4개를 완료하면\n알이 부화합니다',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textTertiary.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$completedCount / 4',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary.withOpacity(0.7),
            ),
          ),
          if (crackLevel > 0) ...[
            const SizedBox(height: 6),
            Text(
              '실금 단계 $crackLevel',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary.withOpacity(0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHatchedFish(Fish fish) {
    return SizedBox.expand(
      key: const ValueKey<String>('fish'),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 100),
            left: _fishPosition.dx,
            top: _fishPosition.dy,
            child: GestureDetector(
              onTap: _onFishTapped,
              child: _buildFishByStyle(fish),
            ),
          ),
          if (_showMessage)
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: _buildSpeechBubble(_displayedMessage ?? ''),
            ),
        ],
      ),
    );
  }

  Widget _buildFishByStyle(Fish fish) {
    switch (_renderStyle) {
      case FishRenderStyle.pixelArt:
        return PixelFish(
          fishType: fish.type,
          growthStage: GrowthStage.adult,
          size: 80,
          level: fish.level,
        );
      case FishRenderStyle.smooth:
        return _buildSmoothFish(fish);
      case FishRenderStyle.minimalist:
        return _buildMinimalistFish(fish);
    }
  }

  Widget _buildSmoothFish(Fish fish) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Color(int.parse('0xFF${fish.type.colorHex.replaceFirst('#', '')}')),
            Color(int.parse('0xFF${fish.type.colorHex.replaceFirst('#', '')}')).withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(int.parse('0xFF${fish.type.colorHex.replaceFirst('#', '')}')).withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Center(
        child: Text(
          fish.type.emoji,
          style: const TextStyle(fontSize: 56),
        ),
      ),
    );
  }

  Widget _buildMinimalistFish(Fish fish) {
    return Center(
      child: Text(
        fish.type.emoji,
        style: const TextStyle(fontSize: 72),
      ),
    );
  }

  void switchRenderStyle(FishRenderStyle style) {
    setState(() {
      _renderStyle = style;
    });
  }

  Widget _buildRenderStyleToggle() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryPastel.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '스타일',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textTertiary.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStyleButton(
                'B',
                FishRenderStyle.pixelArt,
                '픽셀',
              ),
              const SizedBox(width: 4),
              _buildStyleButton(
                'C1',
                FishRenderStyle.smooth,
                '그라디언트',
              ),
              const SizedBox(width: 4),
              _buildStyleButton(
                'C2',
                FishRenderStyle.minimalist,
                '심플',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStyleButton(
    String label,
    FishRenderStyle style,
    String tooltip,
  ) {
    final isActive = _renderStyle == style;
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: () => switchRenderStyle(style),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primaryPastel.withOpacity(0.8)
                : Colors.grey[300],
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isActive
                  ? AppColors.primaryPastel
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : Colors.grey[600],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHUD(BuildContext context, Fish fish, int gold) {
    final progress = (fish.exp / 100).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            fish.type.emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 90,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lv.${fish.level}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: AppColors.surfaceAlt,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primaryPastel,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('💰', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  gold.toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeechBubble(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryPastel,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildMissionArea(BuildContext context, UserData userData) {
    final todayQuests = userData.quests
        .where((quest) => quest.date == userData.currentDate)
        .toList();

    return Container(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: HabitProgressSection(
          todayQuests: todayQuests,
          todos: userData.todos,
          onQuestToggle: (questId) =>
              context.read<UserDataProvider>().completeQuestById(questId),
          onDailyQuestTap: () => widget.onNavChanged?.call(1),
        ),
      ),
    );
  }
}

class _EggCrackPainter extends CustomPainter {
  final int crackLevel;

  _EggCrackPainter({required this.crackLevel});

  @override
  void paint(Canvas canvas, Size size) {
    final crackPaint = Paint()
      ..color = const Color(0xFF8D6E63).withOpacity(0.8)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final mainCrack = Path()
      ..moveTo(size.width * 0.48, size.height * 0.22)
      ..lineTo(size.width * 0.44, size.height * 0.36)
      ..lineTo(size.width * 0.52, size.height * 0.48)
      ..lineTo(size.width * 0.46, size.height * 0.62)
      ..lineTo(size.width * 0.54, size.height * 0.76);
    canvas.drawPath(mainCrack, crackPaint);

    if (crackLevel >= 2) {
      final sideCrackLeft = Path()
        ..moveTo(size.width * 0.35, size.height * 0.44)
        ..lineTo(size.width * 0.28, size.height * 0.52)
        ..lineTo(size.width * 0.34, size.height * 0.60);

      final sideCrackRight = Path()
        ..moveTo(size.width * 0.62, size.height * 0.50)
        ..lineTo(size.width * 0.70, size.height * 0.56)
        ..lineTo(size.width * 0.64, size.height * 0.66);

      canvas.drawPath(sideCrackLeft, crackPaint);
      canvas.drawPath(sideCrackRight, crackPaint);
    }

    if (crackLevel >= 3) {
      final topCrack = Path()
        ..moveTo(size.width * 0.50, size.height * 0.16)
        ..lineTo(size.width * 0.57, size.height * 0.26)
        ..lineTo(size.width * 0.50, size.height * 0.34)
        ..lineTo(size.width * 0.58, size.height * 0.42);

      final bottomCrack = Path()
        ..moveTo(size.width * 0.46, size.height * 0.68)
        ..lineTo(size.width * 0.38, size.height * 0.76)
        ..lineTo(size.width * 0.46, size.height * 0.84);

      canvas.drawPath(topCrack, crackPaint);
      canvas.drawPath(bottomCrack, crackPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _EggCrackPainter oldDelegate) {
    return oldDelegate.crackLevel != crackLevel;
  }
}
