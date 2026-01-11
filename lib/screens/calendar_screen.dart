import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/daily_record.dart';
import '../services/storage_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _currentDate;
  String? _selectedDate;
  List<DailyRecord> _history = [];

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await StorageService.getHistory();
    setState(() {
      _history = history;
    });
  }

  void _previousMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);
    });
  }

  DailyRecord? _getRecordForDate(String date) {
    return _history.cast<DailyRecord?>().firstWhere(
          (r) => r?.date == date,
          orElse: () => null,
        );
  }

  Color _getStatusColor(DailyRecord? record) {
    if (record == null) return const Color(0xFFE5E7EB);
    if (record.completedCount == 0) return const Color(0xFFEF4444);
    if (record.completedCount == record.totalCount) return const Color(0xFF10B981);
    return const Color(0xFFFBBF24);
  }

  @override
  Widget build(BuildContext context) {
    final year = _currentDate.year;
    final month = _currentDate.month;
    final firstDayOfMonth = DateTime(year, month, 1);
    final lastDayOfMonth = DateTime(year, month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final daysInMonth = lastDayOfMonth.day;

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final selectedRecord = _selectedDate != null ? _getRecordForDate(_selectedDate!) : null;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF60A5FA), Color(0xFF2563EB)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '달력',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Calendar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Month Navigation
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: _previousMonth,
                            icon: const Icon(Icons.chevron_left),
                          ),
                          Text(
                            '$year년 ${month}월',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: _nextMonth,
                            icon: const Icon(Icons.chevron_right),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Weekday Headers
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: ['일', '월', '화', '수', '목', '금', '토']
                            .asMap()
                            .entries
                            .map((entry) {
                          Color color = const Color(0xFF6B7280);
                          if (entry.key == 0) color = const Color(0xFFEF4444);
                          if (entry.key == 6) color = const Color(0xFF3B82F6);

                          return SizedBox(
                            width: 40,
                            child: Text(
                              entry.value,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),

                      // Calendar Grid
                      ...List.generate((firstWeekday + daysInMonth) ~/ 7 + 1, (week) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: List.generate(7, (day) {
                              final index = week * 7 + day;
                              if (index < firstWeekday ||
                                  index >= firstWeekday + daysInMonth) {
                                return const SizedBox(width: 40, height: 40);
                              }

                              final dayNumber = index - firstWeekday + 1;
                              final dateStr =
                                  '$year-${month.toString().padLeft(2, '0')}-${dayNumber.toString().padLeft(2, '0')}';
                              final record = _getRecordForDate(dateStr);
                              final isSelected = _selectedDate == dateStr;
                              final isToday = dateStr == today;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedDate = dateStr;
                                  });
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF3B82F6)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: isToday
                                        ? Border.all(
                                            color: const Color(0xFF60A5FA),
                                            width: 2,
                                          )
                                        : null,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '$dayNumber',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: isSelected
                                              ? Colors.white
                                              : const Color(0xFF1F2937),
                                        ),
                                      ),
                                      if (record != null) ...[
                                        const SizedBox(height: 2),
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(record),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        );
                      }),

                      const SizedBox(height: 24),

                      // Legend
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLegend(const Color(0xFF10B981), '완료'),
                          const SizedBox(width: 16),
                          _buildLegend(const Color(0xFFFBBF24), '일부'),
                          const SizedBox(width: 16),
                          _buildLegend(const Color(0xFFEF4444), '실패'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Selected Date Details
              if (_selectedDate != null)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$_selectedDate 기록',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (selectedRecord != null) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  '완료율',
                                  style: TextStyle(color: Color(0xFF6B7280)),
                                ),
                                Text(
                                  '${selectedRecord.completedCount} / ${selectedRecord.totalCount}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: ListView.builder(
                                itemCount: selectedRecord.quests.length,
                                itemBuilder: (context, index) {
                                  final quest = selectedRecord.quests[index];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: quest.completed
                                          ? const Color(0xFFD1FAE5)
                                          : const Color(0xFFF3F4F6),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: quest.completed
                                                ? const Color(0xFF10B981)
                                                : const Color(0xFFD1D5DB),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            quest.title,
                                            style: TextStyle(
                                              color: quest.completed
                                                  ? const Color(0xFF1F2937)
                                                  : const Color(0xFF6B7280),
                                              decoration: quest.completed
                                                  ? TextDecoration.none
                                                  : TextDecoration.lineThrough,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ] else
                            const Expanded(
                              child: Center(
                                child: Text(
                                  '이 날짜에는 기록이 없습니다.',
                                  style: TextStyle(
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}