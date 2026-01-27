import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../providers/user_data_provider.dart';
import '../../widgets/common/cards.dart';
import '../../models/models.dart';

/// 퀘스트 화면
class QuestsScreen extends StatelessWidget {
  const QuestsScreen({Key? key}) : super(key: key);

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

            final allQuests = userData.quests.toList();

            return Column(
              children: [
                // 헤더
                _buildHeader(context, allQuests),

                // 퀘스트 목록
                Expanded(
                  child: allQuests.isEmpty
                      ? EmptyState(
                          message: '진행 중인 퀘스트가 없습니다',
                          icon: Icons.task_alt,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: allQuests.length,
                          itemBuilder: (context, index) {
                            return _buildQuestCard(
                              context,
                              allQuests[index],
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
                '퀘스트',
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
        ],
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
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 체크박스
                  Checkbox(
                    value: quest.completed,
                    onChanged: quest.completed
                        ? null
                        : (_) => _completeQuest(context, quest, provider),
                    activeColor: AppColors.statusSuccess,
                  ),
                  // 제목과 설명
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
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 태그
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 48.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: difficultyColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        quest.difficulty.displayName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: difficultyColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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

  Future<void> _completeQuest(
    BuildContext context,
    Quest quest,
    UserDataProvider provider,
  ) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${quest.title} 완료!'),
        backgroundColor: AppColors.statusSuccess,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
