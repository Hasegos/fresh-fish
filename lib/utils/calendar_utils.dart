import '../models/models.dart';

/// 캘린더 관련 유틸리티 함수
class CalendarUtils {
  /// 날짜 포맷 (YYYY-MM-DD)
  static String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 문자열을 DateTime으로 변환
  static DateTime? parseDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// 오늘 날짜 문자열
  static String today() {
    return formatDate(DateTime.now());
  }

  /// 특정 날짜의 요일 (한국어)
  static String getWeekday(DateTime date) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return weekdays[date.weekday - 1];
  }

  /// 특정 날짜의 퀘스트 필터링
  static List<Quest> getQuestsForDate(List<Quest> quests, String date) {
    return quests.where((q) => q.date == date).toList();
  }

  /// 특정 날짜의 완료율 계산
  static int getCompletionRate(List<Quest> quests, String date) {
    final dayQuests = getQuestsForDate(quests, date);
    if (dayQuests.isEmpty) return 0;

    final completed = dayQuests.where((q) => q.completed).length;
    return ((completed / dayQuests.length) * 100).round();
  }

  /// 특정 날짜의 기록 상태 계산
  static RecordStatus getRecordStatus(List<Quest> quests, String date) {
    final dayQuests = getQuestsForDate(quests, date);
    if (dayQuests.isEmpty) return RecordStatus.none;

    final completed = dayQuests.where((q) => q.completed).length;
    final total = dayQuests.length;

    if (completed == 0) return RecordStatus.fail;
    if (completed == total) return RecordStatus.success;
    return RecordStatus.partial;
  }

  /// 연속 달성 일수 계산
  static int getStreakDays(List<DailyRecord> history) {
    if (history.isEmpty) return 0;

    int streak = 0;
    final sortedHistory = [...history]..sort((a, b) => b.date.compareTo(a.date));

    for (final record in sortedHistory) {
      if (record.status == RecordStatus.success) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  /// 월별 기록 필터링
  static List<DailyRecord> getRecordsForMonth(
    List<DailyRecord> history,
    int year,
    int month,
  ) {
    return history.where((record) {
      final date = parseDate(record.date);
      if (date == null) return false;
      return date.year == year && date.month == month;
    }).toList();
  }

  /// 주간 통계
  static Map<String, dynamic> getWeeklyStats(List<DailyRecord> history) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final weekRecords = history.where((record) {
      final date = parseDate(record.date);
      if (date == null) return false;
      return date.isAfter(weekAgo) && date.isBefore(now.add(const Duration(days: 1)));
    }).toList();

    final totalDays = weekRecords.length;
    final successDays = weekRecords.where((r) => r.status == RecordStatus.success).length;
    final totalQuests = weekRecords.fold<int>(0, (sum, r) => sum + r.totalQuests);
    final completedQuests = weekRecords.fold<int>(0, (sum, r) => sum + r.completedQuests);

    return {
      'totalDays': totalDays,
      'successDays': successDays,
      'totalQuests': totalQuests,
      'completedQuests': completedQuests,
      'completionRate': totalQuests > 0 ? ((completedQuests / totalQuests) * 100).round() : 0,
    };
  }
}
