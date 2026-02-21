import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/user_data_model.dart';
import '../models/timer_model.dart';
import '../services/storage_service.dart';
import '../services/firebase_service.dart';

class AppProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  final FirebaseService _firebaseService = FirebaseService();
  UserData? _userData;
  bool _isLoading = true;
  TimerState? _timerState;


  // -------------------------
  // 알림 모드 설정 (임시: 앱 재실행 시 초기화됨)
  // -------------------------
  bool notifSound = true;       // 소리
  bool notifVibration = false;  // 진동
  bool notifSilent = false;     // 무음

  void setNotifSound(bool v) {
    notifSound = v;
    if (v) {
      notifVibration = false;
      notifSilent = false;
    }
    notifyListeners();
  }

  void setNotifVibration(bool v) {
    notifVibration = v;
    if (v) {
      notifSound = false;
      notifSilent = false;
    }
    notifyListeners();
  }

  void setNotifSilent(bool v) {
    notifSilent = v;
    if (v) {
      notifSound = false;
      notifVibration = false;
    }
    notifyListeners();
  }

  UserData? get userData => _userData;
  bool get isLoading => _isLoading;
  bool get isOnboardingComplete => _userData?.onboardingCompleted ?? false;
  String? get activeTimerCategory => _timerState?.category;
  bool get isTimerRunning => _timerState?.isRunning ?? false;
  PomodoroSettings get pomodoroSettings => _userData?.pomodoroSettings ?? const PomodoroSettings();

  int get activeTimerElapsedSeconds {
    final state = _timerState;
    if (state == null) return 0;
    if (!state.isRunning) return state.elapsedSeconds;
    final startMs = state.startMs;
    if (startMs == null) return state.elapsedSeconds;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final delta = ((nowMs - startMs) / 1000).floor();
    return state.elapsedSeconds + delta;
  }

  int get activeTimerElapsedSecondsToday {
    final state = _timerState;
    if (state == null || !state.isRunning) return 0;

    final totalElapsed = activeTimerElapsedSeconds;
    final startedAtMs = state.startedAtMs ?? state.startMs;
    if (startedAtMs == null) return totalElapsed;

    final now = DateTime.now();
    final startOfTodayMs = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;

    if (startedAtMs >= startOfTodayMs) {
      return totalElapsed;
    }

    final secondsBeforeToday = ((startOfTodayMs - startedAtMs) / 1000).floor();
    final todayElapsed = totalElapsed - secondsBeforeToday;
    return todayElapsed > 0 ? todayElapsed : 0;
  }

  /// 초기화 및 데이터 로드
  Future<void> initialize() async {
    debugPrint('🔄 AppProvider.initialize() 시작');
    _isLoading = true;
    notifyListeners();
    try {
      // 최대 3초 대기
      _userData = await _storage.getUserData().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          debugPrint('⚠️ Storage 로딩 타임아웃 - 새 데이터 시작');
          return null;
        },
      );
      debugPrint('✅ AppProvider 데이터 로드 완료: $_userData');
      _timerState = await _storage.getTimerState();
    } catch (e) {
      debugPrint('❌ AppProvider 초기화 에러: $e');
      _userData = null;
    } finally {
      _isLoading = false;
      debugPrint('✅ AppProvider._isLoading = false로 설정 (onboardingComplete: ${_userData?.onboardingCompleted ?? false})');
      notifyListeners();
      debugPrint('📢 notifyListeners() 호출 완료');
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
      final oldSessionCount = _userData!.timerSessions.length;
      _userData = updater(_userData!);
      final newSessionCount = _userData!.timerSessions.length;
      
      debugPrint('📝 updateUserData called. Sessions: $oldSessionCount → $newSessionCount');
      notifyListeners();
      debugPrint('📢 notifyListeners() called for Provider updates');
      
      await _storage.saveUserData(_userData!);
      debugPrint('💾 Data saved to storage');
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
    if (_userData == null) {
      debugPrint('❌ completeTimerSession: userData is null');
      return;
    }
    
    final uuid = const Uuid();
    final session = TimerSession(
      id: uuid.v4(),
      category: category,
      durationSeconds: durationSeconds,
      startTime: DateTime.now().millisecondsSinceEpoch - (durationSeconds * 1000),
      endTime: DateTime.now().millisecondsSinceEpoch,
      completed: true,
    );

    debugPrint('📋 Creating TimerSession: category=$category, duration=$durationSeconds seconds');
    
    final minutes = (durationSeconds / 60).floor();
    await _applyRewards(
      exp: minutes * 5, 
      gold: minutes * 3,
      updater: (data) {
        debugPrint('🔄 Updating userData with new timerSession. Current sessions: ${data.timerSessions.length}');
        return data.copyWith(timerSessions: [...data.timerSessions, session]);
      }
    );

    // Firestore 누적 집계는 트랜잭션으로 별도 반영
    // (실패해도 로컬 데이터는 이미 저장되어 UX가 끊기지 않도록 분리)
    await _firebaseService.accumulateFocusDuration(
      category: category,
      durationSeconds: durationSeconds,
    );
    
    debugPrint('✅ completeTimerSession finished. Total sessions: ${_userData?.timerSessions.length}');
  }

  Future<void> startTimer(String category) async {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    _timerState = TimerState(
      category: category,
      elapsedSeconds: 0,
      startMs: nowMs,
      startedAtMs: nowMs,
      isRunning: true,
    );
    notifyListeners();
    await _storage.saveTimerState(_timerState!);
  }

  Future<void> pauseTimer() async {
    final state = _timerState;
    if (state == null || !state.isRunning) return;
    final elapsed = activeTimerElapsedSeconds;
    _timerState = state.copyWith(
      elapsedSeconds: elapsed,
      startMs: null,
      isRunning: false,
    );
    notifyListeners();
    await _storage.saveTimerState(_timerState!);
  }

  Future<void> resumeTimer() async {
    final state = _timerState;
    if (state == null || state.isRunning) return;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    _timerState = state.copyWith(
      startMs: nowMs,
      isRunning: true,
    );
    notifyListeners();
    await _storage.saveTimerState(_timerState!);
  }

  Future<int> stopTimer() async {
    final elapsed = activeTimerElapsedSeconds;
    _timerState = null;
    notifyListeners();
    await _storage.clearTimerState();
    return elapsed;
  }

  Future<void> addTimerCategory(TimerCategory category) async {
    if (_userData == null) return;
    final existing = _userData!.timerCategories.any((c) => c.name == category.name);
    if (existing) return;
    await updateUserData(
      (data) => data.copyWith(
        timerCategories: [...data.timerCategories, category],
      ),
    );
  }

  Future<void> updatePomodoroSettings(PomodoroSettings settings) async {
    await updateUserData((data) => data.copyWith(pomodoroSettings: settings));
  }

  Future<void> togglePomodoro(bool enabled) async {
    final current = pomodoroSettings;
    await updatePomodoroSettings(current.copyWith(enabled: enabled));
  }

  Future<void> addTimerSession({required String category, required int durationSeconds}) async {
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

    await updateUserData((data) =>
        data.copyWith(timerSessions: [...data.timerSessions, session]));
  }

  Future<void> addTimerCategory(TimerCategory category) async {
    if (_userData == null) return;

    final exists = _userData!.timerCategories
        .any((c) => c.name.trim() == category.name.trim());
    if (exists) return;

    final updated = [..._userData!.timerCategories, category];
    await updateUserData((data) => data.copyWith(timerCategories: updated));
  }

  /// 공통 보상 적용 시스템 (레벨업 로직 포함)
  Future<void> _applyRewards({required int exp, required int gold, required UserData Function(UserData) updater}) async {
    debugPrint('🎁 _applyRewards: exp=$exp, gold=$gold');
    
    var currentExp = _userData!.fish.exp + exp;
    var currentLevel = _userData!.fish.level;

    while (currentExp >= 100) {
      currentExp -= 100;
      currentLevel++;
    }

    final updatedFish = _userData!.fish.copyWith(level: currentLevel, exp: currentExp);
    debugPrint('🐠 Fish updated: level=$currentLevel, exp=$currentExp');
    
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

  /// 업적용 함수 추가
  Future<Achievement?> unlockAchievement({
    required String title,
    required String icon,
  }) async {
    if (_userData == null) return null;

    final List<Achievement> list = List<Achievement>.from(_userData!.achievements);

    final idx = list.indexWhere((a) => a.title == title);

    if (idx >= 0) {
      // 이미 있으면 unlocked만 true로 바꿈
      final current = list[idx];
      if (current.unlocked == true) return null;

      // copyWith 없으니까 새 객체로 교체 (id는 유지!)
      final updated = Achievement(
        id: current.id,
        title: title,
        icon: icon,
        description: '개발자용 테스트 업적입니다. (탭으로 완료 처리)',
        unlocked: true,
      );

      list[idx] = updated;
      await updateUserData((data) => data.copyWith(achievements: list));
      return updated;
    } else {
      // 없으면 새로 생성 (id 필수)
      final created = Achievement(
        id: const Uuid().v4(),
        title: title,
        icon: icon,
        description: '개발자용 테스트 업적입니다. (탭으로 완료 처리)',
        unlocked: true,
      );


      list.add(created);
      await updateUserData((data) => data.copyWith(achievements: list));
      return created;
    }
  }


  /// 온보딩 완료 처리
  Future<void> setOnboardingComplete() async {
    if (_userData != null) {
      _userData = _userData!.copyWith(onboardingCompleted: true);
      await _storage.saveUserData(_userData!);
      notifyListeners();
    }
  }
}
