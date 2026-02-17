import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';
import '../../models/user_data_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_decorations.dart';
import '../achievements/achievements_screen.dart';

/// 설정 화면
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final pomodoro = p.userData?.pomodoroSettings ?? const PomodoroSettings();

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
                          subtitle: _notifModeLabel(p),
                          onTap: () => _openNotifModeSheet(context),
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
                      title: 'Pomodoro',
                      children: [
                        _buildPomodoroToggle(context, pomodoro, p),
                        _buildPomodoroTile(
                          context,
                          title: '집중 시간',
                          value: '${pomodoro.focusMinutes}분',
                          onTap: () => _editPomodoroMinutes(
                            context,
                            label: '집중 시간 (분)',
                            initialValue: pomodoro.focusMinutes,
                            onSaved: (value) => p.updatePomodoroSettings(
                              pomodoro.copyWith(focusMinutes: value),
                            ),
                          ),
                        ),
                        _buildPomodoroTile(
                          context,
                          title: '짧은 휴식',
                          value: '${pomodoro.shortBreakMinutes}분',
                          onTap: () => _editPomodoroMinutes(
                            context,
                            label: '짧은 휴식 (분)',
                            initialValue: pomodoro.shortBreakMinutes,
                            onSaved: (value) => p.updatePomodoroSettings(
                              pomodoro.copyWith(shortBreakMinutes: value),
                            ),
                          ),
                        ),
                        _buildPomodoroTile(
                          context,
                          title: '긴 휴식',
                          value: '${pomodoro.longBreakMinutes}분',
                          onTap: () => _editPomodoroMinutes(
                            context,
                            label: '긴 휴식 (분)',
                            initialValue: pomodoro.longBreakMinutes,
                            onSaved: (value) => p.updatePomodoroSettings(
                              pomodoro.copyWith(longBreakMinutes: value),
                            ),
                          ),
                        ),
                        _buildPomodoroTile(
                          context,
                          title: '세션 수',
                          value: '${pomodoro.sessionsPerCycle}회',
                          onTap: () => _editPomodoroMinutes(
                            context,
                            label: '세션 수',
                            initialValue: pomodoro.sessionsPerCycle,
                            minValue: 2,
                            maxValue: 8,
                            onSaved: (value) => p.updatePomodoroSettings(
                              pomodoro.copyWith(sessionsPerCycle: value),
                            ),
                          ),
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

  // -------------------------
  // UI Helpers
  // -------------------------

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
            const Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------
  // Pomodoro settings
  // -------------------------

  Widget _buildPomodoroToggle(BuildContext context, PomodoroSettings settings, AppProvider p) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.timer, color: AppColors.secondaryPastel),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Pomodoro Mode',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Switch(
            value: settings.enabled,
            onChanged: (value) => p.togglePomodoro(value),
            activeColor: AppColors.primaryPastel,
          ),
        ],
      ),
    );
  }

  Widget _buildPomodoroTile(
    BuildContext context, {
      required String title,
      required String value,
      required VoidCallback onTap,
    }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }

  Future<void> _editPomodoroMinutes(
    BuildContext context, {
      required String label,
      required int initialValue,
      int minValue = 1,
      int maxValue = 90,
      required Future<void> Function(int value) onSaved,
    }) async {
    final controller = TextEditingController(text: initialValue.toString());
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(label, style: const TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '$minValue-$maxValue',
            hintStyle: const TextStyle(color: AppColors.textTertiary),
          ),
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text.trim());
              if (value == null || value < minValue || value > maxValue) {
                Navigator.of(context).pop();
                return;
              }
              Navigator.of(context).pop(value);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPastel),
            child: const Text('저장'),
          ),
        ],
      ),
    );

    if (result != null) {
      await onSaved(result);
    }
  }

  // -------------------------
  // 알림 모드 (소리/진동/무음)
  // -------------------------

  String _notifModeLabel(AppProvider p) {
    // 우선순위: 무음 > 진동 > 소리
    if (p.notifSilent == true) return '현재: 무음';
    if (p.notifVibration == true) return '현재: 진동';
    if (p.notifSound == true) return '현재: 소리';
    return '현재: 무음';
  }

  void _openNotifModeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '알림 모드',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  '앱 알림이 울릴 때 소리/진동/무음을 선택해요',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),

                Consumer<AppProvider>(
                  builder: (context, p, _) {
                    final selected = p.notifSilent == true
                        ? 'silent'
                        : (p.notifVibration == true ? 'vibrate' : 'sound');

                    return Row(
                      children: [
                        Expanded(
                          child: _ModeBox(
                            title: '소리',
                            icon: Icons.volume_up,
                            selected: selected == 'sound',
                            onTap: () {
                              // 소리 모드
                              p.setNotifSilent(false);
                              p.setNotifVibration(false);
                              p.setNotifSound(true);
                              Navigator.pop(sheetContext);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ModeBox(
                            title: '진동',
                            icon: Icons.vibration,
                            selected: selected == 'vibrate',
                            onTap: () {
                              // 진동 모드
                              p.setNotifSilent(false);
                              p.setNotifSound(false);
                              p.setNotifVibration(true);
                              Navigator.pop(sheetContext);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ModeBox(
                            title: '무음',
                            icon: Icons.notifications_off,
                            selected: selected == 'silent',
                            onTap: () {
                              // 무음 모드
                              p.setNotifSilent(true);
                              p.setNotifSound(false);
                              p.setNotifVibration(false);
                              Navigator.pop(sheetContext);
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 14),
              ],
            ),
          ),
        );
      },
    );
  }

  // -------------------------
  // Dialogs / Snackbars
  // -------------------------

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
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '버전: 1.0.0',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              '나만의 작은 수족관에서 물고기를 키우며 생산적인 하루를 만들어보세요.',
              style: TextStyle(
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
              style: TextStyle(color: AppColors.primaryPastel),
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
        title: const Row(
          children: [
            Icon(Icons.warning, color: AppColors.highlightPink),
            SizedBox(width: 12),
            Text('데이터 초기화', style: TextStyle(color: AppColors.textPrimary)),
          ],
        ),
        content: const Text(
          '모든 데이터가 삭제됩니다.\n이 작업은 되돌릴 수 없습니다.\n\n정말 초기화하시겠습니까?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              '취소',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
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

class _ModeBox extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModeBox({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? AppColors.primaryPastel.withOpacity(0.8)
        : AppColors.borderLight;

    final bg = selected
        ? AppColors.primaryPastel.withOpacity(0.12)
        : AppColors.surface;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 26,
              color: selected ? AppColors.primaryPastel : AppColors.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
