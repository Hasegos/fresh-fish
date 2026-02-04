import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import '../utils/quest_utils.dart';

/// 사용자 데이터 상태 관리 Provider
/// [Why] 앱 전체에서 유저 정보(골드, 물고기 상태 등)를 공유하기 위해 사용합니다.
class UserDataProvider extends ChangeNotifier {
  UserData? _userData;
  bool _isLoading = true;

  // StorageService 인스턴스 생성
  final StorageService _storageService = StorageService();

  // Getters
  UserData? get userData => _userData;
  bool get isLoading => _isLoading;
  bool get isOnboardingComplete => _userData?.onboardingCompleted ?? false;

  /// 초기화
  /// [How] 앱 시작 시 저장된 데이터를 불러옵니다.
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners(); // 로딩 시작 알림

    print("🚀 [Provider LOG 1] 데이터 로딩 시작...");
    try {
      _userData = await _storageService.getUserData().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          debugPrint('⚠️ UserDataProvider Storage 로딩 타임아웃');
          return null;
        },
      );
      print("🚀 [Provider LOG 2] 데이터 로딩 성공: ${_userData != null}");
    } catch (e) {
      print("❌ [Provider ERROR] 로딩 중 에러 발생: $e");
      debugPrint('Error loading user data: $e');
      _userData = null;
    }

    _isLoading = false;
    notifyListeners(); // 로딩 종료 알림
    print("🚀 [Provider LOG 3] 초기화 프로세스 종료");
  }

  /// 사용자 데이터 새로고침
  Future<void> refreshUserData() async {
    try {
      _userData = await _storageService.getUserData();
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing user data: $e');
    }
  }

  /// 사용자 데이터 저장
  Future<void> saveUserData(UserData data) async {
    _userData = data;
    notifyListeners();
    await _storageService.saveUserData(data);
  }

  /// 사용자 데이터 업데이트 (함수형 업데이트)
  Future<void> updateUserData(UserData Function(UserData) updater) async {
    if (_userData != null) {
      _userData = updater(_userData!);
      notifyListeners();
      await _storageService.saveUserData(_userData!);
    }
  }

  /// 특정 항목 업데이트 메서드들
  Future<void> updateFish(Fish fish) async {
    if (_userData != null) {
      await updateUserData((data) => data.copyWith(fish: fish));
    }
  }

  Future<void> updateGold(int gold) async {
    if (_userData != null) {
      await updateUserData((data) => data.copyWith(gold: gold));
    }
  }

  Future<void> addGold(int amount) async {
    if (_userData != null) {
      await updateGold(_userData!.gold + amount);
    }
  }

  /// ???????? ???
  Future<void> completeQuest(String questId, int expGain, int goldGain) async {
    if (_userData == null) return;

    final updatedQuests = _userData!.quests.map((q) {
      if (q.id == questId) {
        return q.copyWith(completed: true);
      }
      return q;
    }).toList();

    await _applyRewards(
      exp: expGain,
      gold: goldGain,
      updater: (data) => data.copyWith(quests: updatedQuests),
    );
  }

  Future<void> completeQuestById(String questId) async {
    if (_userData == null) return;
    final quest = _userData!.quests.firstWhere((q) => q.id == questId);
    if (quest.completed) return;
    await completeQuest(questId, quest.expReward, quest.goldReward);
  }

  Future<void> createQuest({
    required String title,
    required String category,
    required Difficulty difficulty,
    QuestType questType = QuestType.sub,
    String? date,
    String? reminderTime,
  }) async {
    if (_userData == null) return;
    final quest = QuestUtils.createQuest(
      category: category,
      date: date ?? _userData!.currentDate,
      difficulty: difficulty,
      type: questType,
      customTitle: title,
      reminderTime: reminderTime,
    );
    await updateUserData((data) => data.copyWith(
          quests: [...data.quests, quest],
        ));
  }

  Future<void> updateQuest(Quest updated) async {
    if (_userData == null) return;
    final updatedQuests = _userData!.quests
        .map((quest) => quest.id == updated.id ? updated : quest)
        .toList();
    await updateUserData((data) => data.copyWith(quests: updatedQuests));
  }

  Future<void> deleteQuest(String questId) async {
    if (_userData == null) return;
    final updatedQuests =
        _userData!.quests.where((quest) => quest.id != questId).toList();
    await updateUserData((data) => data.copyWith(quests: updatedQuests));
  }

  Future<void> createHabit({
    required String title,
    required String category,
    required Difficulty difficulty,
  }) async {
    if (_userData == null) return;
    final habit = QuestUtils.createHabit(
      title: title,
      category: category,
      difficulty: difficulty,
    );
    await updateUserData((data) => data.copyWith(
          habits: [...data.habits, habit],
        ));
  }

  Future<void> updateHabit(Habit updated) async {
    if (_userData == null) return;
    final updatedHabits = _userData!.habits
        .map((habit) => habit.id == updated.id ? updated : habit)
        .toList();
    await updateUserData((data) => data.copyWith(habits: updatedHabits));
  }

  Future<void> deleteHabit(String habitId) async {
    if (_userData == null) return;
    final updatedHabits =
        _userData!.habits.where((habit) => habit.id != habitId).toList();
    await updateUserData((data) => data.copyWith(habits: updatedHabits));
  }

  Future<void> completeHabit(String habitId) async {
    if (_userData == null) return;
    final now = DateTime.now();

    final updatedHabits = _userData!.habits.map((habit) {
      if (habit.id != habitId) return habit;

      final lastCompletedAt = habit.lastCompletedAt;
      final lastDate = lastCompletedAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(lastCompletedAt);
      final isSameDay = lastDate != null &&
          lastDate.year == now.year &&
          lastDate.month == now.month &&
          lastDate.day == now.day;
      final isYesterday = lastDate != null &&
          lastDate.year == now.year &&
          lastDate.month == now.month &&
          lastDate.day == now.day - 1;

      final nextCompletionCount =
          isSameDay ? habit.completionCount + 1 : 1;
      final nextComboCount = isSameDay
          ? habit.comboCount
          : (isYesterday ? (habit.comboCount ?? 0) + 1 : 1);

      return habit.copyWith(
        completionCount: nextCompletionCount,
        totalCompletions: habit.totalCompletions + 1,
        lastCompletedAt: now.millisecondsSinceEpoch,
        comboCount: nextComboCount,
      );
    }).toList();

    final habit = _userData!.habits.firstWhere((h) => h.id == habitId);
    await _applyRewards(
      exp: habit.expReward,
      gold: habit.goldReward,
      updater: (data) => data.copyWith(habits: updatedHabits),
    );
  }

  Future<void> _applyRewards({
    required int exp,
    required int gold,
    required UserData Function(UserData) updater,
  }) async {
    var currentExp = _userData!.fish.exp + exp;
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

    await updateUserData(
      (data) => updater(data).copyWith(
        fish: updatedFish,
        gold: data.gold + gold,
        waterQuality: (data.waterQuality + 3).clamp(0, 100),
      ),
    );
  }

  // 👇 [새로 추가된 메서드 1: 장식 구매]
  /// [Why] 상점에서 아이템을 구매할 때 골드를 차감하고 소유 목록에 추가하기 위해 필요합니다.
  /// [How] 골드가 충분한지 확인한 후, copyWith를 통해 기존 데이터를 업데이트합니다.
  Future<bool> purchaseDecoration(String decorationId, int price) async {
    if (_userData == null) return false;

    // 1. 골드 부족 여부 체크
    if (_userData!.gold < price) {
      print("❌ 골드가 부족하여 구매할 수 없습니다.");
      return false;
    }

    // 2. 소유 목록 업데이트 및 골드 차감
    final updatedOwned = [..._userData!.ownedDecorations, decorationId];

    await updateUserData((data) => data.copyWith(
      gold: data.gold - price,
      ownedDecorations: updatedOwned,
    ));

    print("✅ 장식 구매 성공: $decorationId");
    return true;
  }

  // 👇 [새로 추가된 메서드 2: 스킨 구매]
  Future<bool> purchaseSkin(String skinId, int price) async {
    if (_userData == null) return false;

    // 1. 이미 소유했는지 확인
    if (_userData!.ownedSkins.contains(skinId)) {
      print("❌ 이미 소유한 스킨입니다.");
      return false;
    }

    // 2. 골드 부족 여부 체크
    if (_userData!.gold < price) {
      print("❌ 골드가 부족하여 구매할 수 없습니다.");
      return false;
    }

    // 3. 소유 목록 업데이트 및 골드 차감
    final updatedOwned = [..._userData!.ownedSkins, skinId];

    await updateUserData((data) => data.copyWith(
      gold: data.gold - price,
      ownedSkins: updatedOwned,
    ));

    print("✅ 스킨 구매 성공: $skinId");
    return true;
  }

  // 👇 [새로 추가된 메서드 3: 스킨 선택]
  Future<bool> selectSkin(String skinId) async {
    if (_userData == null) return false;

    // 1. 소유했는지 확인
    if (!_userData!.ownedSkins.contains(skinId)) {
      print("❌ 소유하지 않은 스킨입니다.");
      return false;
    }

    // 2. 현재 스킨 변경
    await updateUserData((data) => data.copyWith(currentSkinId: skinId));

    print("✅ 스킨 선택 성공: $skinId");
    return true;
  }

  // 👇 [새로 추가된 메서드 4: 장식 위치 업데이트]
  /// [Why] 장식 관리 화면에서 장식 위치를 변경할 때 사용합니다.
  Future<void> updateDecorationPosition(
    String decorationId,
    double x,
    double y,
  ) async {
    if (_userData == null) return;

    final updatedDecorations = _userData!.decorations.map((deco) {
      if (deco.decorationId == decorationId) {
        return deco.copyWith(x: x, y: y);
      }
      return deco;
    }).toList();

    await updateUserData(
      (data) => data.copyWith(decorations: updatedDecorations),
    );
  }

  /// 장식 추가
  Future<void> addDecoration(String decorationId, double x, double y) async {
    if (_userData == null) return;

    final newDecoration = PlacedDecoration(
      decorationId: decorationId,
      x: x,
      y: y,
    );

    await updateUserData(
      (data) => data.copyWith(
        decorations: [...data.decorations, newDecoration],
      ),
    );
  }

  /// 장식 삭제
  Future<void> removeDecoration(String decorationId) async {
    if (_userData == null) return;

    final updatedDecorations = _userData!.decorations
        .where((deco) => deco.decorationId != decorationId)
        .toList();

    await updateUserData(
      (data) => data.copyWith(decorations: updatedDecorations),
    );
  }

  // 👇 [장식장(장식 관리 수족관) 관련 메서드들]
  
  /// 장식장 수족관에 장식 추가
  Future<void> addToDecorationShelf(String decorationId) async {
    if (_userData == null) return;

    // 이미 배치되어 있으면 추가하지 않음
    if (_userData!.decorationShelfLayout.any((d) => d.decorationId == decorationId)) {
      return;
    }

    final newDecoration = PlacedDecoration(
      decorationId: decorationId,
      x: 0.3 + (_userData!.decorationShelfLayout.length * 0.15).clamp(0.0, 0.5),
      y: 0.3,
    );

    await updateUserData(
      (data) => data.copyWith(
        decorationShelfLayout: [...data.decorationShelfLayout, newDecoration],
      ),
    );
  }

  /// 장식장 수족관에서 장식 제거
  Future<void> removeFromDecorationShelf(String decorationId) async {
    if (_userData == null) return;

    final updatedLayout = _userData!.decorationShelfLayout
        .where((deco) => deco.decorationId != decorationId)
        .toList();

    await updateUserData(
      (data) => data.copyWith(decorationShelfLayout: updatedLayout),
    );
  }

  /// 장식장 수족관에서 장식 위치 업데이트
  Future<void> updateShelfDecorationPosition(
    String decorationId,
    double x,
    double y,
  ) async {
    if (_userData == null) return;

    final updatedLayout = _userData!.decorationShelfLayout.map((deco) {
      if (deco.decorationId == decorationId) {
        return deco.copyWith(x: x, y: y);
      }
      return deco;
    }).toList();

    await updateUserData(
      (data) => data.copyWith(decorationShelfLayout: updatedLayout),
    );
  }

  // 👇 [새로 추가된 메서드 5: 메인으로 이동]
  /// [Why] 화면의 뒤로가기 버튼 등을 눌렀을 때 상태를 관리하거나 알림을 주기 위해 사용합니다.
  void backToMain() {
    // 현재는 알림(notifyListeners)만 주지만,
    // 나중에 특정 페이지 인덱스를 0(메인)으로 바꾸는 로직 등을 여기에 넣을 수 있습니다.
    notifyListeners();
  }

  /// 데이터 초기화 (로그아웃 등)
  Future<void> reset() async {
    _userData = null;
    notifyListeners();
    await _storageService.clearUserData();
  }
}
