import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_decorations.dart';

/// 캘린더 화면 (활동 기록)
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _focusedMonth;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<AppProvider>(
          builder: (context, provider, child) {
            final userData = provider.userData;
            if (userData == null) {
              return const Center(child: Text('데이터 없음', style: TextStyle(color: AppColors.textPrimary)));
            }

            final List history = userData.history;
            final historyDates = _buildHistoryDateSet(history);
            final timerTotals = _buildTimerDailyTotals(userData.timerSessions);
            final monthCategoryTotals = _buildMonthCategoryTotals(
              userData.timerSessions,
              _focusedMonth,
            );
            final categoryColors = {
              for (final c in userData.timerCategories)
                c.name: _parseColor(c.color),
            };

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Calendar', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  Text('${history.length}일 기록됨', style: const TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                  const SizedBox(height: 24),

                  _buildCalendar(historyDates, timerTotals),
                  const SizedBox(height: 24),

                  // 통계 카드 섹션
                  _buildStatsCard(history),
                  const SizedBox(height: 24),

                  const Text('최근 기록', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 16),

                  Expanded(
                    child: history.isEmpty && monthCategoryTotals.isEmpty
                        ? const Center(child: Text('아직 기록이 없습니다', style: TextStyle(color: AppColors.textTertiary)))
                        : ListView(
                          children: [
                            _buildMonthlyStudySummary(
                              monthCategoryTotals: monthCategoryTotals,
                              categoryColors: categoryColors,
                            ),
                            const SizedBox(height: 16),
                            if (history.isNotEmpty)
                              ...history.reversed.map((record) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12.0),
                                    child: _buildHistoryCard(record),
                                  )),
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

  Widget _buildStatsCard(List history) {
    final totalDays = history.length;
    final successDays = history.where((r) => r.status.name == 'success').length;

    final totalQuests = history.fold<int>(0, (sum, r) => sum + (r.totalQuests as int));
    final completedQuests = history.fold<int>(0, (sum, r) => sum + (r.completedQuests as int));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.card(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(icon: Icons.calendar_today, label: '총 일수', value: '$totalDays일', color: AppColors.primary),
          _buildStatItem(icon: Icons.check_circle, label: '성공', value: '$successDays일', color: AppColors.success),
          _buildStatItem(icon: Icons.assignment, label: '완료', value: '$completedQuests/$totalQuests', color: AppColors.warning),
        ],
      ),
    );
  }

  Widget _buildCalendar(Set<DateTime> historyDates, Map<DateTime, int> timerTotals) {
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final startWeekday = firstDayOfMonth.weekday % 7; // 0 = Sunday

    final monthTotals = _filterMonthTotals(timerTotals, _focusedMonth);
    final maxSeconds = monthTotals.isEmpty
        ? 0
        : monthTotals.values.reduce((a, b) => a > b ? a : b);

    final totalCells = startWeekday + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _goToPreviousMonth,
                icon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
              ),
              Text(
                _monthLabel(_focusedMonth),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                onPressed: _goToNextMonth,
                icon: const Icon(Icons.chevron_right, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _WeekdayLabel('S'),
              _WeekdayLabel('M'),
              _WeekdayLabel('T'),
              _WeekdayLabel('W'),
              _WeekdayLabel('T'),
              _WeekdayLabel('F'),
              _WeekdayLabel('S'),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rows * 7,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final dayNumber = index - startWeekday + 1;
              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const SizedBox.shrink();
              }

              final date = DateTime(_focusedMonth.year, _focusedMonth.month, dayNumber);
              final isSelected = _isSameDay(_selectedDate, date);
              final isToday = _isSameDay(DateTime.now(), date);
              final hasHistory = historyDates.contains(date);
              final totalSeconds = monthTotals[date] ?? 0;
                final intensity = _calculateIntensity(totalSeconds, maxSeconds);
                final heatColor = _heatColor(intensity);
                final baseColor = isSelected
                  ? AppColors.primaryPastel.withOpacity(0.25)
                  : (intensity > 0 ? heatColor : Colors.white);

              return GestureDetector(
                onTap: () => setState(() => _selectedDate = date),
                child: Container(
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryPastel
                          : AppColors.borderLight,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '$dayNumber',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                              color: isToday
                                ? AppColors.primary
                                : (intensity > 0 ? Colors.white : AppColors.textPrimary),
                        ),
                      ),
                      if (hasHistory)
                        Positioned(
                          bottom: 6,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                                color: isSelected
                                  ? AppColors.primary
                                  : (intensity > 0 ? AppColors.success : AppColors.success),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _goToPreviousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  String _monthLabel(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    return '${date.year}-$month';
  }

  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Map<DateTime, int> _buildTimerDailyTotals(List sessions) {
    final totals = <DateTime, int>{};
    for (final session in sessions) {
      try {
        final startMillis = session.startTime as int;
        final date = DateTime.fromMillisecondsSinceEpoch(startMillis);
        final dayKey = DateTime(date.year, date.month, date.day);
        totals[dayKey] = (totals[dayKey] ?? 0) + (session.durationSeconds as int);
      } catch (_) {
        // ignore invalid session
      }
    }
    return totals;
  }

  Map<String, int> _buildMonthCategoryTotals(List sessions, DateTime month) {
    final totals = <String, int>{};
    for (final session in sessions) {
      try {
        final startMillis = session.startTime as int;
        final date = DateTime.fromMillisecondsSinceEpoch(startMillis);
        if (date.year == month.year && date.month == month.month) {
          final category = session.category as String;
          totals[category] = (totals[category] ?? 0) + (session.durationSeconds as int);
        }
      } catch (_) {
        // ignore invalid session
      }
    }
    return totals;
  }

  Map<DateTime, int> _filterMonthTotals(Map<DateTime, int> totals, DateTime month) {
    final filtered = <DateTime, int>{};
    totals.forEach((date, seconds) {
      if (date.year == month.year && date.month == month.month) {
        filtered[date] = seconds;
      }
    });
    return filtered;
  }

  double _calculateIntensity(int seconds, int maxSeconds) {
    if (seconds <= 0 || maxSeconds <= 0) return 0;
    final ratio = seconds / maxSeconds;
    return ratio.clamp(0.1, 0.9);
  }

  Color _heatColor(double intensity) {
    return AppColors.success.withOpacity(0.08 + (0.32 * intensity));
  }

  Widget _buildMonthlyStudySummary({
    required Map<String, int> monthCategoryTotals,
    required Map<String, Color> categoryColors,
  }) {
    final totalSeconds = monthCategoryTotals.values.fold<int>(0, (a, b) => a + b);
    final topEntry = monthCategoryTotals.entries.isEmpty
        ? null
        : monthCategoryTotals.entries.reduce((a, b) => a.value >= b.value ? a : b);

    final sections = monthCategoryTotals.entries.map((entry) {
      final color = categoryColors[entry.key] ?? AppColors.primaryPastel;
      return PieChartSectionData(
        value: entry.value.toDouble(),
        color: color.withOpacity(0.9),
        radius: 36,
        title: '',
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card(),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: monthCategoryTotals.isEmpty
                ? const Center(
                    child: Text(
                      '데이터 없음',
                      style: TextStyle(color: AppColors.textTertiary),
                    ),
                  )
                : PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 34,
                      sectionsSpace: 2,
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '이번 달 공부 요약',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  '총 시간: ${_formatDuration(totalSeconds)}',
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 6),
                Text(
                  topEntry == null
                      ? '가장 많이 공부한 카테고리: 없음'
                      : '가장 많이 공부한 카테고리: ${topEntry.key}',
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    if (seconds <= 0) return '0시간 0분';
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    return '${hours}시간 ${minutes}분';
  }

  Color _parseColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  Set<DateTime> _buildHistoryDateSet(List history) {
    final dates = <DateTime>{};
    for (final record in history) {
      try {
        final dateString = record.date as String;
        final parsed = DateTime.tryParse(dateString);
        if (parsed != null) {
          dates.add(DateTime(parsed.year, parsed.month, parsed.day));
        }
      } catch (_) {
        // ignore invalid record
      }
    }
    return dates;
  }

  Widget _buildStatItem({required IconData icon, required String label, required String value, required Color color}) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  // [Critical Fix] dynamic 레코드에서 String과 int 값을 안전하게 추출합니다.
  Widget _buildHistoryCard(dynamic record) {
    final String statusName = record.status.name as String;
    final String date = record.date as String;
    final int completed = record.completedQuests as int;
    final int total = record.totalQuests as int;

    // [Why] 완료율 계산 수식: $$ \text{rate} = \frac{\text{completed}}{\text{total}} \times 100 $$
    final int rate = total > 0 ? ((completed / total) * 100).round() : 0;

    final statusColor = _getStatusColor(statusName);
    final statusIcon = _getStatusIcon(statusName);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.featureCard(accentColor: statusColor),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: statusColor.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(statusIcon, color: statusColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text('$completed/$total 완료', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text('$rate%', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: statusColor)),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'success': return Colors.green;
      case 'partial': return Colors.orange;
      case 'fail': return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'success': return Icons.check_circle;
      case 'partial': return Icons.adjust;
      case 'fail': return Icons.cancel;
      default: return Icons.help;
    }
  }
}

class _WeekdayLabel extends StatelessWidget {
  final String label;

  const _WeekdayLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}