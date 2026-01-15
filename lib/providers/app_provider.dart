import 'package:flutter/foundation.dart';
import '../models/user_data_model.dart';
import '../models/fish_model.dart';
import '../models/quest_model.dart';
import '../services/storage_service.dart';

/// 앱 전역 상태 관리
class AppProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  UserData? _userData;
  bool _isLoading = true;
  String? _error;

  // Getters
  UserData? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isOnboardingComplete => _userData?.onboardingCompleted ?? false;

  /// 초기화
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _userData = await _storage.getUserData();
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('초기화 오류: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 사용자 데이터 저장
  Future<void> saveUserData(UserData data) async {
    _userData = data;
    notifyListeners();
    await _storage.saveUserData(data);
  }

  /// 사용자 데이터 업데이트
  Future<void> updateUserData(UserData Function(UserData) updater) async {
    if (_userData != null) {
      _userData = updater(_userData!);
      notifyListeners();
      await _storage.saveUserData(_userData!);
    }
  }

  /// 퀘스트 완료
  Future<void> completeQuest(String questId) async {
    if (_userData == null) return;

    // 퀘스트 찾기
    final quest = _userData!.quests.firstWhere((q) => q.id == questId);

    // 퀘스트 업데이트
    final updatedQuests = _userData!.quests.map((q) {
      if (q.id == questId) {
        return q.copyWith(completed: true);
      }
      return q;
    }).toList();

    // 경험치 및 레벨 계산
    var currentExp = _userData!.fish.exp + quest.expReward;
    var currentLevel = _userData!.fish.level;

    while (currentExp >= 100) {
      currentExp -= 100;
      currentLevel++;
    }

    // 물고기 업데이트
    final updatedFish = _userData!.fish.copyWith(
      level: currentLevel,
      exp: currentExp,
      hp: (_userData!.fish.hp + 5).clamp(0, 100),
    );

    // 데이터 저장
    await updateUserData((data) => data.copyWith(
      fish: updatedFish,
      gold: data.gold + quest.goldReward,
      quests: updatedQuests,
      waterQuality: (data.waterQuality + 3).clamp(0, 100),
    ));
  }

  /// 습관 완료
  Future<void> completeHabit(String habitId) async {
    if (_userData == null) return;

    final habit = _userData!.habits.firstWhere((h) => h.id == habitId);

    final updatedHabits = _userData!.habits.map((h) {
      if (h.id == habitId) {
        return h.copyWith(
          completionCount: h.completionCount + 1,
          totalCompletions: h.totalCompletions + 1,
          lastCompletedAt: DateTime.now().millisecondsSinceEpoch,
          comboCount: (h.comboCount ?? 0) + 1,
        );
      }
      return h;
    }).toList();

    // 경험치 계산
    var currentExp = _userData!.fish.exp + habit.expReward;
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
      gold: data.gold + habit.goldReward,
      habits: updatedHabits,
    ));
  }

  /// ToDo 완료
  Future<void> completeTodo(String todoId) async {
    if (_userData == null) return;

    final todo = _userData!.todos.firstWhere((t) => t.id == todoId);

    final updatedTodos = _userData!.todos.map((t) {
      if (t.id == todoId) {
        return t.copyWith(completed: true);
      }
      return t;
    }).toList();

    // 경험치 계산
    var currentExp = _userData!.fish.exp + todo.expReward;
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
      gold: data.gold + todo.goldReward,
      todos: updatedTodos,
    ));
  }

  /// 퀘스트 추가
  Future<void> addQuest(Quest quest) async {
    if (_userData == null) return;

    final updatedQuests = [..._userData!.quests, quest];
    await updateUserData((data) => data.copyWith(quests: updatedQuests));
  }

  /// 습관 추가
  Future<void> addHabit(Habit habit) async {
    if (_userData == null) return;

    final updatedHabits = [..._userData!.habits, habit];
    await updateUserData((data) => data.copyWith(habits: updatedHabits));
  }

  /// ToDo 추가
  Future<void> addTodo(ToDo todo) async {
    if (_userData == null) return;

    final updatedTodos = [..._userData!.todos, todo];
    await updateUserData((data) => data.copyWith(todos: updatedTodos));
  }

  /// 장식 구매
  Future<bool> purchaseDecoration(String decorationId, int cost) async {
    if (_userData == null || _userData!.gold < cost) {
      return false;
    }

    final updatedOwned = [..._userData!.ownedDecorations, decorationId];
    await updateUserData((data) => data.copyWith(
      gold: data.gold - cost,
      ownedDecorations: updatedOwned,
    ));

    return true;
  }

  /// 앱 초기화
  Future<void> reset() async {
    await _storage.clearUserData();
    _userData = null;
    notifyListeners();
  }

  /// 새로고침
  Future<void> refresh() async {
    await initialize();
  }
}
