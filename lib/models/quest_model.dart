/// 카테고리
enum Category {
  study('학업', '📚'),
  health('건강', '💪'),
  selfDevelopment('자기계발', '🚀'),
  life('생활', '🏠');

  final String displayName;
  final String icon;

  const Category(this.displayName, this.icon);
}

/// 난이도
enum Difficulty {
  easy,
  normal,
  hard;

  String get displayName {
    switch (this) {
      case Difficulty.easy:
        return '쉬움';
      case Difficulty.normal:
        return '보통';
      case Difficulty.hard:
        return '어려움';
    }
  }
}

/// 퀘스트 타입
enum QuestType {
  main,
  sub,
  habit,
  todo,
  daily;
}

/// 퀘스트 모델
class Quest {
  final String id;
  final String title;
  final String category;
  final bool completed;
  final String date; // YYYY-MM-DD
  final String? reminderTime; // HH:mm

  // ✅ (현재는 UI에서 숨겼지만) 기존 데이터 호환을 위해 유지
  final int expReward;
  final int goldReward;

  final QuestType questType;
  final Difficulty difficulty;

  // ✅ 업적 연동을 위한 추가 필드들
  final int? createdAt; // millisecondsSinceEpoch (생성 시각)
  final int? completedAt; // millisecondsSinceEpoch (완료 시각)
  final int? deadlineAt; // millisecondsSinceEpoch (마감 시각)

  /// ✅ 타이머 누적(분) - 기존 주석상 큰 퀘스트 판단에 사용
  final int? durationMinutes;

  // =========================================
  // ✅ [추가] 큰 퀘스트/업적 판정을 위한 필드
  // =========================================

  /// 진행 중 체크리스트 완료 개수 (Condition B 입력값)
  /// ※ 실제 체크리스트 모델이 따로 있으면, Provider에서 계산해서 여기에 저장/반영하면 됨
  final int? checklistCompletedCount;

  /// 완료 시점 스냅샷(완료 순간 확정 저장)
  final int? finalTimerMinutes;
  final int? finalChecklistCompletedCount;

  /// 완료 시점에 "큰 퀘스트"였는지 확정 저장(스냅샷)
  final bool? isBigQuest;

  const Quest({
    required this.id,
    required this.title,
    required this.category,
    required this.completed,
    required this.date,
    this.reminderTime,
    required this.expReward,
    required this.goldReward,
    required this.questType,
    required this.difficulty,
    this.createdAt,
    this.completedAt,
    this.deadlineAt,
    this.durationMinutes,

    // ✅ 추가
    this.checklistCompletedCount,
    this.finalTimerMinutes,
    this.finalChecklistCompletedCount,
    this.isBigQuest,
  });

  // ✅ 안전한 int 파싱(예: json에 num/double로 들어오는 경우 방지)
  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  static bool? _asBool(dynamic v) {
    if (v == null) return null;
    if (v is bool) return v;
    if (v is String) {
      if (v.toLowerCase() == 'true') return true;
      if (v.toLowerCase() == 'false') return false;
    }
    return null;
  }

  factory Quest.fromJson(Map<String, dynamic> json) {
    return Quest(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      completed: json['completed'] as bool? ?? false,
      date: json['date'] as String,
      reminderTime: json['reminderTime'] as String?,

      expReward: (json['expReward'] as num?)?.toInt() ?? 0,
      goldReward: (json['goldReward'] as num?)?.toInt() ?? 0,

      questType: QuestType.values.firstWhere(
            (e) => e.name == json['questType'],
        orElse: () => QuestType.daily,
      ),
      difficulty: Difficulty.values.firstWhere(
            (e) => e.name == json['difficulty'],
        orElse: () => Difficulty.normal,
      ),

      // ✅ 기존 필드
      createdAt: _asInt(json['createdAt']),
      completedAt: _asInt(json['completedAt']),
      deadlineAt: _asInt(json['deadlineAt']),
      durationMinutes: _asInt(json['durationMinutes']),

      // ✅ 추가 필드 (구버전 데이터는 null로 안전 처리)
      checklistCompletedCount: _asInt(json['checklistCompletedCount']),
      finalTimerMinutes: _asInt(json['finalTimerMinutes']),
      finalChecklistCompletedCount: _asInt(json['finalChecklistCompletedCount']),
      isBigQuest: _asBool(json['isBigQuest']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'completed': completed,
      'date': date,
      'reminderTime': reminderTime,
      'expReward': expReward,
      'goldReward': goldReward,
      'questType': questType.name,
      'difficulty': difficulty.name,

      // ✅ 기존
      'createdAt': createdAt,
      'completedAt': completedAt,
      'deadlineAt': deadlineAt,
      'durationMinutes': durationMinutes,

      // ✅ 추가
      'checklistCompletedCount': checklistCompletedCount,
      'finalTimerMinutes': finalTimerMinutes,
      'finalChecklistCompletedCount': finalChecklistCompletedCount,
      'isBigQuest': isBigQuest,
    };
  }

  Quest copyWith({
    String? id,
    String? title,
    String? category,
    bool? completed,
    String? date,
    String? reminderTime,
    int? expReward,
    int? goldReward,
    QuestType? questType,
    Difficulty? difficulty,

    // ✅ 기존
    int? createdAt,
    int? completedAt,
    int? deadlineAt,
    int? durationMinutes,

    // ✅ 추가
    int? checklistCompletedCount,
    int? finalTimerMinutes,
    int? finalChecklistCompletedCount,
    bool? isBigQuest,
  }) {
    return Quest(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      completed: completed ?? this.completed,
      date: date ?? this.date,
      reminderTime: reminderTime ?? this.reminderTime,
      expReward: expReward ?? this.expReward,
      goldReward: goldReward ?? this.goldReward,
      questType: questType ?? this.questType,
      difficulty: difficulty ?? this.difficulty,

      // ✅ 기존
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      deadlineAt: deadlineAt ?? this.deadlineAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,

      // ✅ 추가
      checklistCompletedCount:
      checklistCompletedCount ?? this.checklistCompletedCount,
      finalTimerMinutes: finalTimerMinutes ?? this.finalTimerMinutes,
      finalChecklistCompletedCount:
      finalChecklistCompletedCount ?? this.finalChecklistCompletedCount,
      isBigQuest: isBigQuest ?? this.isBigQuest,
    );
  }
}

/// 습관 모델
class Habit {
  final String id;
  final String title;
  final String category;
  final int completionCount;
  final int totalCompletions;
  final int expReward;
  final int goldReward;
  final Difficulty difficulty;
  final int? lastCompletedAt;
  final int? comboCount;

  const Habit({
    required this.id,
    required this.title,
    required this.category,
    required this.completionCount,
    required this.totalCompletions,
    required this.expReward,
    required this.goldReward,
    required this.difficulty,
    this.lastCompletedAt,
    this.comboCount,
  });

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      completionCount: (json['completionCount'] as num?)?.toInt() ?? 0,
      totalCompletions: (json['totalCompletions'] as num?)?.toInt() ?? 0,
      expReward: (json['expReward'] as num?)?.toInt() ?? 0,
      goldReward: (json['goldReward'] as num?)?.toInt() ?? 0,
      difficulty: Difficulty.values.firstWhere(
            (e) => e.name == json['difficulty'],
        orElse: () => Difficulty.normal,
      ),
      lastCompletedAt: (json['lastCompletedAt'] as num?)?.toInt(),
      comboCount: (json['comboCount'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'completionCount': completionCount,
      'totalCompletions': totalCompletions,
      'expReward': expReward,
      'goldReward': goldReward,
      'difficulty': difficulty.name,
      'lastCompletedAt': lastCompletedAt,
      'comboCount': comboCount,
    };
  }

  Habit copyWith({
    String? id,
    String? title,
    String? category,
    int? completionCount,
    int? totalCompletions,
    int? expReward,
    int? goldReward,
    Difficulty? difficulty,
    int? lastCompletedAt,
    int? comboCount,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      completionCount: completionCount ?? this.completionCount,
      totalCompletions: totalCompletions ?? this.totalCompletions,
      expReward: expReward ?? this.expReward,
      goldReward: goldReward ?? this.goldReward,
      difficulty: difficulty ?? this.difficulty,
      lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
      comboCount: comboCount ?? this.comboCount,
    );
  }
}

/// ToDo 모델
class ToDo {
  final String id;
  final String title;
  final String category;
  final bool completed;
  final String? dueDate;
  final String? dueTime;
  final int expReward;
  final int goldReward;
  final Difficulty difficulty;
  final int createdAt;
  final String description;

  const ToDo({
    required this.id,
    required this.title,
    required this.category,
    required this.completed,
    this.dueDate,
    this.dueTime,
    required this.expReward,
    required this.goldReward,
    required this.difficulty,
    required this.createdAt,
    required this.description,
  });

  factory ToDo.fromJson(Map<String, dynamic> json) {
    return ToDo(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      completed: json['completed'] as bool? ?? false,
      dueDate: json['dueDate'] as String?,
      dueTime: json['dueTime'] as String?,
      expReward: (json['expReward'] as num?)?.toInt() ?? 0,
      goldReward: (json['goldReward'] as num?)?.toInt() ?? 0,
      difficulty: Difficulty.values.firstWhere(
            (e) => e.name == json['difficulty'],
        orElse: () => Difficulty.normal,
      ),
      createdAt: (json['createdAt'] as num?)?.toInt() ??
          DateTime.now().millisecondsSinceEpoch,
      description: (json['description'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'completed': completed,
      'dueDate': dueDate,
      'dueTime': dueTime,
      'expReward': expReward,
      'goldReward': goldReward,
      'difficulty': difficulty.name,
      'createdAt': createdAt,
      'description': description,
    };
  }

  ToDo copyWith({
    String? id,
    String? title,
    String? category,
    bool? completed,
    String? dueDate,
    String? dueTime,
    int? expReward,
    int? goldReward,
    Difficulty? difficulty,
    int? createdAt,
    String? description,
  }) {
    return ToDo(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      completed: completed ?? this.completed,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      expReward: expReward ?? this.expReward,
      goldReward: goldReward ?? this.goldReward,
      difficulty: difficulty ?? this.difficulty,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
    );
  }

  bool get isActive =>
      !completed &&
          (dueDate == null || DateTime.parse(dueDate!).isAfter(DateTime.now()));
}
