import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/fish_model.dart';

/// 수족관 화면
class AquariumScreen extends StatelessWidget {
  const AquariumScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A3A52),
            Color(0xFF0D1B2A),
          ],
        ),
      ),
      child: SafeArea(
        child: Consumer<AppProvider>(
          builder: (context, provider, child) {
            final userData = provider.userData;
            if (userData == null) {
              return const Center(child: Text('데이터 없음'));
            }

            final fish = userData.fish;
            final stage = _getGrowthStage(fish);

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // 헤더
                  _buildHeader(userData),
                  const SizedBox(height: 24),

                  // 수족관
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2A3A).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFF4FC3F7).withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 물고기
                            Text(
                              _getFishEmoji(stage),
                              style: const TextStyle(fontSize: 120),
                            ),
                            const SizedBox(height: 16),

                            // 레벨
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E2A3A),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '레벨 ${fish.level}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 통계
                  _buildStats(fish, userData),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(userData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Aquarium',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2A3A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.monetization_on, color: Color(0xFFFFD700), size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${userData.gold}G',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStats(fish, userData) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2A3A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // HP
          _buildStatBar(
            label: 'HP',
            value: fish.hp,
            maxValue: fish.maxHp,
            color: _getHpColor(fish.hp),
          ),
          const SizedBox(height: 16),

          // 경험치
          _buildStatBar(
            label: 'EXP',
            value: fish.exp,
            maxValue: 100,
            color: const Color(0xFF4FC3F7),
          ),
          const SizedBox(height: 16),

          // 수질
          _buildStatBar(
            label: '수질',
            value: userData.waterQuality,
            maxValue: 100,
            color: Colors.blue,
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
    final progress = (value / maxValue).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$value/$maxValue',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  GrowthStage _getGrowthStage(fish) {
    if (fish.eggHatchedAt == null) return GrowthStage.adult;

    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsed = now - fish.eggHatchedAt!;
    final hours = elapsed / (1000 * 60 * 60);

    if (hours < 24) return GrowthStage.egg;
    if (hours < 48) return GrowthStage.juvenile;
    return GrowthStage.adult;
  }

  String _getFishEmoji(GrowthStage stage) {
    switch (stage) {
      case GrowthStage.egg:
        return '🥚';
      case GrowthStage.juvenile:
        return '🐟';
      case GrowthStage.adult:
        return '🐠';
    }
  }

  Color _getHpColor(int hp) {
    if (hp > 60) return Colors.green;
    if (hp > 30) return Colors.orange;
    return Colors.red;
  }
}
