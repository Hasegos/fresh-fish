import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/models.dart';
import '../utils/growth_utils.dart';

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

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A3A52),
            Color(0xFF0D1B2A),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          // 배경 효과 (물결)
          _buildWaterEffect(),

          // 장식들
          ..._buildDecorations(),

          // 물고기
          Center(
            child: _buildFish(stage),
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
    );
  }

  Widget _buildWaterEffect() {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.1,
        child: CustomPaint(
          painter: WaterEffectPainter(),
        ),
      ),
    );
  }

  List<Widget> _buildDecorations() {
    return decorations.map((decoration) {
      return Positioned(
        left: decoration.x,
        top: decoration.y,
        child: const Text(
          '🪸', // 장식 이모지 (실제로는 decorationId로 조회)
          style: TextStyle(fontSize: 32),
        ),
      );
    }).toList();
  }

  Widget _buildFish(GrowthStage stage) {
    final emoji = GrowthUtils.getGrowthStageEmoji(stage);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 물고기 애니메이션
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(seconds: 2),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, -10 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 120),
          ),
        ),

        const SizedBox(height: 16),

        // 물고기 이름
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '레벨 ${fish.level}',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
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

/// 물결 효과 페인터
class WaterEffectPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    
    for (int i = 0; i < 3; i++) {
      path.reset();
      path.moveTo(0, size.height * 0.3 + i * 50);
      
      for (double x = 0; x <= size.width; x += 20) {
        final y = size.height * 0.3 + i * 50 + 10 * (x / 100).sin();
        path.lineTo(x, y);
      }
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
