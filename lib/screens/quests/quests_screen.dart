import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_decorations.dart';
import '../../providers/app_provider.dart';
import '../../models/quest_model.dart';

/// [QuestsScreen]
/// 사용자의 일일 퀘스트 목록을 보여주고 완료 처리 기능을 제공합니다.
class QuestsScreen extends StatelessWidget {
  const QuestsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<AppProvider>(
          builder: (context, provider, child) {
            final userData = provider.userData;
            if (userData == null) {
              return Center(
                child: Text(
                  '데이터를 불러올 수 없습니다',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              );
            }

            // [How] 오늘 날짜에 해당하고 완료되지 않은 퀘스트 필터링
            final todayQuests = userData.quests.where(
                  (q) => q.date.toString() == userData.currentDate && !q.completed,
            ).toList();

            // [How] 완료된 퀘스트 필터링
            final completedQuests = userData.quests.where(
                  (q) => q.date.toString() == userData.currentDate && q.completed,
            ).toList();

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '오늘의 퀘스트',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${completedQuests.length}/${todayQuests.length + completedQuests.length} 완료됨',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Expanded(
                    child: (todayQuests.isEmpty && completedQuests.isEmpty)
                        ? Center(
                          child: Text(
                            '오늘 등록된 퀘스트가 없습니다.',
                            style: const TextStyle(color: AppColors.textTertiary),
                          ),
                        )
                        : ListView(
                          children: [
                            ...todayQuests.map((quest) => _buildQuestCard(context, quest, provider)),
                            if (completedQuests.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20.0),
                                child: Divider(color: AppColors.borderLight),
                              ),
                              const Text(
                                '✅ 완료됨',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.statusSuccess,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...completedQuests.map((quest) => _buildQuestCard(context, quest, provider, isCompleted: true)),
                            ],
                          ],
                        ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// [타입 수정] quest 인자에 명확한 'Quest' 타입을 지정했습니다.
  Widget _buildQuestCard(
      BuildContext context,
      Quest quest, // dynamic 대신 Quest 타입 사용
      AppProvider provider, {
        bool isCompleted = false,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted ? AppColors.statusSuccess.withOpacity(0.08) : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted ? AppColors.statusSuccess.withOpacity(0.2) : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: isCompleted,
              onChanged: isCompleted ? null : (_) async {
                await provider.completeQuest(quest.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${quest.title} 완료! 🐟'),
                      backgroundColor: AppColors.statusSuccess,
                    ),
                  );
                }
              },
              activeColor: AppColors.statusSuccess,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quest.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    color: isCompleted ? AppColors.textTertiary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildTag(quest.category, AppColors.secondaryPastel),
                    const SizedBox(width: 8),
                    _buildTag(quest.difficulty.displayName, _getDifficultyColor(quest.difficulty)),
                    const Spacer(),
                    _buildRewardInfo(Icons.star, '+${quest.expReward}', AppColors.accentPastel),
                    const SizedBox(width: 8),
                    _buildRewardInfo(Icons.monetization_on, '+${quest.goldReward}', AppColors.highlightPink),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildRewardInfo(IconData icon, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// [타입 수정] difficulty 인자에 'Difficulty' 타입을 지정했습니다.
  Color _getDifficultyColor(Difficulty difficulty) {
    switch (difficulty.name) {
      case 'easy':
        return AppColors.statusSuccess;
      case 'normal':
        return AppColors.primaryPastel;
      case 'hard':
        return AppColors.highlightPink;
      default:
        return AppColors.textTertiariculty difficulty) {
    switch (difficulty.name) {
      case 'easy': return Colors.green;
      case 'normal': return Colors.blue;
      case 'hard': return Colors.redAccent;
      default: return Colors.grey;
    }
  }
}