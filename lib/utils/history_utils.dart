import '../models/models.dart';
import 'calendar_utils.dart';

/// 히스토리 관련 유틸리티
class HistoryUtils {
  /// 오늘의 기록 생성
  static DailyRecord createTodayRecord(List<Quest> quests, String date) {
    final todayQuests = quests.where((q) => q.date == date).toList();
    final completed = todayQuests.where((q) => q.completed).length;
    final total = todayQuests.length;

    return DailyRecord(
      date: date,
      totalQuests: total,
      completedQuests: completed,
      status: _calculateStatus(completed, total),
    );
  }

  /// 상태 계산
  static RecordStatus _calculateStatus(int completed, int total) {
    if (total == 0) return RecordStatus.none;
    if (completed == 0) return RecordStatus.fail;
    if (completed == total) return RecordStatus.success;
    return RecordStatus.partial;
  }

  /// 히스토리 업데이트 또는 추가
  static List<DailyRecord> updateOrAddRecord(
    List<DailyRecord> history,
    DailyRecord newRecord,
  ) {
    final existingIndex = history.indexWhere((r) => r.date == newRecord.date);

    if (existingIndex != -1) {
      // 기존 기록 업데이트
      final updated = [...history];
      updated[existingIndex] = newRecord;
      return updated;
    } else {
      // 새 기록 추가
      return [...history, newRecord];
    }
  }

  /// 전체 통계 계산
  static Map<String, dynamic> calculateTotalStats(List<DailyRecord> history) {
    final totalDays = history.length;
    final successDays = history.where((r) => r.status == RecordStatus.success).length;
    final partialDays = history.where((r) => r.status == RecordStatus.partial).length;
    final failDays = history.where((r) => r.status == RecordStatus.fail).length;

    final totalQuests = history.fold<int>(0, (sum, r) => sum + r.totalQuests);
    final completedQuests = history.fold<int>(0, (sum, r) => sum + r.completedQuests);

    final completionRate = totalQuests > 0
        ? ((completedQuests / totalQuests) * 100).round()
        : 0;

    return {
      'totalDays': totalDays,
      'successDays': successDays,
      'partialDays': partialDays,
      'failDays': failDays,
      'totalQuests': totalQuests,
      'completedQuests': completedQuests,
      'completionRate': completionRate,
    };
  }

  /// 연속 성공 일수 계산
  static int calculateStreak(List<DailyRecord> history) {
    if (history.isEmpty) return 0;

    final sorted = [...history]..sort((a, b) => b.date.compareTo(a.date));
    int streak = 0;

    for (final record in sorted) {
      if (record.status == RecordStatus.success) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  /// 최장 연속 기록 계산
  static int calculateLongestStreak(List<DailyRecord> history) {
    if (history.isEmpty) return 0;

    final sorted = [...history]..sort((a, b) => a.date.compareTo(b.date));
    int longestStreak = 0;
    int currentStreak = 0;

    for (final record in sorted) {
      if (record.status == RecordStatus.success) {
        currentStreak++;
        if (currentStreak > longestStreak) {
          longestStreak = currentStreak;
        }
      } else {
        currentStreak = 0;
      }
    }

    return longestStreak;
  }

  /// 최근 N일 기록 가져오기
  static List<DailyRecord> getRecentRecords(List<DailyRecord> history, int days) {
    final sorted = [...history]..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(days).toList();
  }

  /// 완료율 색상
  static String getCompletionRateColor(int rate) {
    if (rate >= 80) return 'success';
    if (rate >= 50) return 'warning';
    return 'error';
  }

  /// 월간 통계
  static Map<String, dynamic> getMonthlyStats(
    List<DailyRecord> history,
    int year,
    int month,
  ) {
    final monthRecords = CalendarUtils.getRecordsForMonth(history, year, month);

    final totalDays = monthRecords.length;
    final successDays = monthRecords.where((r) => r.status == RecordStatus.success).length;
    final totalQuests = monthRecords.fold<int>(0, (sum, r) => sum + r.totalQuests);
    final completedQuests = monthRecords.fold<int>(0, (sum, r) => sum + r.completedQuests);

    return {
      'totalDays': totalDays,
      'successDays': successDays,
      'totalQuests': totalQuests,
      'completedQuests': completedQuests,
      'completionRate': totalQuests > 0
          ? ((completedQuests / totalQuests) * 100).round()
          : 0,
    };
  }

  /// 카테고리별 통계
  static Map<String, int> getCategoryStats(List<Quest> quests) {
    final stats = <String, int>{};

    for (final quest in quests) {
      if (quest.completed) {
        stats[quest.category] = (stats[quest.category] ?? 0) + 1;
      }
    }

    return stats;
  }

  /// 난이도별 통계
  static Map<String, int> getDifficultyStats(List<Quest> quests) {
    final stats = <String, int>{};

    for (final quest in quests) {
      if (quest.completed) {
        final key = quest.difficulty.name;
        stats[key] = (stats[key] ?? 0) + 1;
      }
    }

    return stats;
  }
}
