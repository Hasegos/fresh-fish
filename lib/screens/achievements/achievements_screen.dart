import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
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

          final raw = userData.achievements as List<dynamic>;
          final achievements = _buildOrderedAchievements(raw);

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

  // [Critical Fix] 에러가 발생했던 핵심 함수
  Widget _buildAchievementCard(_AchievementVM achievement) {
    final String iconEmoji = achievement.icon;
    final String title = achievement.title;
    final bool isUnlocked = achievement.unlocked;

    return Container(
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
            ),
        ],
      ),
    );
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

/// ✅ 여기 리스트 순서 = 화면 표시 순서
const List<_AchievementSeed> _achievementOrder = [
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

List<_AchievementVM> _buildOrderedAchievements(List<dynamic> rawAchievements) {
  // title 기준으로 매칭해서 순서 고정 + 없는 업적은 잠금으로 채움
  final mapByTitle = <String, dynamic>{};
  for (final a in rawAchievements) {
    final t = (a.title as String?) ?? '';
    if (t.isNotEmpty) mapByTitle[t] = a;
  }

  return _achievementOrder.map((seed) {
    final a = mapByTitle[seed.title];
    if (a == null) {
      return _AchievementVM(title: seed.title, icon: seed.icon, unlocked: false);
    }
    return _AchievementVM(
      title: (a.title as String?) ?? seed.title,
      icon: (a.icon as String?) ?? seed.icon,
      unlocked: a.unlocked == true,
    );
  }).toList();
}
