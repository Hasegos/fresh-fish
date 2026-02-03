/// 날짜 포맷 헬퍼
library;

/// 날짜 포맷 헬퍼 클래스
class DateFormatter {
  /// YYYY-MM-DD 형식으로 포맷
  static String toYYYYMMDD(DateTime date) {
    return date.toIso8601String().split('T')[0];
  }

  /// DateTime을 YYYY-MM-DD 문자열로
  static String formatDate(DateTime date) {
    return toYYYYMMDD(date);
  }

  /// YYYY-MM-DD 문자열을 DateTime으로
  static DateTime parseDate(String dateString) {
    return DateTime.parse(dateString);
  }

  /// 두 날짜가 같은 날인지 확인
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// 오늘 날짜를 YYYY-MM-DD 형식으로
  static String today() {
    return toYYYYMMDD(DateTime.now());
  }

  /// 어제 날짜를 YYYY-MM-DD 형식으로
  static String yesterday() {
    return toYYYYMMDD(DateTime.now().subtract(const Duration(days: 1)));
  }

  /// 내일 날짜를 YYYY-MM-DD 형식으로
  static String tomorrow() {
    return toYYYYMMDD(DateTime.now().add(const Duration(days: 1)));
  }

  /// 한국어 형식으로 날짜 표시 (예: 2024년 1월 15일)
  static String toKoreanFormat(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  /// 간단한 한국어 형식 (예: 1월 15일)
  static String toShortKoreanFormat(DateTime date) {
    return '${date.month}월 ${date.day}일';
  }

  /// 요일 포함 형식 (예: 1월 15일 (월))
  static String toKoreanFormatWithWeekday(DateTime date) {
    final weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    final weekday = weekdays[date.weekday % 7];
    return '${date.month}월 ${date.day}일 ($weekday)';
  }

  /// 상대 날짜 표시 (오늘, 어제, 내일, 또는 날짜)
  static String toRelativeFormat(DateTime date) {
    final now = DateTime.now();
    
    if (isSameDay(date, now)) {
      return '오늘';
    } else if (isSameDay(date, now.subtract(const Duration(days: 1)))) {
      return '어제';
    } else if (isSameDay(date, now.add(const Duration(days: 1)))) {
      return '내일';
    }
    
    return toShortKoreanFormat(date);
  }

  /// 주차 번호 계산
  static int getWeekNumber(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }

  /// 시간 포맷 (HH:mm)
  static String formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// 날짜와 시간 포맷 (YYYY-MM-DD HH:mm)
  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} ${formatTime(dateTime)}';
  }

  /// D-Day 계산 (양수: 남은 일, 음수: 지난 일)
  static int calculateDDay(DateTime targetDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
    return target.difference(today).inDays;
  }

  /// D-Day 문자열 (D-3, D-Day, D+3)
  static String formatDDay(DateTime targetDate) {
    final dDay = calculateDDay(targetDate);
    
    if (dDay > 0) {
      return 'D-$dDay';
    } else if (dDay == 0) {
      return 'D-Day';
    } else {
      return 'D+${-dDay}';
    }
  }
}

/// 시간 포맷 헬퍼 클래스
class TimeFormatter {
  /// 밀리초를 시:분:초로 변환
  static String formatMilliseconds(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    return formatDuration(duration);
  }

  /// Duration을 시:분:초로 변환
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}시간 ${minutes}분';
    } else if (minutes > 0) {
      return '${minutes}분 ${seconds}초';
    } else {
      return '${seconds}초';
    }
  }

  /// 간단한 시간 포맷 (시간만 또는 분만)
  static String formatSimple(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}시간';
    } else {
      return '${minutes}분';
    }
  }

  /// 남은 시간 포맷 (2일 3시간, 5시간, 30분 등)
  static String formatTimeRemaining(double hours) {
    if (hours < 1) {
      final minutes = (hours * 60).round();
      return '$minutes분';
    } else if (hours < 24) {
      return '${hours.round()}시간';
    } else {
      final days = (hours / 24).floor();
      final remainingHours = (hours % 24).round();
      if (remainingHours > 0) {
        return '$days일 $remainingHours시간';
      } else {
        return '$days일';
      }
    }
  }

  /// 시간을 AM/PM 형식으로
  static String toAmPmFormat(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    
    if (hour == 0) {
      return '오전 12:$minute';
    } else if (hour < 12) {
      return '오전 $hour:$minute';
    } else if (hour == 12) {
      return '오후 12:$minute';
    } else {
      return '오후 ${hour - 12}:$minute';
    }
  }
}

/// 숫자 포맷 헬퍼 클래스
class NumberFormatter {
  /// 천 단위 구분자 추가 (1,234,567)
  static String formatWithCommas(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  /// 백분율 포맷 (소수점 1자리)
  static String formatPercentage(double value, {int decimals = 1}) {
    return '${value.toStringAsFixed(decimals)}%';
  }

  /// 짧은 숫자 표기 (1K, 1M 등)
  static String formatShort(int number) {
    if (number < 1000) {
      return number.toString();
    } else if (number < 1000000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    }
  }

  /// 골드 포맷 (1,234 G)
  static String formatGold(int gold) {
    return '${formatWithCommas(gold)} G';
  }

  /// 경험치 포맷
  static String formatExp(int exp) {
    return '${formatWithCommas(exp)} EXP';
  }
}
