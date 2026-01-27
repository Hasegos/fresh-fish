import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_text_styles.dart';

/// 습관 진행도 섹션 위젯
class HabitProgressSection extends StatelessWidget {
  final List<Quest> todayQuests;
  final List<ToDo> todos;
  final Function(String)? onQuestToggle;
  final Function(String)? onTodoToggle;

  const HabitProgressSection({
    Key? key,
    required this.todayQuests,
    required this.todos,
    this.onQuestToggle,
    this.onTodoToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dailies = todayQuests
        .where((q) => q.questType == QuestType.daily)
        .toList();
    final completedDailies = dailies.where((q) => q.completed).length;
    final dailyProgress = dailies.isNotEmpty
        ? (completedDailies / dailies.length) * 100
        : 0.0;

    final activeTodos = todos.where((t) => !t.completed).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            '오늘의 진행도',
            style: AppTextStyles.headingSmall,
          ),
        ),
        const SizedBox(height: 12),

        // 일일 진행도 개요
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '일일 퀘스트',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '$completedDailies/${dailies.length}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFAED581),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildProgressBar(dailyProgress),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 일일 항목들
        ...dailies.take(5).map((quest) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildQuestItem(quest),
            )),

        // 상위 활성 할일
        if (activeTodos.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _buildTodoItem(activeTodos.first),
          ),

        // 빈 상태
        if (dailies.isEmpty && activeTodos.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '오늘의 할 일이 없습니다',
                style: AppTextStyles.bodySmall.copyWith(
                  color: const Color(0xFF90A4AE),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProgressBar(double progress) {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: (progress / 100).clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFAED581),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestItem(Quest quest) {
    return InkWell(
      onTap: () => onQuestToggle?.call(quest.id),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              quest.completed ? Icons.check_circle : Icons.circle_outlined,
              color: quest.completed
                  ? const Color(0xFFAED581)
                  : const Color(0xFFE0E0E0),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quest.title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                      decoration: quest.completed
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: quest.completed
                          ? const Color(0xFF90A4AE)
                          : const Color(0xFF2E3440),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    quest.category,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: const Color(0xFF90A4AE),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '+${quest.expReward}',
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFFAED581),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodoItem(ToDo todo) {
    return InkWell(
      onTap: () => onTodoToggle?.call(todo.id),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.circle_outlined,
              color: Color(0xFFE0E0E0),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    todo.title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF2E3440),
                    ),
                  ),
                  if (todo.dueDate != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text('📅 '),
                        Text(
                          todo.dueDate!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: const Color(0xFF90A4AE),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Text(
              '+${todo.expReward}',
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFFAED581),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
