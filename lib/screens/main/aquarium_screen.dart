import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_data_provider.dart';
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
          if (userData == null) {
            return const Center(
              child: Text('데이터를 불러올 수 없습니다'),
            );
          }

          final fish = userData.fish;
          final gold = userData.gold;
          
          // EXP 진행도 계산
          const expToNextLevel = 100;
          final expProgress = (fish.exp / expToNextLevel) * 100;

          return Stack(
            children: [
              // 메인 컨텐츠
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF0A1628),
                      Color(0xFF1B263B),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      // 헤더
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'My Tiny Aquarium',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            // 골드 표시
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF9E6),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.monetization_on,
                                    color: Color(0xFFF9A825),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$gold',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFF57F17),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 어항 뷰포트
                      Expanded(
                        child: AquariumViewport(
                          fish: fish,
                          decorations: userData.decorations,
                        ),
                      ),

                      // 물고기 정보 카드
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B263B).withOpacity(0.8),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF415A77).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            // 물고기 이름과 레벨
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      fish.type.emoji,
                                      style: const TextStyle(fontSize: 32),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          fish.type.displayName,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          'Lv.${fish.level}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF778DA9),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Text(
                                  '${fish.exp}/$expToNextLevel EXP',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF90A4AE),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            
                            // EXP 진행바
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: expProgress / 100,
                                minHeight: 8,
                                backgroundColor: const Color(0xFF0D1B2A),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF4CAF50),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 오늘의 진행상황
                      _buildDailyProgress(context, userData),
                      
                      const SizedBox(height: 80), // 하단 네비게이션 공간
                    ],
                  ),
                ),
              ),

              // 하단 네비게이션
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: BottomNavigation(),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 오늘의 진행상황 위젯
  Widget _buildDailyProgress(BuildContext context, dynamic userData) {
    // 오늘 날짜
    final today = DateTime.now().toIso8601String().split('T')[0];
    final todayQuests = userData.quests
        .where((q) => q.date == today)
        .toList();
    final completedQuests = todayQuests.where((q) => q.completed).length;
    
    final todos = userData.todos;
    final completedTodos = todos.where((t) => t.completed).length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF415A77).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '오늘의 진행상황',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildProgressItem(
                  '✨',
                  'Dailies',
                  completedQuests,
                  todayQuests.length,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildProgressItem(
                  '✅',
                  'To Do',
                  completedTodos,
                  todos.length,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 진행 항목 위젯
  Widget _buildProgressItem(String emoji, String label, int completed, int total) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A).withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF778DA9),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$completed/$total',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
