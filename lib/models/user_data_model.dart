import 'fish_model.dart';
import 'quest_model.dart';
import 'timer_model.dart';
import '../data/timer_categories.dart';

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

/// [PomodoroSettings]
/// 포모도로 모드 설정 정보입니다.
class PomodoroSettings {
  final bool enabled;
  final int focusMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final int sessionsPerCycle;

  const PomodoroSettings({
    this.enabled = false,
    this.focusMinutes = 25,
    this.shortBreakMinutes = 5,
    this.longBreakMinutes = 15,
    this.sessionsPerCycle = 4,
  });

  factory PomodoroSettings.fromJson(Map<String, dynamic> json) {
    return PomodoroSettings(
      enabled: json['enabled'] as bool? ?? false,
      focusMinutes: json['focusMinutes'] as int? ?? 25,
      shortBreakMinutes: json['shortBreakMinutes'] as int? ?? 5,
      longBreakMinutes: json['longBreakMinutes'] as int? ?? 15,
      sessionsPerCycle: json['sessionsPerCycle'] as int? ?? 4,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'focusMinutes': focusMinutes,
      'shortBreakMinutes': shortBreakMinutes,
      'longBreakMinutes': longBreakMinutes,
      'sessionsPerCycle': sessionsPerCycle,
    };
  }

  PomodoroSettings copyWith({
    bool? enabled,
    int? focusMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    int? sessionsPerCycle,
  }) {
    return PomodoroSettings(
      enabled: enabled ?? this.enabled,
      focusMinutes: focusMinutes ?? this.focusMinutes,
      shortBreakMinutes: shortBreakMinutes ?? this.shortBreakMinutes,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
      sessionsPerCycle: sessionsPerCycle ?? this.sessionsPerCycle,
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
  final List<ToDo> todos;
  final List<DailyRecord> history;
  final bool onboardingCompleted;
  final String? notificationTime;
  final List<String> selectedCategories;
  final int waterQuality;
  final List<Achievement> achievements;
  final List<TimerSession> timerSessions;
  final List<TimerCategory> timerCategories;
  final PomodoroSettings pomodoroSettings;

  UserData({
    required this.id,
    required this.fish,
    required this.gold,
    required this.currentDate,
    required this.quests,
    required this.todos,
    required this.history,
    required this.onboardingCompleted,
    this.notificationTime,
    required this.selectedCategories,
    required this.waterQuality,
    required this.achievements,
    required this.timerSessions,
    required this.timerCategories,
    required this.pomodoroSettings,
  });

  // --- UI 편의를 위한 계산 로직 (Getters) ---

  // 오늘 날짜 문자열 (YYYY-MM-DD)
  String get _todayStr => DateTime.now().toIso8601String().split('T')[0];

  // 오늘 완료한 퀘스트 개수
  int get todayCompletedQuests =>
      quests.where((q) => q.date.toString() == _todayStr && q.completed).length;

  // 오늘 전체 퀘스트 개수
  int get todayTotalQuests =>
      quests.where((q) => q.date.toString() == _todayStr).length;

  // 완료한 ToDo 개수
  int get completedTodos => todos.where((t) => t.completed).length;

  // ✅ 큰 퀘스트 클리어 누적(스냅샷 우선 + 구버전 fallback)
  int get bigQuestClears {
    bool isBigQuestFallback(Quest q) {
      final timer = q.durationMinutes ?? 0;
      final checklist = q.checklistCompletedCount ?? 0;

      final conditionA = (timer >= 60) && (q.difficulty.index >= Difficulty.normal.index);
      final conditionB = (checklist >= 5);
      return conditionA || conditionB;
    }

    int cnt = 0;
    for (final q in quests) {
      if (q.completed != true) continue;

      if (q.isBigQuest == true) {
        cnt++;
        continue;
      }
      if (q.isBigQuest == false) continue;

      // 스냅샷이 없는 구버전 데이터는 현재 필드로 fallback 계산
      if (isBigQuestFallback(q)) cnt++;
    }
    return cnt;
  }

  // ---------------------------------------

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] as String,
      fish: Fish.fromJson(json['fish'] as Map<String, dynamic>),
      gold: json['gold'] as int? ?? 0,
      currentDate: json['currentDate'] as String,
      quests: (json['quests'] as List<dynamic>?)
          ?.map((e) => Quest.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      todos: (json['todos'] as List<dynamic>?)
          ?.map((e) => ToDo.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      history: (json['history'] as List<dynamic>?)
          ?.map((e) => DailyRecord.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
      notificationTime: json['notificationTime'] as String?,
      selectedCategories: (json['selectedCategories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
          [],
      waterQuality: json['waterQuality'] as int? ?? 100,
      achievements: (json['achievements'] as List<dynamic>?)
          ?.map((e) => Achievement.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      timerSessions: (json['timerSessions'] as List<dynamic>?)
          ?.map((e) => TimerSession.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      timerCategories: (json['timerCategories'] as List<dynamic>?)
          ?.map((e) => TimerCategory.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      pomodoroSettings: json['pomodoroSettings'] == null
          ? const PomodoroSettings()
          : PomodoroSettings.fromJson(json['pomodoroSettings'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fish': fish.toJson(),
      'gold': gold,
      'currentDate': currentDate,
      'quests': quests.map((e) => e.toJson()).toList(),
      'todos': todos.map((e) => e.toJson()).toList(),
      'history': history.map((e) => e.toJson()).toList(),
      'onboardingCompleted': onboardingCompleted,
      'notificationTime': notificationTime,
      'selectedCategories': selectedCategories,
      'waterQuality': waterQuality,
      'achievements': achievements.map((e) => e.toJson()).toList(),
      'timerSessions': timerSessions.map((e) => e.toJson()).toList(),
      'timerCategories': timerCategories.map((e) => e.toJson()).toList(),
      'pomodoroSettings': pomodoroSettings.toJson(),
    };
  }

  UserData copyWith({
    String? id,
    Fish? fish,
    int? gold,
    String? currentDate,
    List<Quest>? quests,
    List<ToDo>? todos,
    List<DailyRecord>? history,
    bool? onboardingCompleted,
    String? notificationTime,
    List<String>? selectedCategories,
    int? waterQuality,
    List<Achievement>? achievements,
    List<String>? ownedDecorations,
    List<TimerSession>? timerSessions,
    List<TimerCategory>? timerCategories,
    PomodoroSettings? pomodoroSettings,
  }) {
    return UserData(
      id: id ?? this.id,
      fish: fish ?? this.fish,
      gold: gold ?? this.gold,
      currentDate: currentDate ?? this.currentDate,
      quests: quests ?? this.quests,
      todos: todos ?? this.todos,
      history: history ?? this.history,
      onboardingCompleted:
      onboardingCompleted != null ? onboardingCompleted : this.onboardingCompleted,
      notificationTime: notificationTime ?? this.notificationTime,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      waterQuality: waterQuality ?? this.waterQuality,
      achievements: achievements ?? this.achievements,
      timerSessions: timerSessions ?? this.timerSessions,
      timerCategories: timerCategories ?? this.timerCategories,
      pomodoroSettings: pomodoroSettings ?? this.pomodoroSettings,
    );
  }
}
