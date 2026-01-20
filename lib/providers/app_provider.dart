import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/user_data_model.dart';
import '../models/fish_model.dart';
import '../models/quest_model.dart';
import '../models/timer_model.dart';
import '../services/storage_service.dart';

class AppProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  UserData? _userData;
  bool _isLoading = true;

  UserData? get userData => _userData;
  bool get isLoading => _isLoading;
  bool get isOnboardingComplete => _userData?.onboardingCompleted ?? false;

  /// 초기화 및 데이터 로드
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    try {
      _userData = await _storage.getUserData();
    } catch (e) {
      debugPrint('초기화 에러: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 데이터 새로고침 (Settings용)
  Future<void> refresh() async => await initialize();

  /// 유저 생성 및 저장 (EggSelection용)
  Future<void> saveUserData(UserData data) async {
    _userData = data;
    notifyListeners();
    await _storage.saveUserData(data);
  }

  /// 공통 업데이트 로직
  Future<void> updateUserData(UserData Function(UserData) updater) async {
    if (_userData != null) {
      _userData = updater(_userData!);
      notifyListeners();
      await _storage.saveUserData(_userData!);
    }
  }

  /// 퀘스트 완료 처리
  Future<void> completeQuest(String questId) async {
    if (_userData == null) return;
    final quest = _userData!.quests.firstWhere((q) => q.id == questId);
    final updatedQuests = _userData!.quests.map((q) => q.id == questId ? q.copyWith(completed: true) : q).toList();

    await _applyRewards(exp: quest.expReward, gold: quest.goldReward,
        updater: (data) => data.copyWith(quests: updatedQuests));
  }

  /// 할 일 완료 처리 (Todos용)
  Future<void> completeTodo(String todoId) async {
    if (_userData == null) return;
    final todo = _userData!.todos.firstWhere((t) => t.id == todoId);
    final updatedTodos = _userData!.todos.map((t) => t.id == todoId ? t.copyWith(completed: true) : t).toList();

    await _applyRewards(exp: todo.expReward, gold: todo.goldReward,
        updater: (data) => data.copyWith(todos: updatedTodos));
  }

  /// 타이머 보상 처리 (Timer용)
  Future<void> completeTimerSession({required String category, required int durationSeconds}) async {
    if (_userData == null) return;
    final uuid = const Uuid();
    final session = TimerSession(
      id: uuid.v4(),
      category: category,
      durationSeconds: durationSeconds,
      startTime: DateTime.now().millisecondsSinceEpoch - (durationSeconds * 1000),
      endTime: DateTime.now().millisecondsSinceEpoch,
      completed: true,
    );

    final minutes = (durationSeconds / 60).floor();
    await _applyRewards(exp: minutes * 5, gold: minutes * 3,
        updater: (data) => data.copyWith(timerSessions: [...data.timerSessions, session]));
  }

  /// 공통 보상 적용 시스템 (레벨업 로직 포함)
  Future<void> _applyRewards({required int exp, required int gold, required UserData Function(UserData) updater}) async {
    var currentExp = _userData!.fish.exp + exp;
    var currentLevel = _userData!.fish.level;

    while (currentExp >= 100) {
      currentExp -= 100;
      currentLevel++;
    }

    final updatedFish = _userData!.fish.copyWith(level: currentLevel, exp: currentExp);
    await updateUserData((data) => updater(data).copyWith(
        fish: updatedFish, gold: data.gold + gold,
        waterQuality: (data.waterQuality + 3).clamp(0, 100)
    ));
  }

  /// 데이터 초기화 (Reset용)
  Future<void> reset() async {
    await _storage.clearUserData();
    _userData = null;
    notifyListeners();
  }
}