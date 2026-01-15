import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../providers/user_data_provider.dart';
import '../../widgets/common/cards.dart';
import '../../models/models.dart';

/// 데일리 퀘스트 화면
class DailiesScreen extends StatelessWidget {
  const DailiesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.backgroundGradient,
      ),
      child: SafeArea(
        child: Consumer<UserDataProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const LoadingIndicator(message: '로딩 중...');
            }

            final userData = provider.userData;
            if (userData == null) {
              return const EmptyState(
                message: '데이터를 불러올 수 없습니다',
                icon: Icons.error_outline,
              );
            }

            final todayQuests = userData.quests.where(
              (q) => q.date == userData.currentDate && q.questType == QuestType.daily
            ).toList();

            return Column(
              children: [
                // 헤더
                _buildHeader(context, todayQuests),

                // 퀘스트 목록
                Expanded(
                  child: todayQuests.isEmpty
                      ? EmptyState(
                          message: '오늘의 퀘스트가 없습니다',
                          icon: Icons.task_alt,
                          actionLabel: '퀘스트 추가',
                          onAction: () => _showAddQuestDialog(context),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: todayQuests.length,
                          itemBuilder: (context, index) {
                            return _buildQuestCard(
                              context,
                              todayQuests[index],
                              provider,
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, List<Quest> quests) {
    final completed = quests.where((q) => q.completed).length;
    final total = quests.length;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const Expanded(
                child: Text(
                  '데일리 퀘스트',
                  style: AppTextStyles.h2,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 16),
          CommonCard(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatChip(
                  icon: Icons.assignment,
                  label: '전체',
                  value: '$total',
                  color: AppColors.primary,
                ),
                _buildStatChip(
                  icon: Icons.check_circle,
                  label: '완료',
                  value: '$completed',
                  color: AppColors.success,
                ),
                _buildStatChip(
                  icon: Icons.pending,
                  label: '남음',
                  value: '${total - completed}',
                  color: AppColors.warning,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.h3.copyWith(color: color)),
      ],
    );
  }

  Widget _buildQuestCard(
    BuildContext context,
    Quest quest,
    UserDataProvider provider,
  ) {
    final difficultyColor = {
      Difficulty.easy: AppColors.easyColor,
      Difficulty.normal: AppColors.normalColor,
      Difficulty.hard: AppColors.hardColor,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: CommonCard(
        backgroundColor: quest.completed
            ? AppColors.success.withOpacity(0.1)
            : AppColors.surface,
        child: Row(
          children: [
            // 체크박스
            Checkbox(
              value: quest.completed,
              onChanged: quest.completed
                  ? null
                  : (_) => _completeQuest(context, quest, provider),
              activeColor: AppColors.success,
            ),

            // 퀘스트 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quest.title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      decoration: quest.completed
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // 카테고리
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: (AppColors.category[quest.category] ?? AppColors.primary)
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          quest.category,
                          style: AppTextStyles.caption,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // 난이도
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: difficultyColor[quest.difficulty]!.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getDifficultyText(quest.difficulty),
                          style: AppTextStyles.caption.copyWith(
                            color: difficultyColor[quest.difficulty],
                          ),
                        ),
                      ),
                      const Spacer(),

                      // 보상
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '+${quest.expReward}',
                            style: AppTextStyles.caption,
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.monetization_on,
                            size: 14,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '+${quest.goldReward}',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDifficultyText(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return '쉬움';
      case Difficulty.normal:
        return '보통';
      case Difficulty.hard:
        return '어려움';
    }
  }

  Future<void> _completeQuest(
    BuildContext context,
    Quest quest,
    UserDataProvider provider,
  ) async {
    await provider.completeQuest(
      quest.id,
      quest.expReward,
      quest.goldReward,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${quest.title} 완료! 🎉'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showAddQuestDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('퀘스트 추가 기능은 준비 중입니다'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
