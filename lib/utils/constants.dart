/// 앱 전역 상수
class AppConstants {
  // 앱 정보
  static const String appName = 'My Tiny Aquarium';
  static const String appVersion = '1.0.0';
  
  // 시간 상수 (밀리초)
  static const int totalGrowthTime = 72 * 60 * 60 * 1000; // 72시간
  static const int eggToJuvenileTime = 24 * 60 * 60 * 1000; // 24시간
  static const int juvenileToAdultTime = 48 * 60 * 60 * 1000; // 48시간
  
  // 레벨 상수
  static const int expPerLevel = 100;
  static const int maxLevel = 99;
  
  // 진화 레벨 기준
  static const int eggMaxLevel = 3;
  static const int fish1MaxLevel = 7;
  static const int fish2MaxLevel = 12;
  // 13+ legendary
  
  // 물고기 상수
  static const int initialHp = 100;
  static const int maxHp = 100;
  static const int dailyHpDecay = 10;
  static const int questHpBonus = 5;
  
  // 수질 상수
  static const int initialWaterQuality = 50;
  static const int maxWaterQuality = 100;
  static const int dailyWaterDecay = 5;
  static const int questWaterBonus = 3;
  
  // 보상 상수
  static const Map<String, int> expRewards = {
    'easy': 15,
    'normal': 25,
    'hard': 40,
  };
  
  static const Map<String, int> goldRewards = {
    'easy': 8,
    'normal': 15,
    'hard': 25,
  };
  
  // 로컬 저장소 키
  static const String userDataKey = 'my_tiny_aquarium_user_data';
  static const String userIdKey = 'my_tiny_aquarium_user_id';
  
  // Firebase 컬렉션
  static const String usersCollection = 'users';
  
  // 카테고리
  static const List<String> categories = ['학업', '건강', '자기계발', '생활'];
  
  // 카테고리 아이콘
  static const Map<String, String> categoryIcons = {
    '학업': '📚',
    '건강': '💪',
    '자기계발': '🚀',
    '생활': '🏠',
  };
  
  // 물고기 설정
  static const Map<String, Map<String, String>> fishConfigs = {
    'goldfish': {'name': '금붕어', 'color': '#FFD700', 'emoji': '🟡'},
    'bluefish': {'name': '파랑이', 'color': '#4169E1', 'emoji': '🔵'},
    'redfish': {'name': '빨강이', 'color': '#DC143C', 'emoji': '🔴'},
  };
}
