import 'package:flutter/foundation.dart';
import '../models/models.dart' as m;
import '../services/storage_service.dart';

class UserDataProvider extends ChangeNotifier {
  m.UserData? _userData;
  bool _isLoading = true;

  final StorageService _storageService = StorageService();

  m.UserData? get userData => _userData;
  bool get isLoading => _isLoading;
  bool get isOnboardingComplete => _userData?.onboardingCompleted ?? false;

  // =============================
  // 초기화 / 로드 / 저장
  // =============================

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    debugPrint('[UserDataProvider] initialize: start loading');
    try {
      _userData = await _storageService.getUserData().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          debugPrint('[UserDataProvider] storage load timeout');
          return null;
        },
      );
      debugPrint('[UserDataProvider] initialize: loaded = ${_userData != null}');
    } catch (e) {
      debugPrint('[UserDataProvider] initialize error: $e');
      _userData = null;
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('[UserDataProvider] initialize: done');
    }
  }

  Future<void> refreshUserData() async {
    try {
      _userData = await _storageService.getUserData();
      notifyListeners();
    } catch (e) {
      debugPrint('[UserDataProvider] refresh error: $e');
    }
  }

  Future<void> saveUserData(m.UserData data) async {
    _userData = data;
    notifyListeners();
    await _storageService.saveUserData(data);
  }

  Future<void> updateUserData(m.UserData Function(m.UserData) updater) async {
    if (_userData == null) return;

    _userData = updater(_userData!);
    notifyListeners();
    await _storageService.saveUserData(_userData!);
  }

  Future<void> updateFish(m.Fish fish) async {
    if (_userData == null) return;
    await updateUserData((data) => data.copyWith(fish: fish));
  }

  Future<void> updateGold(int gold) async {
    if (_userData == null) return;
    await updateUserData((data) => data.copyWith(gold: gold));
  }

  Future<void> addGold(int amount) async {
    if (_userData == null) return;
    await updateGold(_userData!.gold + amount);
  }

  // =============================
  // ✅ Quest CRUD (추가/수정/삭제) + 시간(reminderTime)
  // =============================

  /// 퀘스트 추가
  ///
  /// - reminderTime: "HH:mm" (예: "09:30") / 없으면 null
  /// - category: 지금 UI에서 카테고리 선택이 없으니 기본값 "공부"로 처리
  Future<void> addQuest({
    required String title,
    required m.Difficulty difficulty,
    int expReward = 10,
    int goldReward = 0,
    String? reminderTime,
    String? category,
    m.QuestType? questType,
  }) async {
    if (_userData == null) return;

    final newQuest = m.Quest(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      category: category ?? '공부',
      completed: false,
      date: _userData!.currentDate, // "YYYY-MM-DD"
      reminderTime: reminderTime,
      expReward: expReward,
      goldReward: goldReward,
      questType: questType ?? m.QuestType.values.first,
      difficulty: difficulty,
    );

    await updateUserData((data) {
      return data.copyWith(
        quests: [...data.quests, newQuest],
      );
    });

    // (선택) "첫 퀘스트 만들기" 업적 등 체크를 여기서 추가할 수 있음
    // await checkAndUnlockAchievements();
  }

  /// 퀘스트 수정
  ///
  /// ⚠️ Quest.copyWith가 프로젝트마다 다를 수 있어서
  /// 여기서는 "제목/난이도/보상/시간"만 수정하도록 구성.
  Future<void> updateQuest({
    required String questId,
    required String title,
    required m.Difficulty difficulty,
    int? expReward,
    int? goldReward,
    String? reminderTime,
  }) async {
    if (_userData == null) return;

    await updateUserData((data) {
      final updated = data.quests.map((q) {
        if (q.id != questId) return q;

        return q.copyWith(
          title: title,
          difficulty: difficulty,
          expReward: expReward ?? q.expReward,
          goldReward: goldReward ?? q.goldReward,
          reminderTime: reminderTime,
        );
      }).toList();

      return data.copyWith(quests: updated);
    });

    // (선택) "첫 수정" 업적 등
    // await checkAndUnlockAchievements();
  }

  /// 퀘스트 삭제
  Future<void> deleteQuest(String questId) async {
    if (_userData == null) return;

    await updateUserData((data) {
      return data.copyWith(
        quests: data.quests.where((q) => q.id != questId).toList(),
      );
    });
  }

  // =============================
  // ✅ 퀘스트 완료 + 업적 연동(팝업용 반환)
  // =============================

  Future<List<m.Achievement>> completeQuest(
      String questId,
      int expGain,
      int goldGain,
      ) async {
    if (_userData == null) return [];

    final beforeCompleted =
        _userData!.quests.where((q) => q.completed == true).length;

    final updatedQuests = _userData!.quests.map((q) {
      if (q.id == questId) return q.copyWith(completed: true);
      return q;
    }).toList();

    // exp/gold 반영 (fish.copyWith(exp: ...)가 없으면 여기서 에러남 → 알려줘!)
    final updatedFish = _userData!.fish.copyWith(
      exp: _userData!.fish.exp + expGain,
    );

    await updateUserData((data) => data.copyWith(
      quests: updatedQuests,
      gold: data.gold + goldGain,
      fish: updatedFish,
    ));

    final afterCompleted =
        _userData!.quests.where((q) => q.completed == true).length;

    // 완료 개수가 늘어난 경우에만 업적 체크
    if (afterCompleted <= beforeCompleted) return [];

    final newlyUnlocked = await checkAndUnlockAchievements();
    return newlyUnlocked;
  }

  // =============================
  // ✅ 업적(Unlock) 로직
  // =============================

  Future<m.Achievement?> unlockAchievement({
    required String title,
    required String icon,
    String description = '',
  }) async {
    if (_userData == null) return null;

    final achievements = List<m.Achievement>.from(_userData!.achievements);
    final idx = achievements.indexWhere((a) => a.title == title);

    if (idx != -1) {
      final current = achievements[idx];
      if (current.unlocked == true) return null;

      final updated = m.Achievement(
        id: current.id,
        title: current.title,
        description: current.description,
        icon: current.icon.isNotEmpty ? current.icon : icon,
        unlocked: true,
      );

      achievements[idx] = updated;
      await updateUserData((data) => data.copyWith(achievements: achievements));
      return updated;
    }

    final created = m.Achievement(
      id: title,
      title: title,
      description: description,
      icon: icon,
      unlocked: true,
    );

    achievements.add(created);
    await updateUserData((data) => data.copyWith(achievements: achievements));
    return created;
  }

  Future<List<m.Achievement>> checkAndUnlockAchievements() async {
    if (_userData == null) return [];

    final newlyUnlocked = <m.Achievement>[];

    final quests = _userData!.quests;
    final completedCount = quests.where((q) => q.completed == true).length;

    // ✅ 예시: 완료 개수 기반 업적
    if (completedCount >= 1) {
      final a = await unlockAchievement(
        title: '첫 클리어 (퀘스트 1개 완료)',
        icon: '✅',
        description: '퀘스트를 1개 완료했습니다.',
      );
      if (a != null) newlyUnlocked.add(a);
    }

    if (completedCount >= 10) {
      final a = await unlockAchievement(
        title: '10개 완료',
        icon: '🔟',
        description: '퀘스트를 10개 완료했습니다.',
      );
      if (a != null) newlyUnlocked.add(a);
    }

    if (completedCount >= 25) {
      final a = await unlockAchievement(
        title: '25개 완료',
        icon: '🏅',
        description: '퀘스트를 25개 완료했습니다.',
      );
      if (a != null) newlyUnlocked.add(a);
    }

    if (completedCount >= 50) {
      final a = await unlockAchievement(
        title: '50개 완료',
        icon: '🥈',
        description: '퀘스트를 50개 완료했습니다.',
      );
      if (a != null) newlyUnlocked.add(a);
    }

    if (completedCount >= 100) {
      final a = await unlockAchievement(
        title: '100개 완료',
        icon: '🥇',
        description: '퀘스트를 100개 완료했습니다.',
      );
      if (a != null) newlyUnlocked.add(a);
    }

    return newlyUnlocked;
  }

  Future<List<m.Achievement>> completeQuestById(String questId) async {
    if (_userData == null) return [];

    final quest = _userData!.quests.firstWhere(
          (q) => q.id == questId,
      orElse: () => throw Exception('Quest not found: $questId'),
    );

    return completeQuest(questId, quest.expReward, quest.goldReward);
  }


  // =============================
  // 기타
  // =============================

  void backToMain() {
    notifyListeners();
  }

  Future<void> reset() async {
    _userData = null;
    notifyListeners();
    await _storageService.clearUserData();
  }
}
