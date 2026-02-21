import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/timer_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_decorations.dart';

/// [StatisticsModal]
/// 선택된 날짜의 상세 통계를 표시하는 모달입니다.
/// [기능]:
/// - 총 집중 시간
/// - 최대 집중 시간
/// - 시작 시간 / 종료 시간
/// - 카테고리별 원형 차트
class StatisticsModal extends StatelessWidget {
  final DateTime selectedDate;
  final List<TimerSession> sessions;

  const StatisticsModal({
    Key? key,
    required this.selectedDate,
    required this.sessions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '통계',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${selectedDate.year}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.day.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),

            // 컨텐츠
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 주요 통계 카드
                    _buildMainStatsCard(),
                    const SizedBox(height: 20),

                    // 시간대 표시
                    _buildTimeRangeCard(),
                    const SizedBox(height: 20),

                    // 카테고리별 원형 차트
                    if (sessions.isNotEmpty) ...[
                      _buildCategoryPieChart(),
                      const SizedBox(height: 20),
                    ],

                    // 세션 목록
                    _buildSessionsListCard(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// [_buildMainStatsCard]
  /// 총 시간, 최대 집중 시간 등 주요 통계를 표시합니다.
  Widget _buildMainStatsCard() {
    int totalSeconds = 0;
    int maxSessionSeconds = 0;

    for (final session in sessions) {
      totalSeconds += session.durationSeconds;
      if (session.durationSeconds > maxSessionSeconds) {
        maxSessionSeconds = session.durationSeconds;
      }
    }

    final totalMinutes = totalSeconds ~/ 60;
    final totalHours = totalMinutes ~/ 60;
    final remainingMinutes = totalMinutes % 60;

    final maxMinutes = maxSessionSeconds ~/ 60;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatBox(
                label: '총 집중 시간',
                value: totalHours > 0
                    ? '${totalHours}h ${remainingMinutes}m'
                    : '${remainingMinutes}m',
                icon: Icons.timer,
                color: AppColors.success,
              ),
              _buildStatBox(
                label: '최대 집중',
                value: maxMinutes > 0 ? '${maxMinutes}분' : '${maxSessionSeconds}초',
                icon: Icons.trending_up,
                color: AppColors.primary,
              ),
              _buildStatBox(
                label: '세션 수',
                value: '${sessions.length}회',
                icon: Icons.repeat,
                color: AppColors.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// [_buildStatBox]
  /// 개별 통계 박스를 빌드합니다.
  Widget _buildStatBox({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// [_buildTimeRangeCard]
  /// 시작 시간과 종료 시간을 표시합니다.
  Widget _buildTimeRangeCard() {
    DateTime? startTime;
    DateTime? endTime;

    for (final session in sessions) {
      final sessionStart = DateTime.fromMillisecondsSinceEpoch(session.startTime);
      final sessionEnd = DateTime.fromMillisecondsSinceEpoch(session.endTime);

      if (startTime == null || sessionStart.isBefore(startTime)) {
        startTime = sessionStart;
      }

      if (endTime == null || sessionEnd.isAfter(endTime)) {
        endTime = sessionEnd;
      }
    }

    final startTimeStr = startTime != null
        ? '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}'
        : '-';

    final endTimeStr = endTime != null
        ? '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}'
        : '-';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '시작 시간',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                startTimeStr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Icon(Icons.arrow_forward, color: AppColors.textTertiary),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '종료 시간',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                endTimeStr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// [_buildCategoryPieChart]
  /// 카테고리별 집중 시간을 원형 차트로 표시합니다.
  Widget _buildCategoryPieChart() {
    // 카테고리별 시간 합산
    final categoryTotals = <String, int>{};
    for (final session in sessions) {
      categoryTotals.update(
        session.category,
        (value) => value + session.durationSeconds,
        ifAbsent: () => session.durationSeconds,
      );
    }

    final totalSeconds = categoryTotals.values.fold<int>(0, (sum, val) => sum + val);

    // 차트 데이터 생성
    final pieSections = categoryTotals.entries.map((entry) {
      final category = entry.key;
      final seconds = entry.value;
      final percentage = (seconds / totalSeconds) * 100;
      final color = _getCategoryColor(category);

      return PieChartSectionData(
        value: percentage,
        title: '${percentage.toStringAsFixed(1)}%',
        color: color,
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '카테고리별 분포',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: AppDecorations.card(),
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: pieSections,
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 범례
              Column(
                children: categoryTotals.entries.map((entry) {
                  final category = entry.key;
                  final seconds = entry.value;
                  final minutes = seconds ~/ 60;
                  final color = _getCategoryColor(category);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            category,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          minutes > 0
                              ? '${minutes}분'
                              : '${seconds}초',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// [_buildSessionsListCard]
  /// 해당 날짜의 모든 세션을 리스트로 표시합니다.
  Widget _buildSessionsListCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '세션 목록',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: AppDecorations.card(),
          child: Column(
            children: sessions.isNotEmpty
                ? sessions.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final session = entry.value;
                    final startTime =
                        DateTime.fromMillisecondsSinceEpoch(session.startTime);
                    final timeStr =
                        '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
                    final durationMin = session.durationSeconds ~/ 60;

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(session.category)
                                      .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    '${idx + 1}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: _getCategoryColor(session.category),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      session.category,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      timeStr,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(session.category)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '$durationMin분',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        _getCategoryColor(session.category),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (idx < sessions.length - 1)
                          Container(
                            height: 1,
                            color: AppColors.borderLight,
                          ),
                      ],
                    );
                  }).toList()
                : [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        '세션이 없습니다',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ],
          ),
        ),
      ],
    );
  }

  /// [_getCategoryColor]
  /// 카테고리명으로 색상을 결정합니다.
  Color _getCategoryColor(String category) {
    final hash = category.codeUnits.fold<int>(0, (sum, value) => sum + value);
    const colors = [
      Color(0xFF4FC3F7),
      Color(0xFF9575CD),
      Color(0xFF81C784),
      Color(0xFFFFB74D),
      Color(0xFFF06292),
      Color(0xFF90A4AE),
    ];
    return colors[hash % colors.length];
  }
}
