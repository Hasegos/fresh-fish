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
    
    // 데이터 로딩 대기
    while (provider.isLoading) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    // 최소 스플래시 시간 (1초)
    await Future.delayed(const Duration(seconds: 1));
    
    if (!mounted) return;
    
    // 온보딩 완료 여부에 따라 화면 이동
    if (provider.isOnboardingComplete) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AppScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 앱 아이콘/로고
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
              
              // 앱 이름
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
              
              // 로딩 인디케이터
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