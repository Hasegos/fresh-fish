import '../models/achievement_model.dart';

/// 모든 업적 목록
List<Achievement> getInitialAchievements() {
  return [
    Achievement(
      id: 'first_hatch',
      title: '첫 부화',
      description: '첫 물고기 알을 부화시켰습니다',
      icon: '🥚',
      unlocked: false,
    ),
    Achievement(
      id: 'first_quest',
      title: '첫 퀘스트',
      description: '첫 퀘스트를 완료했습니다',
      icon: '✅',
      unlocked: false,
    ),
    Achievement(
      id: 'streak_3',
      title: '3일 연속',
      description: '3일 연속 퀘스트를 완료했습니다',
      icon: '🔥',
      unlocked: false,
    ),
    Achievement(
      id: 'streak_7',
      title: '일주일 달성',
      description: '7일 연속 퀘스트를 완료했습니다',
      icon: '⭐',
      unlocked: false,
    ),
    Achievement(
      id: 'streak_30',
      title: '한 달 연속',
      description: '30일 연속 퀘스트를 완료했습니다',
      icon: '🏆',
      unlocked: false,
    ),
    Achievement(
      id: 'level_5',
      title: '레벨 5',
      description: '레벨 5에 도달했습니다',
      icon: '🎖️',
      unlocked: false,
    ),
    Achievement(
      id: 'level_10',
      title: '레벨 10',
      description: '레벨 10에 도달했습니다',
      icon: '🏅',
      unlocked: false,
    ),
    Achievement(
      id: 'level_20',
      title: '레벨 20',
      description: '레벨 20에 도달했습니다',
      icon: '👑',
      unlocked: false,
    ),
    Achievement(
      id: 'perfect_day',
      title: '완벽한 하루',
      description: '하루의 모든 퀘스트를 완료했습니다',
      icon: '💯',
      unlocked: false,
    ),
    Achievement(
      id: 'perfect_week',
      title: '완벽한 한 주',
      description: '일주일 내내 모든 퀘스트를 완료했습니다',
      icon: '🌟',
      unlocked: false,
    ),
    Achievement(
      id: 'gold_100',
      title: '골드 100',
      description: '골드 100개를 모았습니다',
      icon: '💰',
      unlocked: false,
    ),
    Achievement(
      id: 'gold_500',
      title: '골드 500',
      description: '골드 500개를 모았습니다',
      icon: '💎',
      unlocked: false,
    ),
    Achievement(
      id: 'hard_quest_10',
      title: '도전자',
      description: '어려움 난이도 퀘스트를 10개 완료했습니다',
      icon: '🔥',
      unlocked: false,
    ),
    Achievement(
      id: 'all_categories',
      title: '만능 플레이어',
      description: '모든 카테고리의 퀘스트를 완료했습니다',
      icon: '🎯',
      unlocked: false,
    ),
  ];
}
