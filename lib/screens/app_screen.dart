import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/app_provider.dart';
import '../models/fish_model.dart';
import '../models/user_data_model.dart';
import 'onboarding/onboarding_screen.dart';
import 'onboarding/category_selection_screen.dart';
import 'onboarding/egg_selection_screen.dart';
import 'main/main_screen.dart';

/// 앱 메인 진입점
class AppScreen extends StatelessWidget {
  const AppScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        // 로딩 중
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '🐠',
                    style: TextStyle(fontSize: 80),
                  ),
                  SizedBox(height: 24),
                  CircularProgressIndicator(
                    color: Color(0xFF4FC3F7),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'My Tiny Aquarium',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // userData가 없거나 onboarding이 안됨
        if (provider.userData == null || !provider.isOnboardingComplete) {
          debugPrint('🔄 OnboardingFlow로 진입 (userData: ${provider.userData != null}, onboarding: ${provider.isOnboardingComplete})');
          return const OnboardingFlow();
        }

        // 메인 앱
        debugPrint('✅ MainScreen으로 진입');
        return const MainScreen();
      },
    );
  }
}

/// 온보딩 플로우
class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({Key? key}) : super(key: key);

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  int _step = 0;
  List<String> _selectedCategories = [];
  FishType? _selectedFish;

  /// 사용자 데이터 생성 (onboarding 완료 시)
  Future<void> _createUserData() async {
    if (_selectedFish == null) {
      debugPrint('❌ 선택된 물고기가 없음');
      return;
    }

    try {
      debugPrint('🎣 UserData 생성 중... (fish: $_selectedFish, categories: $_selectedCategories)');
      
      final uuid = const Uuid();
      final userId = uuid.v4();
      
      // Fish 객체 생성
      final fish = Fish(
        id: userId,
        type: _selectedFish!,
        level: 1,
        exp: 0,
        hp: 100,
        maxHp: 100,
        eggHatchedAt: DateTime.now().millisecondsSinceEpoch,
      );

      // UserData 객체 생성
      final userData = UserData(
        id: userId,
        fish: fish,
        gold: 100,
        currentDate: DateTime.now().toIso8601String().split('T')[0],
        quests: [],
        habits: [],
        todos: [],
        history: [],
        onboardingCompleted: true,
        selectedCategories: _selectedCategories,
        waterQuality: 80,
        achievements: [],
        customRewards: [],
        decorations: [],
        ownedDecorations: [],
        ownedSkins: ['skin_default'],
        activeSkinId: 'skin_default',
        timerSessions: [],
      );

      debugPrint('✅ UserData 생성 완료: $userId');

      // AppProvider에 저장 (또는 직접 storage 저장)
      if (mounted) {
        final appProvider = context.read<AppProvider>();
        await appProvider.saveUserData(userData);
        debugPrint('💾 AppProvider에 UserData 저장 완료');
      }
    } catch (e) {
      debugPrint('❌ UserData 생성 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_step) {
      case 0:
        return OnboardingScreen(
          onComplete: () {
            setState(() => _step = 1);
          },
        );
      case 1:
        return CategorySelectionScreen(
          onComplete: (categories) {
            setState(() {
              _selectedCategories = categories;
              _step = 2;
            });
          },
        );
      case 2:
        return EggSelectionScreen(
          selectedCategories: _selectedCategories,
          onComplete: (selectedFishType) async {
            debugPrint('🎉 EggSelection 완료 → UserData 생성 및 저장');
            setState(() => _selectedFish = selectedFishType);
            await _createUserData();
          },
        );
      default:
        return const OnboardingScreen(onComplete: null);
    }
  }
}
