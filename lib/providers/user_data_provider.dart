import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/storage_service.dart';

class UserDataProvider extends ChangeNotifier {
  UserData? _userData;
  bool _isLoading = true;

  final StorageService _storageService = StorageService();

  UserData? get userData => _userData;
  bool get isLoading => _isLoading;
  bool get isOnboardingComplete => _userData?.onboardingCompleted ?? false;

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

  Future<void> saveUserData(UserData data) async {
    _userData = data;
    notifyListeners();
    await _storageService.saveUserData(data);
  }

  Future<void> updateUserData(UserData Function(UserData) updater) async {
    if (_userData == null) return;

    _userData = updater(_userData!);
    notifyListeners();
    await _storageService.saveUserData(_userData!);
  }

  Future<void> updateFish(Fish fish) async {
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

  // Quest completion + auto achievement check
  // Returns newly unlocked achievements (for popup)
  Future<List<Achievement>> completeQuest(String questId, int expGain, int goldGain) async {
    if (_userData == null) return [];

    final beforeCompleted = _userData!.quests.where((q) => q.completed == true).length;

    final updatedQuests = _userData!.quests.map((q) {
      if (q.id == questId) {
        return q.copyWith(completed: true);
      }
      return q;
    }).toList();

    var currentExp = _userData!.fish.exp + expGain;
    var currentLevel = _userData!.fish.level;

    while (currentExp >= 100) {
      currentExp -= 100;
      currentLevel++;
    }

    final updatedFish = _userData!.fish.copyWith(
      level: currentLevel,
      exp: currentExp,
      hp: (_userData!.fish.hp + 5).clamp(0, 100),
    );

    await updateUserData((data) => data.copyWith(
      fish: updatedFish,
      gold: data.gold + goldGain,
      quests: updatedQuests,
      waterQuality: (data.waterQuality + 3).clamp(0, 100),
    ));

    final afterCompleted = _userData!.quests.where((q) => q.completed == true).length;

    // 완료 개수가 늘어난 경우에만 업적 체크 (중복 방지)
    if (afterCompleted <= beforeCompleted) return [];

    final newlyUnlocked = await checkAndUnlockAchievements();
    return newlyUnlocked;
  }

  // Unlock achievement (without copyWith/unlockedDate)
  Future<Achievement?> unlockAchievement({
    required String title,
    required String icon,
    String description = '',
  }) async {
    if (_userData == null) return null;

    final achievements = List<Achievement>.from(_userData!.achievements);
    final idx = achievements.indexWhere((a) => a.title == title);

    if (idx != -1) {
      final current = achievements[idx];
      if (current.unlocked == true) return null;

      // If existing entry exists, keep its fields, set unlocked=true
      final updated = Achievement(
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

    // Create new
    final created = Achievement(
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

  // All achievement rules are here
  Future<List<Achievement>> checkAndUnlockAchievements() async {
    if (_userData == null) return [];

    final newlyUnlocked = <Achievement>[];

    final quests = _userData!.quests;
    final completedCount = quests.where((q) => q.completed == true).length;

    // Quest completion milestones
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

  Future<bool> purchaseDecoration(String decorationId, int price) async {
    if (_userData == null) return false;

    if (_userData!.gold < price) {
      debugPrint('[UserDataProvider] purchaseDecoration: not enough gold');
      return false;
    }

    final updatedOwned = [..._userData!.ownedDecorations, decorationId];

    await updateUserData((data) => data.copyWith(
      gold: data.gold - price,
      ownedDecorations: updatedOwned,
    ));

    debugPrint('[UserDataProvider] purchaseDecoration: success $decorationId');
    return true;
  }

  void backToMain() {
    notifyListeners();
  }

  Future<void> reset() async {
    _userData = null;
    notifyListeners();
    await _storageService.clearUserData();
  }
}
