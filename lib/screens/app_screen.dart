import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
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
          onComplete: () {
            debugPrint('🎉 Step 2 완료 → 온보딩 완료 처리');
            final appProvider = Provider.of<AppProvider>(context, listen: false);
            appProvider.updateUserData(
              (data) => data.copyWith(onboardingCompleted: true),
            );
            // setState 호출 불필요 - Provider가 rebuild를 트리거함
          },
        );
      default:
        return const OnboardingScreen(onComplete: null);
    }
  }
}
