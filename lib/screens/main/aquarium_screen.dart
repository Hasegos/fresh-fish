import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_data_provider.dart';
import '../../models/user_data_model.dart'; // [중요] UserData 타입을 인식하기 위해 반드시 필요합니다.
import '../../models/fish_model.dart';
import '../../widgets/aquarium_viewport.dart';
import '../../widgets/bottom_navigation.dart';

/// 메인 어항 화면
class AquariumScreen extends StatelessWidget {
  const AquariumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<UserDataProvider>(
        builder: (context, provider, child) {
          final userData = provider.userData;

          // 데이터 로딩 중이거나 없는 경우 처리
          if (userData == null) {
            return Container(
              color: Color(0xFF0A1628),
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
          }

          final fish = userData.fish;
          final int gold = userData.gold;

          const expToNextLevel = 100;
          final double expProgress = (fish.exp / expToNextLevel) * 100;

          return Stack(
            children: [
              // 배경 및 메인 레이아웃
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF0A1628), Color(0xFF1B263B)],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      _buildHeader(gold),
                      Expanded(
                        child: AquariumViewport(
                          fish: fish,
                          waterQuality: userData.waterQuality,
                          decorations: userData.decorations,
                        ),
                      ),
                      _buildFishInfoCard(fish, expToNextLevel, expProgress),
                      // 모델의 Getter를 사용하는 개선된 위젯 호출
                      _buildDailyProgress(context, userData),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
              // 하단 네비게이션
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: BottomNavigation(
                  currentIndex: 0,
                  onTap: (index) {
                    // 여기에 화면 전환 로직을 추가할 예정입니다.
                    print("Selected Index: $index");
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 헤더: 골드 표시
  Widget _buildHeader(int gold) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'My Tiny Aquarium',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9E6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: Color(0xFFF9A825), size: 18),
                const SizedBox(width: 4),
                Text(
                  gold.toString(),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFF57F17)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 물고기 정보 카드: 레벨 및 경험치 바
  Widget _buildFishInfoCard(Fish fish, int maxExp, double progress) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B).withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF415A77).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Fish 모델의 emoji 필드 사용
                  Text(fish.type.emoji, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fish.type.displayName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text('Lv.${fish.level}', style: const TextStyle(fontSize: 14, color: Color(0xFF778DA9))),
                    ],
                  ),
                ],
              ),
              Text('${fish.exp}/$maxExp EXP', style: const TextStyle(fontSize: 12, color: Color(0xFF90A4AE))),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (progress / 100).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: const Color(0xFF0D1B2A),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
            ),
          ),
        ],
      ),
    );
  }

  /// 일일 진행 상황: 오늘 완료한 퀘스트와 ToDo 표시
  /// [Point] 모델에 미리 정의해둔 Getter를 사용하여 로직을 단순화했습니다.
  Widget _buildDailyProgress(BuildContext context, UserData userData) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF415A77).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('오늘의 진행상황', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          Row(
            children: [
              // 일일 퀘스트 진행도
              Expanded(
                child: _buildProgressItem(
                  '✨',
                  'Dailies',
                  userData.todayCompletedQuests, // 모델의 계산된 값 사용
                  userData.todayTotalQuests,
                ),
              ),
              const SizedBox(width: 12),
              // 전체 ToDo 진행도
              Expanded(
                child: _buildProgressItem(
                  '✅',
                  'To Do',
                  userData.completedTodos,      // 모델의 계산된 값 사용
                  userData.todos.length,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 개별 진행 아이템 위젯
  Widget _buildProgressItem(String emoji, String label, int completed, int total) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A).withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF778DA9))),
          const SizedBox(height: 4),
          // 분모가 0인 경우 처리
          Text(
            '$completed/$total',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}