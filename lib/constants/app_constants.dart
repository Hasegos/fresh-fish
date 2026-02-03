/// Time constants (밀리초 단위)
class TimeConstants {
  /// 총 성장 시간 (72시간)
  static const int totalGrowthTime = 72 * 60 * 60 * 1000;

  /// 알 → 치어 시간 (24시간)
  static const int eggToBabyTime = 24 * 60 * 60 * 1000;

  /// 치어 → 성체 시간 (48시간)
  static const int babyToAdultTime = 48 * 60 * 60 * 1000;

  /// 1시간 (밀리초)
  static const int oneHour = 60 * 60 * 1000;

  /// 1일 (밀리초)
  static const int oneDay = 24 * 60 * 60 * 1000;
}

/// 경험치 및 레벨 상수
class LevelConstants {
  /// 레벨당 필요 EXP
  static const int expPerLevel = 100;

  /// 최대 표시 레벨
  static const int maxDisplayLevel = 99;

  /// 진화 레벨 기준
  static const int eggMaxLevel = 3;
  static const int smallMaxLevel = 7;
  static const int adultMaxLevel = 12;
  // 13+ 전설
}

/// 퀘스트 상수
class QuestConstants {
  /// 기본 일일 퀘스트 개수
  static const int defaultDailyQuestCount = 5;

  /// 하루 최대 퀘스트 수
  static const int maxQuestsPerDay = 10;

  /// 최대 습관 수
  static const int maxHabits = 20;

  /// 최대 할일 수
  static const int maxTodos = 50;
}

/// 보상 상수
class RewardConstants {
  /// 난이도별 EXP 보상
  static const Map<String, int> expRewards = {
    'easy': 15,
    'normal': 25,
    'hard': 40,
  };

  /// 난이도별 골드 보상
  static const Map<String, int> goldRewards = {
    'easy': 8,
    'normal': 15,
    'hard': 25,
  };

  /// 습관 기본 보상
  static const int habitBaseExp = 10;
  static const int habitBaseGold = 5;
  static const int habitComboMultiplier = 2;
}

/// 수질 상수
class WaterQualityConstants {
  /// 초기 수질
  static const int initial = 50;

  /// 최대 수질
  static const int max = 100;

  /// 최소 수질
  static const int min = 0;

  /// 일일 수질 감소율
  static const int dailyDecay = 5;

  /// 퀘스트 완료당 수질 증가
  static const int questBonus = 3;
}

/// 물고기 상수
class FishConstants {
  /// 초기 HP (포만도)
  static const int initialHp = 100;

  /// 최대 HP
  static const int maxHp = 100;

  /// 일일 HP 감소
  static const int dailyHpDecay = 10;

  /// 퀘스트 완료당 HP 회복
  static const int questHpBonus = 5;
}

/// 저장소 키
class StorageKeys {
  static const String userData = 'my_tiny_aquarium_data';
  static const String userId = 'my_tiny_aquarium_user_id';
  static const String settings = 'my_tiny_aquarium_settings';
  static const String lastSync = 'my_tiny_aquarium_last_sync';
}

/// 업적 ID (참조용)
class AchievementIds {
  static const String firstHatch = 'first_hatch';
  static const String firstQuest = 'first_quest';
  static const String streak3 = 'streak_3';
  static const String streak7 = 'streak_7';
  static const String streak30 = 'streak_30';
  static const String level5 = 'level_5';
  static const String level10 = 'level_10';
  static const String level20 = 'level_20';
  static const String perfectDay = 'perfect_day';
  static const String perfectWeek = 'perfect_week';
  static const String gold100 = 'gold_100';
  static const String gold500 = 'gold_500';
  static const String hardQuest10 = 'hard_quest_10';
  static const String allCategories = 'all_categories';
}