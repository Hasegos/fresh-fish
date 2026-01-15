import 'package:flutter/foundation.dart' hide Category;
import '../models/models.dart';
import '../services/storage_service.dart';

/// 사용자 데이터 상태 관리 Provider
class UserDataProvider extends ChangeNotifier {
  UserData? _userData;
  bool _isLoading = true;
  
  /// 온보딩 단계
  OnboardingStep _onboardingStep = OnboardingStep.guide;
  
  /// 선택된 카테고리들
  List<Category> _selectedCategories = [];
  
  /// 현재 페이지
  AppPage _currentPage = AppPage.main;

  // Getters
  UserData? get userData => _userData;
  bool get isLoading => _isLoading;
  OnboardingStep get onboardingStep => _onboardingStep;
  List<Category> get selectedCategories => _selectedCategories;
  AppPage get currentPage => _currentPage;
  
  /// 온보딩 완료 여부
  bool get isOnboardingComplete => _userData?.onboardingCompleted ?? false;

  UserDataProvider() {
    _loadUserData();
  }

  /// 사용자 데이터 로드
  Future<void> _loadUserData() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await storageService.init();
      final data = await storageService.getUserData();
      
      if (data != null && data.onboardingCompleted) {
        _userData = data;
        _onboardingStep = OnboardingStep.complete;
      }
    } catch (e) {
      debugPrint('사용자 데이터 로드 실패: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }

  /// 사용자 데이터 새로고침
  Future<void> refreshUserData() async {
    await _loadUserData();
  }

  /// 온보딩 완료
  void completeOnboarding() {
    _onboardingStep = OnboardingStep.categorySelection;
    notifyListeners();
  }

  /// 카테고리 선택
  void selectCategories(List<Category> categories) {
    _selectedCategories = categories;
    _onboardingStep = OnboardingStep.eggSelection;
    notifyListeners();
  }

  /// 알 선택 및 초기 사용자 생성
  Future<void> selectEgg(FishType fishType) async {
    final newUser = await storageService.createInitialUser(
      fishType,
      _selectedCategories,
    );
    await storageService.saveUserData(newUser);
    _userData = newUser;
    _onboardingStep = OnboardingStep.complete;
    notifyListeners();
  }

  /// 사용자 데이터 업데이트
  Future<void> updateUserData(UserData data) async {
    _userData = data;
    await storageService.saveUserData(data);
    notifyListeners();
  }

  /// 페이지 이동
  void navigateTo(AppPage page) {
    _currentPage = page;
    notifyListeners();
  }

  /// 메인으로 돌아가기
  Future<void> backToMain() async {
    _currentPage = AppPage.main;
    await refreshUserData();
  }

  /// 앱 초기화 (디버그용)
  Future<void> resetApp() async {
    _userData = null;
    _onboardingStep = OnboardingStep.guide;
    _selectedCategories = [];
    _currentPage = AppPage.main;
    // 저장소 초기화는 storage_service에서 처리
    notifyListeners();
  }

  /// 퀘스트 완료 처리
  Future<void> completeQuest(String questId, int expGain, int goldGain) async {
    if (_userData == null) return;

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

    final updatedData = _userData!.copyWith(
      fish: updatedFish,
      gold: _userData!.gold + goldGain,
      quests: updatedQuests,
      waterQuality: (_userData!.waterQuality + 3).clamp(0, 100),
    );

    await updateUserData(updatedData);
  }

  /// 습관 완료
  Future<void> completeHabit(String habitId) async {
    if (_userData == null) return;

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

    final habit = _userData!.habits.firstWhere((h) => h.id == habitId);
    await completeQuest(habitId, habit.expReward, habit.goldReward);

    final updatedData = _userData!.copyWith(habits: updatedHabits);
    await updateUserData(updatedData);
  }

  /// ToDo 완료
  Future<void> completeTodo(String todoId) async {
    if (_userData == null) return;

    final updatedTodos = _userData!.todos.map((t) {
      if (t.id == todoId) {
        return t.copyWith(completed: true);
      }
      return t;
    }).toList();

    final todo = _userData!.todos.firstWhere((t) => t.id == todoId);
    await completeQuest(todoId, todo.expReward, todo.goldReward);

    final updatedData = _userData!.copyWith(todos: updatedTodos);
    await updateUserData(updatedData);
  }
}

/// 온보딩 단계
enum OnboardingStep {
  guide,              // 가이드
  categorySelection,  // 카테고리 선택
  eggSelection,       // 알 선택
  complete,           // 완료
}

/// 앱 페이지
enum AppPage {
  main,              // 메인 어항
  dailies,           // 데일리 퀘스트
  todos,             // 할 일
  calendar,          // 캘린더
  settings,          // 설정
  decorationShop,    // 장식 상점
  decorationManager, // 장식 관리
}
