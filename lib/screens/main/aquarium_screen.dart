import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_data_provider.dart';
import '../../models/user_data_model.dart';
import '../../models/fish_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_decorations.dart';
import '../../widgets/aquarium_viewport.dart';
import '../../widgets/bottom_navigation.dart';

/// 메인 어항 화면
class AquariumScreen extends StatelessWidget {
  const AquariumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<UserDataProvider>(
        builder: (context, provider, child) {
          final userData = provider.userData;

          // 데이터 로딩 중이거나 없는 경우 처리
          if (userData == null) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final fish = userData.fish;
          final int gold = userData.gold;

          const expToNextLevel = 100;
          final double expProgress = (fish.exp / expToNextLevel) * 100;

          return Stack(
            children: [
              // 메인 레이아웃
              SafeArea(
                child: Column(
                  children: [
                    _buildHeader(context, gold),
                    Expanded(
                      child: AquariumViewport(
                        fish: fish,
                        waterQuality: userData.waterQuality,
                        decorations: userData.decorations,
                      ),
                    ),
                    _buildFishInfoCard(fish, expToNextLevel, expProgress),
                    _buildDailyProgress(context, userData),
                    const SizedBox(height: 100),
                  ],
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
                    debugPrint("Selected Index: $index");
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
  Widget _buildHeader(BuildContext context, int gold) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Fresh Fish',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ) ??
                const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.highlight.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.highlight.withOpacity(0.3),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.monetization_on,
                    color: AppColors.highlight, size: 18),
                const SizedBox(width: 4),
                Text(
                  gold.toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
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
      decoration: AppDecorations.card(color: AppColors.surface),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(fish.type.emoji, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fish Display',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Lv.${fish.level}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                '${fish.exp}/$maxExp EXP',
                style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (progress / 100).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppColors.surfaceLight,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  /// 일일 진행 상황: 오늘 완료한 퀘스트와 ToDo 표시
  Widget _buildDailyProgress(BuildContext context, UserData userData) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card(color: AppColors.surface),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '오늘의 진행상황',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildProgressItem(
                  '✨',
                  'Dailies',
                  userData.todayCompletedQuests,
                  userData.todayTotalQuests,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildProgressItem(
                  '✅',
                  'To Do',
                  userData.completedTodos,
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
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFEEEEEE),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            '$completed/$total',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}