import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/quest_model.dart';
import '../../models/timer_model.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_decorations.dart';
import 'statistics_modal.dart';

/// 캘린더 화면 (활동 기록)
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: Row(
          children: [
            // Home 버튼
            IconButton(
              icon: const Icon(Icons.home, color: AppColors.textPrimary),
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
            // Back 버튼
            IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        leadingWidth: 100,
        title: const Text('Calendar', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Consumer<AppProvider>(
          builder: (context, provider, child) {
            final userData = provider.userData;
            if (userData == null) {
              return const Center(child: Text('데이터 없음', style: TextStyle(color: AppColors.textPrimary)));
            }

            final List history = userData.history;
            final todosByDate = _groupTodosByDate(userData.todos);
            final sessionsByDate = _groupSessionsByDate(userData.timerSessions);
            final selectedKey = _formatDate(_selectedDate);
            final selectedTodos = todosByDate[selectedKey] ?? [];
            final selectedSessions = sessionsByDate[selectedKey] ?? [];
            final selectedFocusSeconds = _sumSessionSeconds(selectedSessions);
            final weeklyFocusSeconds = _sumWeeklySessionSeconds(userData.timerSessions, _selectedDate);

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  const Text('Calendar', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  Text('${history.length}일 기록됨', style: const TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                  const SizedBox(height: 16),

                  _buildCalendarCard(
                    todosByDate: todosByDate,
                    sessionsByDate: sessionsByDate,
                  ),
                  const SizedBox(height: 16),

                  _buildFocusStatsCard(
                    selectedSeconds: selectedFocusSeconds,
                    weeklySeconds: weeklyFocusSeconds,
                    sessionsByDate: sessionsByDate,
                  ),
                  const SizedBox(height: 16),

                  // 선택된 날짜의 타이머 통계 그래프
                  if (selectedSessions.isNotEmpty)
                    _buildCategoryChart(selectedSessions),
                  if (selectedSessions.isNotEmpty)
                    const SizedBox(height: 16),

                  _buildScheduleSection(selectedTodos, selectedSessions),
                  const SizedBox(height: 16),

                  // 통계 카드 섹션
                  _buildStatsCard(history),
                  const SizedBox(height: 16),

                  _buildWeeklyProgressGraph(userData.timerSessions),
                  const SizedBox(height: 16),

                  const Text('최근 기록', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),

                  if (history.isEmpty)
                    const Center(
                      child: Text(
                        '아직 기록이 없습니다',
                        style: TextStyle(color: AppColors.textTertiary),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final record = history[history.length - 1 - index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: _buildHistoryCard(record),
                        );
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCalendarCard({
    required Map<String, List<ToDo>> todosByDate,
    required Map<String, List<TimerSession>> sessionsByDate,
  }) {
    final daysInMonth = DateUtils.getDaysInMonth(_focusedMonth.year, _focusedMonth.month);
    final firstWeekday = DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday;
    final leadingEmpty = (firstWeekday - DateTime.monday) % 7;
    final totalCells = leadingEmpty + daysInMonth;

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
                '${_focusedMonth.year}.${_focusedMonth.month.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              IconButton(
                onPressed: _goToNextMonth,
                icon: const Icon(Icons.chevron_right, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildWeekdayRow(),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalCells,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemBuilder: (context, index) {
              if (index < leadingEmpty) {
                return const SizedBox.shrink();
              }
              final day = index - leadingEmpty + 1;
              final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
              final isSelected = _isSameDay(date, _selectedDate);
              final isToday = _isSameDay(date, DateTime.now());
              final dateKey = _formatDate(date);
              final todoCount = todosByDate[dateKey]?.length ?? 0;
              final sessionCount = sessionsByDate[dateKey]?.length ?? 0;
              final hasItems = todoCount + sessionCount > 0;
              
              // 해당 날짜의 누적 시간 계산
              final daySessionSeconds = sessionsByDate[dateKey]
                  ?.fold<int>(0, (sum, session) => sum + session.durationSeconds) ?? 0;
              final dayMinutes = daySessionSeconds ~/ 60;

              return InkWell(
                onTap: () => _onDateSelected(date),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryPastel.withOpacity(0.2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isToday ? AppColors.primaryPastel : Colors.transparent,
                      width: 1.2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$day',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),
                      // 누적 시간 표시
                      if (dayMinutes > 0) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${dayMinutes}분',
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      if (hasItems && dayMinutes == 0) ...[
                        const SizedBox(height: 2),
                        _buildDateIndicators(todoCount, sessionCount),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.event, size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 6),
              Text(
                '${_selectedDate.year}.${_selectedDate.month.toString().padLeft(2, '0')}.${_selectedDate.day.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayRow() {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: labels
          .map((label) => Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildDateIndicators(int todoCount, int sessionCount) {
    final dots = <Widget>[];
    if (todoCount > 0) {
      dots.add(_buildDot(AppColors.info));
    }
    if (sessionCount > 0) {
      dots.add(_buildDot(AppColors.success));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: dots
          .map((dot) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1.5),
                child: dot,
              ))
          .toList(),
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildScheduleSection(List<ToDo> todos, List<TimerSession> sessions) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '선택한 날짜 일정',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          if (todos.isEmpty && sessions.isEmpty)
            const Text('일정이 없습니다', style: TextStyle(color: AppColors.textTertiary))
          else ...[
            ...todos.map(_buildTodoScheduleItem),
            if (sessions.isNotEmpty) const SizedBox(height: 8),
            ...sessions.map(_buildSessionScheduleItem),
          ],
        ],
      ),
    );
  }

  Widget _buildTodoScheduleItem(ToDo todo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 18, color: AppColors.info),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              todo.title,
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            ),
          ),
          if (todo.dueTime != null)
            Text(
              todo.dueTime!,
              style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
            ),
        ],
      ),
    );
  }

  Widget _buildSessionScheduleItem(TimerSession session) {
    final start = DateTime.fromMillisecondsSinceEpoch(session.startTime);
    final duration = _formatDuration(session.durationSeconds);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.timer, size: 18, color: AppColors.success),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              session.category,
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            ),
          ),
          Text(
            '${_formatTime(start)} · $duration',
            style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  Map<String, List<ToDo>> _groupTodosByDate(List<ToDo> todos) {
    final map = <String, List<ToDo>>{};
    for (final todo in todos) {
      final dueDate = todo.dueDate;
      if (dueDate == null || dueDate.isEmpty) continue;
      map.putIfAbsent(dueDate, () => []).add(todo);
    }
    return map;
  }

  Map<String, List<TimerSession>> _groupSessionsByDate(List<TimerSession> sessions) {
    final map = <String, List<TimerSession>>{};
    for (final session in sessions) {
      final date = DateTime.fromMillisecondsSinceEpoch(session.startTime);
      final key = _formatDate(date);
      map.putIfAbsent(key, () => []).add(session);
    }
    return map;
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _goToPreviousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
      _selectedDate = _clampSelectedDate(_focusedMonth, _selectedDate.day);
    });
  }

  void _goToNextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
      _selectedDate = _clampSelectedDate(_focusedMonth, _selectedDate.day);
    });
  }

  DateTime _clampSelectedDate(DateTime month, int preferredDay) {
    final days = DateUtils.getDaysInMonth(month.year, month.month);
    final day = preferredDay > days ? days : preferredDay;
    return DateTime(month.year, month.month, day);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(int seconds) {
    final totalMinutes = (seconds / 60).floor();
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  int _sumSessionSeconds(List<TimerSession> sessions) {
    var total = 0;
    for (final session in sessions) {
      total += session.durationSeconds;
    }
    return total;
  }

  int _sumWeeklySessionSeconds(List<TimerSession> sessions, DateTime anchor) {
    final start = _startOfWeek(anchor);
    final end = start.add(const Duration(days: 6));
    var total = 0;
    for (final session in sessions) {
      final date = DateTime.fromMillisecondsSinceEpoch(session.startTime);
      if (!_isBeforeDay(date, start) && !_isAfterDay(date, end)) {
        total += session.durationSeconds;
      }
    }
    return total;
  }

  DateTime _startOfWeek(DateTime date) {
    final weekdayIndex = (date.weekday + 6) % 7;
    final start = DateTime(date.year, date.month, date.day).subtract(Duration(days: weekdayIndex));
    return start;
  }

  bool _isBeforeDay(DateTime a, DateTime b) {
    if (a.year != b.year) return a.year < b.year;
    if (a.month != b.month) return a.month < b.month;
    return a.day < b.day;
  }

  bool _isAfterDay(DateTime a, DateTime b) {
    if (a.year != b.year) return a.year > b.year;
    if (a.month != b.month) return a.month > b.month;
    return a.day > b.day;
  }

  Widget _buildFocusStatsCard({
    required int selectedSeconds,
    required int weeklySeconds,
    required Map<String, List<TimerSession>> sessionsByDate,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.timer,
                label: '선택한 날',
                value: _formatDuration(selectedSeconds),
                color: AppColors.success,
              ),
              _buildStatItem(
                icon: Icons.calendar_view_week,
                label: '이번 주',
                value: _formatDuration(weeklySeconds),
                color: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 통계 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final selectedKey = _formatDate(_selectedDate);
                final selectedSessions = sessionsByDate[selectedKey] ?? [];
                
                showDialog(
                  context: context,
                  builder: (context) => StatisticsModal(
                    selectedDate: _selectedDate,
                    sessions: selectedSessions,
                  ),
                );
              },
              icon: const Icon(Icons.bar_chart),
              label: const Text('상세 통계'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
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
      case 'partial': return Icons.check_circle_outline;
      case 'fail': return Icons.cancel;
      default: return Icons.help_outline;
    }
  }

  // 선택된 날짜의 카테고리별 집중 시간 그래프
  Widget _buildCategoryChart(List<TimerSession> sessions) {
    // 카테고리별 시간 합산
    final categoryTotals = <String, int>{};
    for (final session in sessions) {
      categoryTotals.update(
        session.category,
        (value) => value + session.durationSeconds,
        ifAbsent: () => session.durationSeconds,
      );
    }

    // 정렬: 시간이 많은 순
    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // 최대값 계산
    final maxSeconds = sortedEntries.isNotEmpty ? sortedEntries.first.value : 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '카테고리별 집중 시간',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...sortedEntries.map((entry) {
            final category = entry.key;
            final seconds = entry.value;
            final minutes = (seconds / 60).floor();
            final remainingSecs = seconds % 60;
            final timeText = minutes > 0
                ? '$minutes분 ${remainingSecs}초'
                : '${remainingSecs}초';
            final percentage = (seconds / maxSeconds).clamp(0.0, 1.0);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        category,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        timeText,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage,
                      minHeight: 8,
                      backgroundColor: AppColors.borderLight,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getCategoryColor(category),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // 카테고리명으로 색상 결정
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

  Widget _buildWeeklyProgressGraph(List<TimerSession> sessions) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));

    final days = List.generate(7, (index) => start.add(Duration(days: index)));
    final dayTotals = <int>[];

    for (final day in days) {
      var total = 0;
      for (final session in sessions) {
        final date = DateTime.fromMillisecondsSinceEpoch(session.startTime);
        final isSameDay =
            date.year == day.year && date.month == day.month && date.day == day.day;
        if (!isSameDay) continue;
        total += session.durationSeconds;
      }
      dayTotals.add(total);
    }

    final maxSeconds = dayTotals.reduce((a, b) => a > b ? a : b);
    final labels = ['월', '화', '수', '목', '금', '토', '일'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '최근 7일 집중 통계',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(7, (index) {
            final day = days[index];
            final total = dayTotals[index];
            final ratio = maxSeconds == 0 ? 0.0 : (total / maxSeconds);
            final minutes = total ~/ 60;
            final weekdayLabel = labels[(day.weekday + 6) % 7];

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: Text(
                      weekdayLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 8,
                        backgroundColor: AppColors.borderLight,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 52,
                    child: Text(
                      '${minutes}m',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}