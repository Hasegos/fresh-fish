/// 레벨 및 경험치 유틸리티
library;

import '../constants/app_constants.dart';

/// 레벨업 결과
class LevelUpResult {
  final int newLevel;      // 새로운 레벨
  final int newExp;        // 새로운 경험치
  final int levelsGained;  // 획득한 레벨 수
  final bool didLevelUp;   // 레벨업 여부

  LevelUpResult({
    required this.newLevel,
    required this.newExp,
    required this.levelsGained,
    required this.didLevelUp,
  });
}

/// 경험치 획득 처리 및 레벨업 처리
LevelUpResult processExpGain(
  int currentLevel,
  int currentExp,
  int expGained,
) {
  final totalExp = currentExp + expGained;
  final levelsGained = totalExp ~/ LevelConstants.expPerLevel;
  final remainingExp = totalExp % LevelConstants.expPerLevel;

  return LevelUpResult(
    newLevel: currentLevel + levelsGained,
    newExp: remainingExp,
    levelsGained: levelsGained,
    didLevelUp: levelsGained > 0,
  );
}

/// 진화 단계
enum EvolutionStage {
  egg,       // 알 단계
  small,     // 작은 물고기
  adult,     // 성체
  legendary; // 전설
}

/// 레벨에 따른 진화 단계 가져오기
EvolutionStage getEvolutionStage(int level) {
  if (level >= 1 && level <= LevelConstants.eggMaxLevel) {
    return EvolutionStage.egg;
  }
  if (level >= LevelConstants.eggMaxLevel + 1 && level <= LevelConstants.smallMaxLevel) {
    return EvolutionStage.small;
  }
  if (level >= LevelConstants.smallMaxLevel + 1 && level <= LevelConstants.adultMaxLevel) {
    return EvolutionStage.adult;
  }
  return EvolutionStage.legendary;
}

/// 진화 정보
class EvolutionInfo {
  final EvolutionStage stage;  // 진화 단계
  final String displayName;    // 표시 이름
  final String emoji;          // 이모지
  final double scale;          // 크기 배율

  EvolutionInfo({
    required this.stage,
    required this.displayName,
    required this.emoji,
    required this.scale,
  });
}

/// 진화 단계 표시 정보 가져오기
EvolutionInfo getEvolutionInfo(int level) {
  final stage = getEvolutionStage(level);

  switch (stage) {
    case EvolutionStage.egg:
      return EvolutionInfo(
        stage: EvolutionStage.egg,
        displayName: '알',
        emoji: '🥚',
        scale: 0.6,
      );
    case EvolutionStage.small:
      return EvolutionInfo(
        stage: EvolutionStage.small,
        displayName: '어린 물고기',
        emoji: '🐟',
        scale: 1.0,
      );
    case EvolutionStage.adult:
      return EvolutionInfo(
        stage: EvolutionStage.adult,
        displayName: '성체',
        emoji: '🐠',
        scale: 1.5,
      );
    case EvolutionStage.legendary:
      return EvolutionInfo(
        stage: EvolutionStage.legendary,
        displayName: '전설의 물고기',
        emoji: '🐋',
        scale: 2.0,
      );
  }
}

/// 진화 확인 결과
class EvolutionCheckResult {
  final bool evolved;            // 진화 여부
  final EvolutionStage oldStage; // 이전 단계
  final EvolutionStage newStage; // 새로운 단계

  EvolutionCheckResult({
    required this.evolved,
    required this.oldStage,
    required this.newStage,
  });
}

/// 물고기가 진화했는지 확인 (단계 변경)
EvolutionCheckResult checkEvolution(int oldLevel, int newLevel) {
  final oldStage = getEvolutionStage(oldLevel);
  final newStage = getEvolutionStage(newLevel);

  return EvolutionCheckResult(
    evolved: oldStage != newStage,
    oldStage: oldStage,
    newStage: newStage,
  );
}