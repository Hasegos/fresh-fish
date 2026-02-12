import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../providers/user_data_provider.dart';
import '../../models/models.dart';

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
      body: Consumer<UserDataProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = provider.userData;
          if (userData == null) {
            return const Center(
              child: Text(
                '데이터를 불러올 수 없습니다.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          // ✅ DEV 업적이 데이터에 남아있더라도 화면에서는 숨김
          final filteredRaw = userData.achievements
              .where((a) => !a.title.startsWith('[DEV]'))
              .toList();

          final achievements = _buildOrderedAchievements(filteredRaw);

          final unlockedCount = achievements.where((a) => a.unlocked).length;
          final totalCount = achievements.length;
          final percentage =
          totalCount > 0 ? ((unlockedCount / totalCount) * 100).round() : 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProgressHeader(percentage, unlockedCount, totalCount),
                const SizedBox(height: 24),
                const Text(
                  '업적 목록',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
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
                  itemBuilder: (context, index) {
                    final a = achievements[index];
                    return _buildAchievementCard(
                      context,
                      a,
                      onTap: null,
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressHeader(int percentage, int unlocked, int total) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
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
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Text(
            '$unlocked / $total',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(
      BuildContext context,
      _AchievementVM achievement, {
        required VoidCallback? onTap,
      }) {
    final isUnlocked = achievement.unlocked;

    final card = Container(
      decoration: BoxDecoration(
        color: isUnlocked ? AppColors.surface : AppColors.background,
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
            achievement.icon,
            style: TextStyle(
              fontSize: 40,
              color: isUnlocked ? null : AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              achievement.title,
              style: TextStyle(
                fontSize: 12,
                color: isUnlocked ? AppColors.textPrimary : AppColors.textTertiary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 6),
          if (!isUnlocked)
            const Icon(
              Icons.lock,
              size: 16,
              color: AppColors.textTertiary,
            ),
        ],
      ),
    );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: card,
      ),
    );
  }

  List<_AchievementVM> _buildOrderedAchievements(List<Achievement> rawAchievements) {
    final byTitle = <String, Achievement>{};
    for (final a in rawAchievements) {
      if (a.title.isNotEmpty) byTitle[a.title] = a;
    }

    final order = _achievementOrder();

    return order.map((seed) {
      final found = byTitle[seed.title];
      if (found == null) {
        return _AchievementVM(title: seed.title, icon: seed.icon, unlocked: false);
      }

      final icon = (found.icon.isNotEmpty) ? found.icon : seed.icon;

      return _AchievementVM(
        title: found.title,
        icon: icon,
        unlocked: found.unlocked == true,
      );
    }).toList();
  }

  List<_AchievementSeed> _achievementOrder() {
    return const <_AchievementSeed>[
      _AchievementSeed('첫 퀘스트 만들기 (퀘스트 1개 생성)', '📝'),
      _AchievementSeed('첫 클리어 (퀘스트 1개 완료)', '✅'),
      _AchievementSeed('첫 보상 수령 (보상/코인/경험치 첫 획득)', '💰'),
      _AchievementSeed('첫 수정 (퀘스트 수정 1회)', '✏️'),
      _AchievementSeed('연속 완료 3일', '🔥'),
      _AchievementSeed('연속 완료 7일', '🔥'),
      _AchievementSeed('스트릭 복구자 (끊긴 뒤 다시 3일 연속)', '🩹'),
      _AchievementSeed('10개 완료', '🔟'),
      _AchievementSeed('25개 완료', '🏅'),
      _AchievementSeed('50개 완료', '🥈'),
      _AchievementSeed('100개 완료', '🥇'),
      _AchievementSeed('하루 3개 완료', '📅'),
      _AchievementSeed('하루 5개 완료', '📆'),
      _AchievementSeed('주간 20개 완료', '🗓️'),
      _AchievementSeed('월간 100개 완료', '🗓️'),
      _AchievementSeed('서로 다른 카테고리 3개에서 각 1개 완료', '🧩'),
      _AchievementSeed('서로 다른 카테고리 5개에서 각 1개 완료', '🧠'),
      _AchievementSeed('공부 퀘스트 10개 완료', '📚'),
      _AchievementSeed('운동 퀘스트 10개 완료', '🏋️'),
      _AchievementSeed('청소/정리 퀘스트 10개 완료', '🧹'),
      _AchievementSeed('자기관리 퀘스트 20개 완료', '🧴'),
      _AchievementSeed('쉬움 퀘스트 30개 완료', '🙂'),
      _AchievementSeed('어려움 퀘스트 10개 완료', '😤'),
      _AchievementSeed('큰 퀘스트 클리어 (예: 60분 이상/난이도 상) 1회', '🏁'),
      _AchievementSeed('마감 전 완료 10회 (데드라인 있으면)', '⏰'),
      _AchievementSeed('아침형 인간 (06~09시 완료 10회)', '🌅'),
      _AchievementSeed('야행성 (23시 이후 완료 10회)', '🌙'),
      _AchievementSeed('주말에도 한다 (토/일 완료 20회)', '🎌'),
      _AchievementSeed('정리왕 (완료/아카이브 정리 20회)', '🗂️'),
      _AchievementSeed('완벽한 한 주 (주간 목표 100% 달성 1회)', '💯'),
    ];
  }
}

class _AchievementSeed {
  final String title;
  final String icon;
  const _AchievementSeed(this.title, this.icon);
}

class _AchievementVM {
  final String title;
  final String icon;
  final bool unlocked;
  const _AchievementVM({
    required this.title,
    required this.icon,
    required this.unlocked,
  });
}
