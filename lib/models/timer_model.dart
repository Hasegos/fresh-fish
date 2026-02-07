import 'package:flutter/material.dart';

/// [TimerSession]
/// 실제 타이머로 집중한 시간을 기록하는 데이터 모델입니다.
/// UserData의 timerSessions 리스트에서 사용됩니다.
class TimerSession {
  final String id;
  final String category;
  final int durationSeconds;
  final int startTime;
  final int endTime;
  final bool completed;

  TimerSession({
    required this.id,
    required this.category,
    required this.durationSeconds,
    required this.startTime,
    required this.endTime,
    required this.completed,
  });

  // [Why] UserData.fromJson에서 호출하므로 반드시 필요합니다.
  factory TimerSession.fromJson(Map<String, dynamic> json) {
    return TimerSession(
      id: json['id'] as String,
      category: json['category'] as String,
      durationSeconds: json['durationSeconds'] as int,
      startTime: json['startTime'] as int,
      endTime: json['endTime'] as int,
      completed: json['completed'] as bool? ?? false,
    );
  }

  // [Why] UserData.toJson에서 호출하므로 반드시 필요합니다.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'durationSeconds': durationSeconds,
      'startTime': startTime,
      'endTime': endTime,
      'completed': completed,
    };
  }
}

/// [TimerCategory]
/// 타이머 화면의 그리드 목록에 표시될 카테고리 정보입니다. (UI용)
class TimerCategory {
  final String name;
  final String icon;
  final String color; // #FFFFFF 형식

  const TimerCategory({
    required this.name,
    required this.icon,
    required this.color,
  });

  Color toColor() {
    final buffer = StringBuffer();
    if (color.length == 6 || color.length == 7) buffer.write('ff');
    buffer.write(color.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

/// [TimerRunState]
/// 백그라운드 타이머 상태를 로컬에 저장하기 위한 모델입니다.
class TimerRunState {
  final bool isRunning;
  final String? category;
  final int elapsedSeconds;
  final int? startedAtMillis;

  const TimerRunState({
    required this.isRunning,
    required this.category,
    required this.elapsedSeconds,
    required this.startedAtMillis,
  });

  factory TimerRunState.fromJson(Map<String, dynamic> json) {
    return TimerRunState(
      isRunning: json['isRunning'] as bool? ?? false,
      category: json['category'] as String?,
      elapsedSeconds: json['elapsedSeconds'] as int? ?? 0,
      startedAtMillis: json['startedAtMillis'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isRunning': isRunning,
      'category': category,
      'elapsedSeconds': elapsedSeconds,
      'startedAtMillis': startedAtMillis,
    };
  }
}