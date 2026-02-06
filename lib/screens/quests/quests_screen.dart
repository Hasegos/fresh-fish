import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import '../../theme/app_colors.dart';
import '../../providers/user_data_provider.dart';
import '../../widgets/common/cards.dart';
import '../../models/models.dart';

class QuestsScreen extends StatelessWidget {
  const QuestsScreen({Key? key}) : super(key: key);

  static const String _devAchievementTitle = '[DEV] 업적 테스트: 퀘스트 화면에서 팝업';
  static const String _devAchievementIcon = '🧪';

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
                _buildHeader(allQuests),
                if (!kReleaseMode)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: _buildDevTestCard(context),
                  ),
                Expanded(
                  child: allQuests.isEmpty
                      ? const EmptyState(
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

  Widget _buildDevTestCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          const Text('🧪', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'DEV 테스트: 눌러서 업적 팝업 뜨는지 확인',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => _devUnlockAndPopup(context),
            child: const Text('테스트'),
          ),
        ],
      ),
    );
  }

  Future<void> _devUnlockAndPopup(BuildContext context) async {
    final provider = context.read<UserDataProvider>();

    final unlocked = await provider.unlockAchievement(
      title: _devAchievementTitle,
      icon: _devAchievementIcon,
      description: '퀘스트 화면에서 DEV 업적 팝업 테스트',
    );

    if (!context.mounted) return;

    if (unlocked == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미 완료된 DEV 업적입니다.')),
      );
      return;
    }

    _showAchievementPopup(
      context,
      icon: unlocked.icon,
      title: unlocked.title,
    );
  }

  Widget _buildHeader(List<Quest> quests) {
    final completed = quests.where((q) => q.completed == true).length;
    final total = quests.length;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
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
          color: quest.completed == true
              ? AppColors.statusSuccess.withOpacity(0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: quest.completed == true
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
                  Checkbox(
                    value: quest.completed == true,
                    onChanged: (quest.completed == true)
                        ? null
                        : (_) => _completeQuest(context, quest, provider),
                    activeColor: AppColors.statusSuccess,
                  ),
                  Expanded(
                    child: Text(
                      quest.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: quest.completed == true
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                        decoration: quest.completed == true
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 48.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
    List<Achievement> newlyUnlocked = [];

    try {
      newlyUnlocked = await provider.completeQuest(
        quest.id,
        quest.expReward,
        quest.goldReward,
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('퀘스트 완료 처리 실패: $e')),
      );
      return;
    }

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${quest.title} 완료! (+${quest.goldReward}G, +${quest.expReward}EXP)'),
        backgroundColor: AppColors.statusSuccess,
        duration: const Duration(seconds: 2),
      ),
    );

    for (final a in newlyUnlocked) {
      if (!context.mounted) return;
      _showAchievementPopup(context, icon: a.icon, title: a.title);
    }
  }

  void _showAchievementPopup(
      BuildContext context, {
        required String icon,
        required String title,
      }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('업적 달성'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 30)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              '계속 진행해보자',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
