import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_decorations.dart';
import '../../providers/app_provider.dart';
// [Mentor Tip] 실제 모델 클래스를 임포트하면 dynamic 대신 정확한 타입을 쓸 수 있습니다.
// import '../../models/achievement_model.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          '🏆 업적',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          final userData = provider.userData;
          if (userData == null) {
            return const Center(
              child: Text(
                '데이터를 불러올 수 없습니다.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
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
                const Text(
                  '업적 목록',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
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
        gradient: const LinearGradient(
          colors: [AppColors.primaryPastel, AppColors.secondaryPastel],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              const Text(
                '전체 달성률',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              Text(
                '$percentage%',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,AppColors.accentPastel),
        const SizedBox(width: 10),
        _buildStatItem('골드', '${userData.gold}', AppColors.highlightPink),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            

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
            Text(label, stylAppColors.surface : AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked
              ? AppColors.primaryPastel.withOpacity(0.3)
              : AppColors.borderLight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            iconEmoji,
            style: TextStyle(
              fontSize: 40,
              color: isUnlocked ? null : AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isUnlocked ? AppColors.textPrimary : AppColors.textTertiary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          if (!isUnlocked)
            Icon(
              Icons.lock,
              size: 16,
              color: AppColors.textTertiary,
            
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