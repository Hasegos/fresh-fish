import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_decorations.dart';
import '../achievements/achievements_screen.dart';

/// 설정 화면
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              const Text(
                'Menu',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),

              // 설정 항목들
              Expanded(
                child: ListView(
                  children: [
                    _buildSection(
                      title: '일반',
                      children: [
                        _buildSettingTile(
                          context,
                          icon: Icons.emoji_events,
                          title: '업적',
                          subtitle: '달성한 업적 보기',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const AchievementsScreen(),
                              ),
                            );
                          },
                        ),
                        _buildSettingTile(
                          context,
                          icon: Icons.notifications,
                          title: '알림 설정',
                          subtitle: '퀘스트 알림 시간 설정',
                          onTap: () => _showComingSoon(context),
                        ),
                        _buildSettingTile(
                          context,
                          icon: Icons.language,
                          title: '언어',
                          subtitle: '한국어',
                          onTap: () => _showComingSoon(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildSection(
                      title: '데이터',
                      children: [
                        _buildSettingTile(
                          context,
                          icon: Icons.cloud_sync,
                          title: 'Firebase 동기화',
                          subtitle: '데이터 백업 및 복원',
                          onTap: () => _showComingSoon(context),
                        ),
                        _buildSettingTile(
                          context,
                          icon: Icons.refresh,
                          title: '데이터 새로고침',
                          subtitle: '데이터 다시 불러오기',
                          onTap: () async {
                            await context.read<AppProvider>().refresh();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('데이터를 새로고침했습니다'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildSection(
                      title: '정보',
                      children: [
                        _buildSettingTile(
                          context,
                          icon: Icons.info,
                          title: '앱 정보',
                          subtitle: 'My Tiny Aquarium v1.0.0',
                          onTap: () => _showAboutDialog(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildSection(
                      title: '위험',
                      children: [
                        _buildSettingTile(
                          context,
                          icon: Icons.delete_forever,
                          title: '모든 데이터 초기화',
                          subtitle: '모든 진행 상황이 삭제됩니다',
                          onTap: () => _showResetDialog(context),
                          isDestructive: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: AppDecorations.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.secondaryPastel,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? AppColors.highlightPink : AppColors.secondaryPastel;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? AppColors.highlightPink : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('준비 중인 기능입니다'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Row(
          children: [
            Text('🐠', style: TextStyle(fontSize: 32)),
            SizedBox(width: 12),
            Text(
              'My Tiny Aquarium',
              style: TextStyle(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '버전: 1.0.0',
              style: TextStyle(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '나만의 작은 수족관에서 물고기를 키우며 생산적인 하루를 만들어보세요.',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              '확인',
              style: TextStyle(
                color: AppColors.primaryPastel,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            const Icon(
              Icons.warning,
              color: AppColors.highlightPink,
            ),
            const SizedBox(width: 12),
            Text(
              '데이터 초기화',
              style: const TextStyle(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: const Text(
          '모든 데이터가 삭제됩니다.\n이 작업은 되돌릴 수 없습니다.\n\n정말 초기화하시겠습니까?',
          style: TextStyle(
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              '취소',
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();

              // 데이터 초기화
              await context.read<AppProvider>().reset();

              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('데이터가 초기화되었습니다'),
                  backgroundColor: AppColors.statusSuccess,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.highlightPink,
            ),
            child: const Text('초기화'),
          ),
        ],
      ),
    );
  }
}