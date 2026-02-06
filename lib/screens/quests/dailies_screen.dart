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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
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
                      ? const EmptyState(
                          message: '오늘의 퀘스트가 없습니다',
                          icon: Icons.task_alt,
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
              const Text(
                '오늘의 퀘스트',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryPastel.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$completed/$total 완료',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryPastel,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatChip(
                Icons.emoji_events,
                'EXP',
                '+${(completed * 10)}',
                AppColors.accentPastel,
              ),
              const SizedBox(width: 12),
              _buildStatChip(
                Icons.trending_up,
                'Status',
                '${(completed * 10)}%',
                AppColors.primaryPastel,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTextStyles.h3.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestCard(
    BuildContext context,
    Quest quest,
    UserDataProvider provider,
  ) {
    final difficultyColor = _getDifficultyColor(quest.difficulty);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: quest.completed
              ? AppColors.statusSuccess.withOpacity(0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: quest.completed
                ? AppColors.statusSuccess.withOpacity(0.2)
                : AppColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            // 체크박스
            Checkbox(
              value: quest.completed,
              onChanged: quest.completed
                  ? null
                  : (_) => _completeQuest(context, quest, provider),
              activeColor: AppColors.statusSuccess,
            ),
            // 내용
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quest.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: quest.completed
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                      decoration: quest.completed
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: difficultyColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _getDifficultyLabel(quest.difficulty),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: difficultyColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 보상 표시
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    '+${quest.expReward}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryPastel,
                    ),
                  ),
                  const Text(
                    'EXP',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return AppColors.statusSuccess;
      case Difficulty.normal:
        return AppColors.primaryPastel;
      case Difficulty.hard:
        return AppColors.highlightPink;
    }
  }

  String _getDifficultyLabel(Difficulty difficulty) {
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
          content: Text('${quest.title} ???! +${quest.expReward} EXP ???'),
          backgroundColor: AppColors.statusSuccess,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
