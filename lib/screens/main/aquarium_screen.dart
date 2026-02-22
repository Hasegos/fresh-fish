import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_data_provider.dart';
import '../../models/user_data_model.dart';
import '../../models/fish_model.dart';
import '../../theme/app_colors.dart';
import '../../widgets/habit_progress_section.dart';
import '../../widgets/god_rays_painter.dart';
import '../../widgets/bubble_painter.dart';

/// 메인 어항 화면 - 정적 배경 + (프레임 PNG) 물고기 유영 + CustomPainter(빛/거품)
class AquariumScreen extends StatefulWidget {
  final Function(int)? onNavChanged;

  const AquariumScreen({super.key, this.onNavChanged});

  @override
  State<AquariumScreen> createState() => _AquariumScreenState();
}

class _AquariumScreenState extends State<AquariumScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Bubble> _bubbles;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();

    _bubbles = generateBubbles(40);
  }

  @override
  void dispose() {
    _animationController.dispose();
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

          return Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.60,
                child: _buildAquariumSection(context, userData),
              ),
              Expanded(child: _buildMissionArea(context, userData)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAquariumSection(BuildContext context, UserData userData) {
    final fish = userData.fish;

    // ✅ 3종류 x 3프레임 (전부 "왼쪽을 바라보는" 프레임이라고 가정)
    const fishTypes = <List<String>>[
      [
        'assets/images/fish/type1_1.png',
        'assets/images/fish/type1_2.png',
        'assets/images/fish/type1_3.png',
      ],
      [
        'assets/images/fish/type2_1.png',
        'assets/images/fish/type2_2.png',
        'assets/images/fish/type2_3.png',
      ],
      [
        'assets/images/fish/type3_1.png',
        'assets/images/fish/type3_2.png',
        'assets/images/fish/type3_3.png',
      ],
    ];

    return Stack(
      children: [
        Positioned.fill(
          child: Stack(
            children: [
              // 1) 정적 배경
              Positioned.fill(
                child: Image.asset(
                  'assets/images/aquarium_bg.png',
                  fit: BoxFit.cover,
                ),
              ),

              // 2) 물고기 유영 레이어 (후진 제거: 이동방향=머리방향)
              Positioned.fill(
                child: FishSwimLayerFrames(
                  animation: _animationController,
                  fishTypes: fishTypes,
                  count: 10,
                  renderSize: 56, // ✅ 작게 쓸거라 대충 56으로 고정
                  fps: 10,
                  // ✅ 네 PNG가 기본으로 "왼쪽을 바라봄"
                  defaultFacing: FishFacing.left,
                  // ✅ 좌/우로 다니되, 항상 앞으로 헤엄치게(필요하면 false로 바꾸면 한 방향만)
                  allowBothDirections: true,
                ),
              ),

              // 3) 빛/거품 이펙트
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Stack(
                    children: [
                      CustomPaint(
                        size: Size.infinite,
                        painter: GodRaysPainter(
                          animationValue: _animationController.value,
                        ),
                      ),
                      CustomPaint(
                        size: Size.infinite,
                        painter: BubblePainter(
                          animationValue: _animationController.value,
                          bubbles: _bubbles,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),

        // HUD
        Positioned(
          top: 16,
          left: 16,
          child: _buildHUD(context, fish, userData.gold),
        ),
      ],
    );
  }

  Widget _buildHUD(BuildContext context, Fish fish, int gold) {
    final progress = (fish.exp / 100).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(fish.type.emoji, style: const TextStyle(fontSize: 20)),
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
          onQuestToggle: (questId) =>
              context.read<UserDataProvider>().completeQuestById(questId),
          onDailyQuestTap: () => widget.onNavChanged?.call(1),
        ),
      ),
    );
  }
}

/// ----------------------------
/// FishSwimLayerFrames
/// - 3종류 x 3프레임 PNG 애니메이션
/// - 후진 방지: "머리 방향 = 이동 방향"
/// ----------------------------

enum FishFacing { left, right }

class _SwimFishFrames {
  _SwimFishFrames({
    required this.frames,
    required this.facing,
    required this.baseY,
    required this.speed,
    required this.amp,
    required this.freq,
    required this.phase,
    required this.size,
    required this.startX,
    required this.opacity,
    required this.frameOffset,
  });

  final List<String> frames; // 3프레임
  final FishFacing facing; // 실제 이동방향

  final double baseY;
  final double speed;
  final double amp;
  final double freq;
  final double phase;
  final double size;
  final double startX;
  final double opacity;
  final int frameOffset;
}

class FishSwimLayerFrames extends StatefulWidget {
  const FishSwimLayerFrames({
    super.key,
    required this.animation,
    required this.fishTypes,
    this.count = 8,
    this.renderSize = 56,
    this.fps = 10,
    this.defaultFacing = FishFacing.left,
    this.allowBothDirections = true,
  });

  final Animation<double> animation;

  /// 3종류 x 3프레임
  final List<List<String>> fishTypes;

  final int count;
  final double renderSize;
  final int fps;

  /// 프레임 PNG가 기본으로 바라보는 방향
  final FishFacing defaultFacing;

  /// true면 좌/우로 섞어서 다님. false면 defaultFacing 방향으로만 다님
  final bool allowBothDirections;

  @override
  State<FishSwimLayerFrames> createState() => _FishSwimLayerFramesState();
}

class _FishSwimLayerFramesState extends State<FishSwimLayerFrames> {
  final _rng = Random();
  late final List<_SwimFishFrames> _fishes;

  @override
  void initState() {
    super.initState();

    final safeTypes =
    widget.fishTypes.where((t) => t.isNotEmpty).toList(growable: false);

    _fishes = List.generate(widget.count, (_) {
      final frames = safeTypes[_rng.nextInt(safeTypes.length)];

      final facing = widget.allowBothDirections
          ? (_rng.nextBool() ? FishFacing.left : FishFacing.right)
          : widget.defaultFacing;

      final baseY = 0.12 + _rng.nextDouble() * 0.72;
      final speed = 18 + _rng.nextDouble() * 55;
      final amp = 5 + _rng.nextDouble() * 12;
      final freq = 0.7 + _rng.nextDouble() * 1.4;
      final phase = _rng.nextDouble() * pi * 2;

      final size = widget.renderSize * (0.75 + _rng.nextDouble() * 0.6);

      // 시작 X (대충)
      final startX = _rng.nextDouble() * 800;

      final opacity = 0.70 + _rng.nextDouble() * 0.30;
      final frameOffset = _rng.nextInt(max(1, frames.length));

      return _SwimFishFrames(
        frames: frames,
        facing: facing,
        baseY: baseY,
        speed: speed,
        amp: amp,
        freq: freq,
        phase: phase,
        size: size,
        startX: startX,
        opacity: opacity,
        frameOffset: frameOffset,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.fishTypes.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final h = c.maxHeight;

        return AnimatedBuilder(
          animation: widget.animation,
          builder: (context, child) {
            final t = widget.animation.value * 30.0; // 0~30초
            return Stack(
              children: [
                for (final f in _fishes) _buildOneFish(f, w, h, t),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildOneFish(_SwimFishFrames f, double w, double h, double t) {
    // ✅ 이동방향에 따라 x 증가/감소를 맞춰 "후진" 제거
    final travel = t * f.speed;
    final total = w + f.size * 2;

    final x = (f.facing == FishFacing.left)
    // 왼쪽으로 전진: x가 줄어드는 느낌
        ? (total - ((f.startX + travel) % total)) - f.size
    // 오른쪽으로 전진: x가 늘어나는 느낌
        : ((f.startX + travel) % total) - f.size;

    final yBase = h * f.baseY;
    final yWave = sin(t * f.freq + f.phase) * f.amp;
    final y = yBase + yWave;

    final fps = max(1, widget.fps);
    final frameIndex =
    (((t * fps).floor() + f.frameOffset) % f.frames.length);

    // ✅ PNG 기본 방향(defaultFacing)과 실제 진행방향(facing)이 다르면 flip
    final shouldFlip =
        (widget.defaultFacing == FishFacing.left && f.facing == FishFacing.right) ||
            (widget.defaultFacing == FishFacing.right && f.facing == FishFacing.left);

    return Positioned(
      left: x,
      top: y,
      child: Opacity(
        opacity: f.opacity,
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..scale(shouldFlip ? -1.0 : 1.0, 1.0, 1.0),
          child: SizedBox(
            width: f.size,
            height: f.size,
            child: FittedBox(
              fit: BoxFit.contain,
              alignment: Alignment.center,
              child: Image.asset(
                f.frames[frameIndex],
                filterQuality: FilterQuality.none,
              ),
            ),
          ),
        ),
      ),
    );
  }
}