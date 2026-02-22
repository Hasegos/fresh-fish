import 'dart:ui';

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// 습관 진행도 섹션 위젯
class HabitProgressSection extends StatelessWidget {
  final List<Quest> todayQuests;
  final Function(String)? onQuestToggle;
  final Function(String)? onTodoToggle;
  final VoidCallback? onDailyQuestTap;

  const HabitProgressSection({
    Key? key,
    required this.todayQuests,
    this.onQuestToggle,
    this.onTodoToggle,
    this.onDailyQuestTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dailies = todayQuests
        .where((q) => q.questType == QuestType.daily)
        .toList();
    
    // [Fix] 완료된 미션은 홈 화면에서 제거
    final activeDailies = dailies.where((q) => !q.completed).toList();
    
    // 진행도 계산은 전체 기준으로 (완료된 것도 포함)
    final completedDailies = dailies.where((q) => q.completed).length;
    final dailyProgress = dailies.isNotEmpty
        ? (completedDailies / dailies.length) * 100
        : 0.0;

    final completedText = completedDailies == 1
      ? '1 Mission Completed'
      : '$completedDailies Missions Completed';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            '오늘의 진행도',
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: const Color(0xFF0277BD),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // 일일 진행도 개요
        InkWell(
          onTap: onDailyQuestTap,
          borderRadius: BorderRadius.circular(12),
          child: _buildGlassCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '일일 퀘스트',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.1,
                          color: const Color(0xFF0277BD),
                        ),
                      ),
                      Text(
                        completedText,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0288D1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildProgressBar(dailyProgress),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // 일일 항목들
        ...activeDailies.take(5).map((quest) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildQuestItem(quest),
            )),

        // 빈 상태
        if (activeDailies.isEmpty)
          _buildGlassCard(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  '오늘의 할 일이 없습니다',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: const Color(0xFF607D8B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF).withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.75),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0277BD).withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildProgressBar(double progress) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: const Color(0xFFBBDEFB).withValues(alpha: 0.50),
        borderRadius: BorderRadius.circular(99),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final ratio = (progress / 100).clamp(0.0, 1.0);
          return Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: constraints.maxWidth * ratio,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF42A5F5),
                    Color(0xFF1E88E5),
                  ],
                ),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuestItem(Quest quest) {
    return InkWell(
      onTap: () => onQuestToggle?.call(quest.id),
      borderRadius: BorderRadius.circular(12),
      child: _buildGlassCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                quest.completed ? Icons.check_circle : Icons.circle_outlined,
                color: quest.completed 
                    ? const Color(0xFF1E88E5) 
                    : const Color(0xFF90CAF9),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quest.title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.1,
                        decoration: quest.completed
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: quest.completed
                            ? const Color(0xFF607D8B)
                            : const Color(0xFF01579B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      quest.category,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: const Color(0xFF607D8B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '+${quest.expReward}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: const Color(0xFF0288D1),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
