import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_data_provider.dart';
import '../theme/app_colors.dart';
import 'onboarding/onboarding_screen.dart';
import 'app_screen.dart';

/// 스플래시 화면 (로딩)
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    final provider = context.read<UserDataProvider>();

    // 1. 데이터 로딩 대기
    // Provider의 초기화가 완료될 때까지 대기합니다.
    while (provider.isLoading) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // 2. 최소 스플래시 노출 시간 (사용자 경험을 위해 1초간 브랜드 노출)
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    // 3. 온보딩 완료 여부에 따라 화면 이동
    if (provider.isOnboardingComplete) {
      // 이미 온보딩을 했다면 메인 어항으로 이동
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AppScreen()),
      );
    } else {
      // 처음 온 사용자라면 온보딩 화면으로 이동
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OnboardingScreen(
            // [Fix] 필수 인자인 onComplete를 추가했습니다.
            onComplete: () {
              // 온보딩이 끝나면 AppScreen으로 이동하도록 설정합니다.
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const AppScreen()),
              );
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          // 배경 그라데이션 적용
          gradient: AppColors.backgroundGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 앱 로고 영역
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '🐠',
                    style: TextStyle(fontSize: 60),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // 앱 타이틀
              const Text(
                'My Tiny Aquarium',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '나만의 작은 수족관',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 48),

              // 하단 로딩 표시
              const CircularProgressIndicator(
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}