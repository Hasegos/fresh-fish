import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_fish/models/user_data_model.dart';
import 'package:fresh_fish/utils/calendar_utils.dart';
import 'package:fresh_fish/utils/history_utils.dart';

void main() {
  test('perfect week requires 7 success days in same week', () {
    final weekStart = DateTime(2026, 2, 16); // Monday
    final records = List.generate(7, (i) {
      final date = weekStart.add(Duration(days: i));
      return DailyRecord(
        date: CalendarUtils.formatDate(date),
        totalQuests: 3,
        completedQuests: 3,
        status: RecordStatus.success,
      );
    });

    expect(HistoryUtils.hasPerfectWeek(records), true);
  });

  test('perfect week fails if any day is not success', () {
    final weekStart = DateTime(2026, 2, 16);
    final records = List.generate(7, (i) {
      final date = weekStart.add(Duration(days: i));
      return DailyRecord(
        date: CalendarUtils.formatDate(date),
        totalQuests: 3,
        completedQuests: i == 3 ? 1 : 3,
        status: i == 3 ? RecordStatus.partial : RecordStatus.success,
      );
    });

    expect(HistoryUtils.hasPerfectWeek(records), false);
  });

  test('perfect week fails if any day is missing', () {
    final weekStart = DateTime(2026, 2, 16);
    final records = List.generate(6, (i) {
      final date = weekStart.add(Duration(days: i));
      return DailyRecord(
        date: CalendarUtils.formatDate(date),
        totalQuests: 2,
        completedQuests: 2,
        status: RecordStatus.success,
      );
    });

    expect(HistoryUtils.hasPerfectWeek(records), false);
  });
}
