import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../data/quest_templates.dart';

/// 퀘스트 관련 유틸리티
class QuestUtils {
  static const Uuid _uuid = Uuid();

  /// 일일 퀘스트 생성
  static List<Quest> generateDailyQuests(
    List<String> categories,
    String date,
  ) {
    final quests = <Quest>[];

    for (final category in categories) {
      // 각 카테고리마다 2개의 퀘스트 생성
      quests.add(createQuest(
        category: category,
        date: date,
        difficulty: Difficulty.easy,
      ));
      quests.add(createQuest(
        category: category,
        date: date,
        difficulty: Difficulty.normal,
      ));
    }

    return quests;
  }

  /// 퀘스트 생성
  static Quest createQuest({
    required String category,
    required String date,
    required Difficulty difficulty,
    QuestType type = QuestType.daily,
    String? customTitle,
  }) {
    final title = customTitle ?? QuestTemplates.getRandomQuest(category);

    return Quest(
      id: _uuid.v4(),
      title: title,
      category: category,
      completed: false,
      date: date,
      expReward: getExpReward(difficulty),
      goldReward: getGoldReward(difficulty),
      questType: type,
      difficulty: difficulty,
    );
  }

  /// 난이도별 경험치 보상
  static int getExpReward(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 15;
      case Difficulty.normal:
        return 25;
      case Difficulty.hard:
        return 40;
    }
  }

  /// 난이도별 골드 보상
  static int getGoldReward(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 8;
      case Difficulty.normal:
        return 15;
      case Difficulty.hard:
        return 25;
    }
  }

  /// 습관 생성
  static Habit createHabit({
    required String title,
    required String category,
    required Difficulty difficulty,
  }) {
    return Habit(
      id: _uuid.v4(),
      title: title,
      category: category,
      completionCount: 0,
      totalCompletions: 0,
      expReward: getExpReward(difficulty),
      goldReward: getGoldReward(difficulty),
      difficulty: difficulty,
    );
  }

  /// ToDo 생성
  static ToDo createTodo({
    required String title,
    required String category,
    required Difficulty difficulty,
    String? dueDate,
    String? dueTime,
  }) {
    return ToDo(
      id: _uuid.v4(),
      title: title,
      category: category,
      completed: false,
      dueDate: dueDate,
      dueTime: dueTime,
      expReward: getExpReward(difficulty),
      goldReward: getGoldReward(difficulty),
      difficulty: difficulty,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// 완료되지 않은 퀘스트 필터링
  static List<Quest> getIncompleteQuests(List<Quest> quests) {
    return quests.where((q) => !q.completed).toList();
  }

  /// 완료된 퀘스트 필터링
  static List<Quest> getCompletedQuests(List<Quest> quests) {
    return quests.where((q) => q.completed).toList();
  }

  /// 특정 카테고리 퀘스트 필터링
  static List<Quest> getQuestsByCategory(List<Quest> quests, String category) {
    return quests.where((q) => q.category == category).toList();
  }

  /// 특정 난이도 퀘스트 필터링
  static List<Quest> getQuestsByDifficulty(List<Quest> quests, Difficulty difficulty) {
    return quests.where((q) => q.difficulty == difficulty).toList();
  }

  /// 완료율 계산
  static double calculateCompletionRate(List<Quest> quests) {
    if (quests.isEmpty) return 0.0;

    final completed = quests.where((q) => q.completed).length;
    return (completed / quests.length) * 100;
  }

  /// 총 보상 계산
  static Map<String, int> calculateTotalRewards(List<Quest> quests) {
    int totalExp = 0;
    int totalGold = 0;

    for (final quest in quests) {
      if (quest.completed) {
        totalExp += quest.expReward;
        totalGold += quest.goldReward;
      }
    }

    return {
      'exp': totalExp,
      'gold': totalGold,
    };
  }

  /// 난이도 텍스트
  static String getDifficultyText(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return '쉬움';
      case Difficulty.normal:
        return '보통';
      case Difficulty.hard:
        return '어려움';
    }
  }

  /// 퀘스트 타입 텍스트
  static String getQuestTypeText(QuestType type) {
    switch (type) {
      case QuestType.main:
        return '메인';
      case QuestType.sub:
        return '서브';
      case QuestType.habit:
        return '습관';
      case QuestType.todo:
        return '할 일';
      case QuestType.daily:
        return '데일리';
    }
  }

  /// 마감일까지 남은 시간 계산
  static String getTimeUntilDue(String? dueDate, String? dueTime) {
    if (dueDate == null) return '';

    try {
      final date = DateTime.parse(dueDate);
      final now = DateTime.now();
      final difference = date.difference(now);

      if (difference.isNegative) {
        return '마감됨';
      } else if (difference.inDays > 0) {
        return 'D-${difference.inDays}';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}시간 남음';
      } else {
        return '${difference.inMinutes}분 남음';
      }
    } catch (e) {
      return '';
    }
  }

  /// 오늘의 퀘스트인지 확인
  static bool isTodayQuest(Quest quest, String today) {
    return quest.date == today;
  }

  /// 마감된 ToDo 확인
  static bool isOverdue(ToDo todo) {
    if (todo.dueDate == null) return false;

    try {
      final dueDate = DateTime.parse(todo.dueDate!);
      return dueDate.isBefore(DateTime.now()) && !todo.completed;
    } catch (e) {
      return false;
    }
  }
}
