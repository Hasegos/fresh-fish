import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_fish/utils/calendar_utils.dart';

void main() {
  test('app day normalization uses 4am cutoff', () {
    final beforeCutoff = DateTime(2026, 2, 18, 3, 59);
    final atCutoff = DateTime(2026, 2, 18, 4, 0);

    expect(
      CalendarUtils.normalizeToAppDay(beforeCutoff),
      DateTime(2026, 2, 17),
    );
    expect(
      CalendarUtils.normalizeToAppDay(atCutoff),
      DateTime(2026, 2, 18),
    );
  });

  test('appDateString returns normalized date string', () {
    final beforeCutoff = DateTime(2026, 2, 18, 1, 0);
    final afterCutoff = DateTime(2026, 2, 18, 10, 0);

    expect(CalendarUtils.appDateString(beforeCutoff), '2026-02-17');
    expect(CalendarUtils.appDateString(afterCutoff), '2026-02-18');
  });
}
