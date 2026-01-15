import 'package:flutter/material.dart';

/// 온보딩 가이드 화면
class OnboardingScreen extends StatelessWidget {
  final VoidCallback? onComplete;

  const OnboardingScreen({
    Key? key,
    required this.onComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A3A52),
              Color(0xFF0D1B2A),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                
                // 아이콘
                const Text(
                  '🐠',
                  style: TextStyle(fontSize: 120),
                ),
                const SizedBox(height: 32),
                
                // 제목
                const Text(
                  'My Tiny Aquarium',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4FC3F7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                // 설명
                const Text(
                  '나만의 작은 수족관에서\n물고기를 키우며\n생산적인 하루를 만들어보세요',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const Spacer(),
                
                // 시작 버튼
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: onComplete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4FC3F7),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      '시작하기',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
