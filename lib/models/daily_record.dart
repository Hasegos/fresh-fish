import 'quest.dart';

class DailyRecord {
  final String date;
  final List<Quest> quests;
  final int completedCount;
  final int totalCount;

  DailyRecord({
    required this.date,
    required this.quests,
    required this.completedCount,
    required this.totalCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'quests': quests.map((q) => q.toJson()).toList(),
      'completedCount': completedCount,
      'totalCount': totalCount,
    };
  }

  factory DailyRecord.fromJson(Map<String, dynamic> json) {
    return DailyRecord(
      date: json['date'] ?? '',
      quests: (json['quests'] as List<dynamic>?)
              ?.map((q) => Quest.fromJson(q))
              .toList() ??
          [],
      completedCount: json['completedCount'] ?? 0,
      totalCount: json['totalCount'] ?? 0,
    );
  }
}