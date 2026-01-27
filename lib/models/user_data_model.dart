import 'fish_model.dart';
import 'quest_model.dart';
import 'timer_model.dart';

/// [PlacedDecoration]
/// 어항 내에 실제 배치된 장식의 정보를 담습니다.
/// 유저가 장식을 어디에 두었는지 위치값(x, y)을 저장합니다.
class PlacedDecoration {
  final String decorationId;
  final double x; // 화면 가로 위치 (%)
  final double y; // 화면 세로 위치 (%)

  PlacedDecoration({
    required this.decorationId,
    required this.x,
    required this.y,
  });

  factory PlacedDecoration.fromJson(Map<String, dynamic> json) {
    return PlacedDecoration(
      decorationId: json['decorationId'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'decorationId': decorationId,
      'x': x,
      'y': y,
    };
  }

  PlacedDecoration copyWith({
    String? decorationId,
    double? x,
    double? y,
  }) {
    return PlacedDecoration(
      decorationId: decorationId ?? this.decorationId,
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }
}

/// [DailyRecord]
/// 특정 날짜의 수행 실적을 기록합니다.
class DailyRecord {
  final String date; // YYYY-MM-DD
  final int totalQuests;
  final int completedQuests;
  final RecordStatus status;

  DailyRecord({
    required this.date,
    required this.totalQuests,
    required this.completedQuests,
    required this.status,
  });

  factory DailyRecord.fromJson(Map<String, dynamic> json) {
    return DailyRecord(
      date: json['date'] as String,
      totalQuests: json['totalQuests'] as int? ?? 0,
      completedQuests: json['completedQuests'] as int? ?? 0,
      status: RecordStatus.values.firstWhere(
            (e) => e.name == json['status'],
        orElse: () => RecordStatus.none,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'totalQuests': totalQuests,
      'completedQuests': completedQuests,
      'status': status.name,
    };
  }
}

/// [Achievement]
/// 유저가 달성할 수 있는 목표(업적) 정보입니다.
class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  bool unlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.unlocked = false,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      unlocked: json['unlocked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'unlocked': unlocked,
    };
  }
}

/// [RecordStatus]
/// 하루 기록의 성공 여부를 나타내는 열거형 타입입니다.
enum RecordStatus {
  success,
  partial,
  fail,
  none;
}

/// [CustomReward]
/// 유저가 직접 설정한 보상 아이템입니다.
class CustomReward {
  final String id;
  final String title;
  final int cost;
  final bool claimed;

  CustomReward({
    required this.id,
    required this.title,
    required this.cost,
    required this.claimed,
  });

  factory CustomReward.fromJson(Map<String, dynamic> json) {
    return CustomReward(
      id: json['id'] as String,
      title: json['title'] as String,
      cost: json['cost'] as int,
      claimed: json['claimed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'cost': cost,
      'claimed': claimed,
    };
  }

  CustomReward copyWith({
    String? id,
    String? title,
    int? cost,
    bool? claimed,
  }) {
    return CustomReward(
      id: id ?? this.id,
      title: title ?? this.title,
      cost: cost ?? this.cost,
      claimed: claimed ?? this.claimed,
    );
  }
}

/// [UserData]
/// 애플리케이션의 최상위 데이터 모델입니다.
/// 모든 리스트와 상태 정보를 포함하며, UI에서 접근하기 쉬운 계산 로직을 포함합니다.
class UserData {
  final String id;
  final Fish fish;
  final int gold;
  final String currentDate;
  final List<Quest> quests;
  final List<Habit> habits;
  final List<ToDo> todos;
  final List<DailyRecord> history;
  final bool onboardingCompleted;
  final String? notificationTime;
  final List<String> selectedCategories;
  final int waterQuality;
  final List<Achievement> achievements;
  final List<CustomReward> customRewards;
  final List<PlacedDecoration> decorations;
  final List<String> ownedDecorations;
  final List<TimerSession> timerSessions;

  UserData({
    required this.id,
    required this.fish,
    required this.gold,
    required this.currentDate,
    required this.quests,
    required this.habits,
    required this.todos,
    required this.history,
    required this.onboardingCompleted,
    this.notificationTime,
    required this.selectedCategories,
    required this.waterQuality,
    required this.achievements,
    required this.customRewards,
    required this.decorations,
    required this.ownedDecorations,
    required this.timerSessions,
  });

  // --- UI 편의를 위한 계산 로직 (Getters) ---

  // 오늘 날짜 문자열 (YYYY-MM-DD)
  String get _todayStr => DateTime.now().toIso8601String().split('T')[0];

  // 오늘 완료한 퀘스트 개수
  int get todayCompletedQuests => quests
      .where((q) => q.date.toString() == _todayStr && q.completed)
      .length;

  // 오늘 전체 퀘스트 개수
  int get todayTotalQuests => quests
      .where((q) => q.date.toString() == _todayStr)
      .length;

  // 완료한 ToDo 개수
  int get completedTodos => todos.where((t) => t.completed).length;

  // ---------------------------------------

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] as String,
      fish: Fish.fromJson(json['fish'] as Map<String, dynamic>),
      gold: json['gold'] as int? ?? 0,
      currentDate: json['currentDate'] as String,
      quests: (json['quests'] as List<dynamic>?)
          ?.map((e) => Quest.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      habits: (json['habits'] as List<dynamic>?)
          ?.map((e) => Habit.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      todos: (json['todos'] as List<dynamic>?)
          ?.map((e) => ToDo.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      history: (json['history'] as List<dynamic>?)
          ?.map((e) => DailyRecord.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
      notificationTime: json['notificationTime'] as String?,
      selectedCategories: (json['selectedCategories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      waterQuality: json['waterQuality'] as int? ?? 100,
      achievements: (json['achievements'] as List<dynamic>?)
          ?.map((e) => Achievement.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      customRewards: (json['customRewards'] as List<dynamic>?)
          ?.map((e) => CustomReward.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      decorations: (json['decorations'] as List<dynamic>?)
          ?.map((e) => PlacedDecoration.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      ownedDecorations: (json['ownedDecorations'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      timerSessions: (json['timerSessions'] as List<dynamic>?)
          ?.map((e) => TimerSession.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fish': fish.toJson(),
      'gold': gold,
      'currentDate': currentDate,
      'quests': quests.map((e) => e.toJson()).toList(),
      'habits': habits.map((e) => e.toJson()).toList(),
      'todos': todos.map((e) => e.toJson()).toList(),
      'history': history.map((e) => e.toJson()).toList(),
      'onboardingCompleted': onboardingCompleted,
      'notificationTime': notificationTime,
      'selectedCategories': selectedCategories,
      'waterQuality': waterQuality,
      'achievements': achievements.map((e) => e.toJson()).toList(),
      'customRewards': customRewards.map((e) => e.toJson()).toList(),
      'decorations': decorations.map((e) => e.toJson()).toList(),
      'ownedDecorations': ownedDecorations,
      'timerSessions': timerSessions.map((e) => e.toJson()).toList(),
    };
  }

  UserData copyWith({
    String? id,
    Fish? fish,
    int? gold,
    String? currentDate,
    List<Quest>? quests,
    List<Habit>? habits,
    List<ToDo>? todos,
    List<DailyRecord>? history,
    bool? onboardingCompleted,
    String? notificationTime,
    List<String>? selectedCategories,
    int? waterQuality,
    List<Achievement>? achievements,
    List<CustomReward>? customRewards,
    List<PlacedDecoration>? decorations,
    List<String>? ownedDecorations,
    List<TimerSession>? timerSessions,
  }) {
    return UserData(
      id: id ?? this.id,
      fish: fish ?? this.fish,
      gold: gold ?? this.gold,
      currentDate: currentDate ?? this.currentDate,
      quests: quests ?? this.quests,
      habits: habits ?? this.habits,
      todos: todos ?? this.todos,
      history: history ?? this.history,
      onboardingCompleted: onboardingCompleted != null ? onboardingCompleted : this.onboardingCompleted,
      notificationTime: notificationTime ?? this.notificationTime,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      waterQuality: waterQuality ?? this.waterQuality,
      achievements: achievements ?? this.achievements,
      customRewards: customRewards ?? this.customRewards,
      decorations: decorations ?? this.decorations,
      ownedDecorations: ownedDecorations ?? this.ownedDecorations,
      timerSessions: timerSessions ?? this.timerSessions,
    );
  }
}