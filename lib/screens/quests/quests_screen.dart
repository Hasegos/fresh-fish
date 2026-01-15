import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';

/// 퀘스트 화면
class QuestsScreen extends StatelessWidget {
  const QuestsScreen({Key? key}) : super(key: key);

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

            final todayQuests = userData.quests.where(
              (q) => q.date == userData.currentDate && !q.completed,
            ).toList();

            final completedQuests = userData.quests.where(
              (q) => q.date == userData.currentDate && q.completed,
            ).toList();

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 헤더
                  const Text(
                    '오늘의 퀘스트',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${completedQuests.length}/${userData.quests.where((q) => q.date == userData.currentDate).length} 완료',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 퀘스트 목록
                  Expanded(
                    child: todayQuests.isEmpty && completedQuests.isEmpty
                        ? const Center(
                            child: Text(
                              '오늘의 퀘스트가 없습니다',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white54,
                              ),
                            ),
                          )
                        : ListView(
                            children: [
                              // 미완료 퀘스트
                              ...todayQuests.map((quest) => Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: _buildQuestCard(
                                  context,
                                  quest,
                                  provider,
                                ),
                              )),

                              // 완료된 퀘스트
                              if (completedQuests.isNotEmpty) ...[
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16.0),
                                  child: Text(
                                    '✅ 완료',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                                ...completedQuests.map((quest) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: _buildQuestCard(
                                    context,
                                    quest,
                                    provider,
                                    isCompleted: true,
                                  ),
                                )),
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

  Widget _buildQuestCard(
    BuildContext context,
    quest,
    AppProvider provider, {
    bool isCompleted = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted
            ? Colors.green.withOpacity(0.1)
            : const Color(0xFF1E2A3A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? Colors.green.withOpacity(0.3)
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          // 체크박스
          Checkbox(
            value: isCompleted,
            onChanged: isCompleted
                ? null
                : (_) async {
                    await provider.completeQuest(quest.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${quest.title} 완료! 🎉'),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
            activeColor: Colors.green,
          ),
          const SizedBox(width: 12),

          // 퀘스트 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quest.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    decoration: isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                    color: isCompleted ? Colors.white54 : Colors.white,
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
                        color: const Color(0xFF4FC3F7).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        quest.category,
                        style: const TextStyle(fontSize: 12),
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
                        color: _getDifficultyColor(quest.difficulty)
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        quest.difficulty.displayName,
                        style: TextStyle(
                          fontSize: 12,
                          color: _getDifficultyColor(quest.difficulty),
                        ),
                      ),
                    ),
                    const Spacer(),

                    // 보상
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '+${quest.expReward}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.monetization_on, size: 14, color: Color(0xFFFFD700)),
                        const SizedBox(width: 4),
                        Text(
                          '+${quest.goldReward}',
                          style: const TextStyle(fontSize: 12),
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
    );
  }

  Color _getDifficultyColor(difficulty) {
    switch (difficulty.name) {
      case 'easy':
        return Colors.green;
      case 'normal':
        return Colors.blue;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
