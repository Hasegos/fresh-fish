import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/models.dart';
import '../utils/growth_utils.dart';
import '../utils/time_based_theme.dart';
import 'animated_fish.dart';
import 'underwater_effects.dart';

/// 수족관 뷰포트 위젯
class AquariumViewport extends StatelessWidget {
  final Fish fish;
  final int waterQuality;
  final List<PlacedDecoration> decorations;

  const AquariumViewport({
    Key? key,
    required this.fish,
    required this.waterQuality,
    this.decorations = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stage = GrowthUtils.getGrowthStage(fish);
    final theme = getAquariumTheme();

    return Container(
      decoration: BoxDecoration(
        gradient: theme.gradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // 수중 효과 (변환된 위젯 사용)
            UnderwaterEffects(theme: theme),

            // 장식들
            ..._buildDecorations(context),

            // 애니메이션 물고기 (변환된 위젯 사용)
            AnimatedFish(
              fishType: fish.type,
              level: fish.level,
              scale: 1.0,
              waterQuality: waterQuality,
              eggHatchedAt: fish.eggHatchedAt,
            ),

            // 물고기 정보 오버레이
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: _buildFishInfo(stage),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDecorations(BuildContext context) {
    if (decorations.isEmpty) return [];

    final screenSize = MediaQuery.of(context).size;
    return decorations.map((decoration) {
      // x, y는 퍼센트 값이므로 화면 크기에 맞게 변환 필요
      return Positioned(
        left: decoration.x * 0.01 * screenSize.width,
        top: decoration.y * 0.01 * screenSize.height,
        child: const Text(
          '🪸', // 장식 이모지 (실제로는 decorationId로 조회)
          style: TextStyle(fontSize: 32),
        ),
      );
    }).toList();
  }

  Widget _buildFishInfo(GrowthStage stage) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // HP 바
          _buildStatBar(
            label: 'HP',
            value: fish.hp,
            maxValue: fish.maxHp,
            color: _getHpColor(fish.hp),
          ),
          const SizedBox(height: 12),

          // 경험치 바
          _buildStatBar(
            label: 'EXP',
            value: fish.exp,
            maxValue: 100,
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),

          // 성장 단계
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('성장 단계', style: AppTextStyles.bodySmall),
              Text(
                GrowthUtils.getGrowthStageText(stage),
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBar({
    required String label,
    required int value,
    required int maxValue,
    required Color color,
  }) {
    final progress = value / maxValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.bodySmall),
            Text('$value/$maxValue', style: AppTextStyles.caption),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.textDisabled.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Color _getHpColor(int hp) {
    if (hp > 60) return AppColors.success;
    if (hp > 30) return AppColors.warning;
    return AppColors.error;
  }
}

