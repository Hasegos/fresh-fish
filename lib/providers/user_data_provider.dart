import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../models/skin_model.dart';
import '../services/storage_service.dart';

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

    debugPrint("🚀 [Provider LOG 1] 데이터 로딩 시작...");
    try {
      _userData = await _storageService.getUserData().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          debugPrint('⚠️ UserDataProvider Storage 로딩 타임아웃');
          return null;
        },
      );
      debugPrint("🚀 [Provider LOG 2] 데이터 로딩 성공: ${_userData != null}");
    } catch (e) {
      debugPrint("❌ [Provider ERROR] 로딩 중 에러 발생: $e");
      debugPrint('Error loading user data: $e');
      _userData = null;
    }

    _isLoading = false;
    notifyListeners(); // 로딩 종료 알림
    debugPrint("🚀 [Provider LOG 3] 초기화 프로세스 종료");
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

  /// 퀘스트 완료 로직
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

    await updateUserData((data) => data.copyWith(
      fish: updatedFish,
      gold: data.gold + goldGain,
      quests: updatedQuests,
      waterQuality: (data.waterQuality + 3).clamp(0, 100),
    ));
  }

  // 👇 [새로 추가된 메서드 1: 장식 구매]
  /// [Why] 상점에서 아이템을 구매할 때 골드를 차감하고 소유 목록에 추가하기 위해 필요합니다.
  /// [How] 골드가 충분한지 확인한 후, copyWith를 통해 기존 데이터를 업데이트합니다.
  Future<bool> purchaseDecoration(String decorationId, int price) async {
    if (_userData == null) return false;

    // 1. 골드 부족 여부 체크
    if (_userData!.gold < price) {
      debugPrint("❌ 골드가 부족하여 구매할 수 없습니다.");
      return false;
    }

    // 2. 소유 목록 업데이트 및 골드 차감
    final updatedOwned = [..._userData!.ownedDecorations, decorationId];

    await updateUserData((data) => data.copyWith(
      gold: data.gold - price,
      ownedDecorations: updatedOwned,
    ));

    debugPrint("✅ 장식 구매 성공: $decorationId");
    return true;
  }

  // 👇 [새로 추가된 메서드 2: 스킨 구매]
  /// [Why] 상점에서 스킨을 구매할 때 골드를 차감하고 소유 목록에 추가하기 위해 필요합니다.
  Future<bool> purchaseSkin(Skin skin) async {
    if (_userData == null) return false;

    final skinId = skin.id;
    final skinCost = skin.cost;

    // 1. 골드 부족 여부 체크
    if (_userData!.gold < skinCost) {
      debugPrint("❌ 골드가 부족하여 구매할 수 없습니다.");
      return false;
    }

    // 2. 소유 목록 업데이트 및 골드 차감
    final updatedOwned = <String>[..._userData!.ownedSkins, skinId];

    await updateUserData((data) => data.copyWith(
      gold: data.gold - skinCost,
      ownedSkins: updatedOwned,
    ));

    debugPrint("✅ 스킨 구매 성공: $skinId");
    return true;
  }

  // 👇 [새로 추가된 메서드 3: 스킨 적용]
  /// [Why] 보유한 스킨을 활성화하기 위해 필요합니다.
  /// 기존 물고기의 스킨(타입)만 변경합니다.
  Future<void> setActiveSkin(String skinId) async {
    if (_userData == null) return;

    // 소유한 스킨인지 확인
    if (!_userData!.ownedSkins.contains(skinId)) {
      debugPrint("❌ 소유하지 않은 스킨입니다.");
      return;
    }

    // 스킨 ID로부터 물고기 타입 결정
    final fishType = _getFishTypeFromSkinId(skinId);
    
    // 기존 물고기를 새 타입으로 변경
    final updatedFish = _userData!.fish.copyWith(type: fishType);

    await updateUserData((data) => data.copyWith(
      activeSkinId: skinId,
      fish: updatedFish,
    ));

    debugPrint("✅ 스킨 적용 성공: $skinId, 물고기 타입: $fishType");
  }

  /// 스킨 ID로부터 물고기 타입을 결정합니다.
  /// 각 스킨은 특정 물고기 타입으로 변환됩니다.
  FishType _getFishTypeFromSkinId(String skinId) {
    switch (skinId) {
      case 'skin_default':
        return FishType.goldfish;
      case 'skin_goldfish':
        return FishType.goldfish;
      case 'skin_stripedfish':
        return FishType.bluefish;
      case 'skin_neonparty':
        return FishType.tropical;
      case 'skin_oceanboss':
        return FishType.dolphin;
      case 'skin_phoenix':
        return FishType.redfish;
      case 'skin_crystal':
        return FishType.clownfish;
      case 'skin_galaxy':
        return FishType.tropical;
      case 'skin_dragon':
        return FishType.dolphin;
      default:
        return FishType.goldfish;
    }
  }

  // 👇 [새로 추가된 메서드 4: 메인으로 이동]
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