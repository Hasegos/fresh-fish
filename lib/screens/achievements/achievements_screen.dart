import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
// [Mentor Tip] 실제 모델 클래스를 임포트하면 dynamic 대신 정확한 타입을 쓸 수 있습니다.
// import '../../models/achievement_model.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E2A3A),
        title: const Text('🏆 업적', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          final userData = provider.userData;
          if (userData == null) {
            return const Center(child: Text('데이터를 불러올 수 없습니다.', style: TextStyle(color: Colors.white)));
          }

          final achievements = userData.achievements;
          final unlockedCount = achievements.where((a) => a.unlocked).length;
          final totalCount = achievements.length;
          final percentage = totalCount > 0 ? ((unlockedCount / totalCount) * 100).round() : 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProgressHeader(percentage, unlockedCount, totalCount),
                const SizedBox(height: 24),
                _buildStatsGrid(userData),
                const SizedBox(height: 24),
                const Text('업적 목록', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 16),

                // 업적 그리드
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: achievements.length,
                  itemBuilder: (context, index) => _buildAchievementCard(achievements[index]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 상단 진행률 카드
  Widget _buildProgressHeader(int percentage, int unlocked, int total) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF4FC3F7), Color(0xFF2196F3)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              const Text('전체 달성률', style: TextStyle(fontSize: 16, color: Colors.white)),
              Text('$percentage%', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          Text('$unlocked / $total', style: const TextStyle(fontSize: 18, color: Colors.white70)),
        ],
      ),
    );
  }

  // 통계 그리드
  Widget _buildStatsGrid(dynamic userData) {
    return Row(
      children: [
        _buildStatItem('레벨', '${userData.fish.level}', Colors.amber),
        const SizedBox(width: 10),
        _buildStatItem('골드', '${userData.gold}', Colors.yellow),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFF1E2A3A), borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // [Critical Fix] 에러가 발생했던 핵심 함수
  Widget _buildAchievementCard(dynamic achievement) {
    // [How] as String을 사용하여 dynamic 타입을 String으로 명시해줍니다.
    final String iconEmoji = achievement.icon as String;
    final String title = achievement.title as String;
    final bool isUnlocked = achievement.unlocked == true;

    return Container(
      decoration: BoxDecoration(
        color: isUnlocked ? const Color(0xFF1E2A3A) : Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isUnlocked ? const Color(0xFF4FC3F7) : Colors.transparent),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(iconEmoji, style: TextStyle(fontSize: 40, color: isUnlocked ? null : Colors.white24)),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: isUnlocked ? Colors.white : Colors.white24),
            textAlign: TextAlign.center,
          ),
          if (!isUnlocked) const Icon(Icons.lock, size: 16, color: Colors.white24),
        ],
      ),
    );
  }
}