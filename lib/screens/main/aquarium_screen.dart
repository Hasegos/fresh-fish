import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_data_provider.dart';
import '../../models/user_data_model.dart';
import '../../models/fish_model.dart';
import '../../theme/app_colors.dart';
import '../../widgets/habit_progress_section.dart';
import '../../widgets/god_rays_painter.dart';
import '../../widgets/bubble_painter.dart';

/// 메인 어항 화면 - WebP 배경 + CustomPainter 애니메이션
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
    
    // 애니메이션 컨트롤러 초기화 (30초로 느리게)
    _animationController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat(); // 무한 반복
    
    // 거품 생성 (더 많이)
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
          );
        },
      ),
    );
  }

  Widget _buildAquariumSection(BuildContext context, UserData userData) {
    final fish = userData.fish;

    return Stack(
      children: [
        // 전체 화면 수족관 애니메이션
        Positioned.fill(
          child: Stack(
            children: [
              // 1. WebP 정적 배경 (애니메이션 GIF처럼 자동 재생되지만, 반복은 부드럽게)
              Positioned.fill(
                child: Image.asset(
                  'assets/videos/aquarium_vid.webp',
                  fit: BoxFit.cover,
                  gaplessPlayback: true, // 부드러운 전환
                ),
              ),
              
              // 2. 애니메이션 레이어 (거품과 빛만)
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Stack(
                    children: [
                      // God Rays 레이어 (빛 광선)
                      CustomPaint(
                        size: Size.infinite,
                        painter: GodRaysPainter(
                          animationValue: _animationController.value,
                        ),
                      ),
                      
                      // 거품 레이어 (최상단)
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

        // HUD (Top-Left)
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
