import '../models/models.dart';

/// 물고기 성장 관련 유틸리티
class GrowthUtils {
  /// 총 성장 시간 (72시간)
  static const int totalGrowthHours = 72;
  static const int eggToJuvenileHours = 24;
  static const int juvenileToAdultHours = 48;

  /// 물고기 성장 단계 계산 (시간 기반)
  static GrowthStage getGrowthStage(Fish fish) {
    if (fish.eggHatchedAt == null) {
      return GrowthStage.adult;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsed = now - fish.eggHatchedAt!;
    final hours = elapsed / (1000 * 60 * 60);

    if (hours < eggToJuvenileHours) {
      return GrowthStage.egg;
    } else if (hours < juvenileToAdultHours) {
      return GrowthStage.juvenile;
    } else {
      return GrowthStage.adult;
    }
  }

  /// 성장 진행률 (0-100)
  static double getGrowthProgress(Fish fish) {
    if (fish.eggHatchedAt == null) {
      return 100.0;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsed = now - fish.eggHatchedAt!;
    final hours = elapsed / (1000 * 60 * 60);

    return (hours / totalGrowthHours * 100).clamp(0, 100);
  }

  /// 남은 성장 시간 (밀리초)
  static int getRemainingGrowthTime(Fish fish) {
    if (fish.eggHatchedAt == null) {
      return 0;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsed = now - fish.eggHatchedAt!;
    final totalTime = totalGrowthHours * 60 * 60 * 1000;
    final remaining = totalTime - elapsed;

    return remaining > 0 ? remaining : 0;
  }

  /// 남은 시간을 읽기 쉬운 형식으로 변환
  static String formatRemainingTime(int milliseconds) {
    if (milliseconds <= 0) return '완료';

    final hours = milliseconds ~/ (1000 * 60 * 60);
    final minutes = (milliseconds % (1000 * 60 * 60)) ~/ (1000 * 60);

    if (hours > 0) {
      return '$hours시간 ${minutes}분';
    } else {
      return '$minutes분';
    }
  }

  /// 레벨 기반 진화 단계 계산
  static FishEvolution getEvolutionStage(int level) {
    if (level <= 3) {
      return FishEvolution.egg;
    } else if (level <= 7) {
      return FishEvolution.fish1;
    } else if (level <= 12) {
      return FishEvolution.fish2;
    } else {
      return FishEvolution.legendary;
    }
  }

  /// 다음 레벨까지 필요한 경험치
  static int getExpForNextLevel(int currentExp) {
    return 100 - currentExp;
  }

  /// 레벨업 체크
  static bool canLevelUp(int exp) {
    return exp >= 100;
  }

  /// 경험치로 레벨 계산
  static Map<String, int> calculateLevel(int currentLevel, int currentExp, int expGain) {
    var newExp = currentExp + expGain;
    var newLevel = currentLevel;

    while (newExp >= 100) {
      newExp -= 100;
      newLevel++;
    }

    return {
      'level': newLevel,
      'exp': newExp,
    };
  }

  /// HP 계산 (퀘스트 완료 시)
  static int calculateHp(int currentHp, int questsCompleted) {
    final newHp = currentHp + (questsCompleted * 5);
    return newHp.clamp(0, 100);
  }

  /// HP 감소 (일일)
  static int decreaseHp(int currentHp, int decayAmount) {
    final newHp = currentHp - decayAmount;
    return newHp.clamp(0, 100);
  }

  /// 물고기 상태 확인
  static String getFishStatus(Fish fish) {
    if (fish.hp <= 0) {
      return '위급';
    } else if (fish.hp <= 30) {
      return '배고픔';
    } else if (fish.hp <= 60) {
      return '보통';
    } else {
      return '건강';
    }
  }

  /// 성장 단계 이모지
  static String getGrowthStageEmoji(GrowthStage stage) {
    switch (stage) {
      case GrowthStage.egg:
        return '🥚';
      case GrowthStage.juvenile:
        return '🐟';
      case GrowthStage.adult:
        return '🐠';
    }
  }

  /// 성장 단계 텍스트
  static String getGrowthStageText(GrowthStage stage) {
    switch (stage) {
      case GrowthStage.egg:
        return '알';
      case GrowthStage.juvenile:
        return '치어';
      case GrowthStage.adult:
        return '성체';
    }
  }
}
