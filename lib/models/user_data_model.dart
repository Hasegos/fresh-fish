import 'fish_model.dart';
import 'quest_model.dart';
import 'decoration_model.dart';
import 'achievement_model.dart';

/// 일일 기록
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

/// 기록 상태
enum RecordStatus {
  success, // 완료
  partial, // 일부 완료
  fail,    // 실패
  none;    // 데이터 없음
}

/// 커스텀 보상
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

/// 사용자 데이터
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
  });

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
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      notificationTime: notificationTime ?? this.notificationTime,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      waterQuality: waterQuality ?? this.waterQuality,
      achievements: achievements ?? this.achievements,
      customRewards: customRewards ?? this.customRewards,
      decorations: decorations ?? this.decorations,
      ownedDecorations: ownedDecorations ?? this.ownedDecorations,
    );
  }
}
