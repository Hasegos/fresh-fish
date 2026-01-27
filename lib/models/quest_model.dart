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
  final int expReward;
  final int goldReward;
  final QuestType questType;
  final Difficulty difficulty;

  Quest({
    required this.id,
    required this.title,
    required this.category,
    required this.completed,
    required this.date,
    required this.expReward,
    required this.goldReward,
    required this.questType,
    required this.difficulty,
  });

  factory Quest.fromJson(Map<String, dynamic> json) {
    return Quest(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      completed: json['completed'] as bool? ?? false,
      date: json['date'] as String,
      expReward: json['expReward'] as int? ?? 0,
      goldReward: json['goldReward'] as int? ?? 0,
      questType: QuestType.values.firstWhere(
        (e) => e.name == json['questType'],
        orElse: () => QuestType.daily,
      ),
      difficulty: Difficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => Difficulty.normal,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'completed': completed,
      'date': date,
      'expReward': expReward,
      'goldReward': goldReward,
      'questType': questType.name,
      'difficulty': difficulty.name,
    };
  }

  Quest copyWith({
    String? id,
    String? title,
    String? category,
    bool? completed,
    String? date,
    int? expReward,
    int? goldReward,
    QuestType? questType,
    Difficulty? difficulty,
  }) {
    return Quest(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      completed: completed ?? this.completed,
      date: date ?? this.date,
      expReward: expReward ?? this.expReward,
      goldReward: goldReward ?? this.goldReward,
      questType: questType ?? this.questType,
      difficulty: difficulty ?? this.difficulty,
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

  Habit({
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
      completionCount: json['completionCount'] as int? ?? 0,
      totalCompletions: json['totalCompletions'] as int? ?? 0,
      expReward: json['expReward'] as int? ?? 0,
      goldReward: json['goldReward'] as int? ?? 0,
      difficulty: Difficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => Difficulty.normal,
      ),
      lastCompletedAt: json['lastCompletedAt'] as int?,
      comboCount: json['comboCount'] as int?,
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

  ToDo({
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
      expReward: json['expReward'] as int? ?? 0,
      goldReward: json['goldReward'] as int? ?? 0,
      difficulty: Difficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => Difficulty.normal,
      ),
      createdAt: json['createdAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      description: json['description'] as String,
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

  bool get isActive => !completed && (dueDate == null || DateTime.parse(dueDate!).isAfter(DateTime.now()));
}
