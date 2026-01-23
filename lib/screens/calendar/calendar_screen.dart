import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_decorations.dart';

/// 캘린더 화면 (활동 기록)
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<AppProvider>(
          builder: (context, provider, child) {
            final userData = provider.userData;
            if (userData == null) {
              return const Center(child: Text('데이터 없음', style: TextStyle(color: AppColors.textPrimary)));
            }

            final List history = userData.history;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Calendar', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  Text('${history.length}일 기록됨', style: const TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                  const SizedBox(height: 24),

                  // 통계 카드 섹션
                  _buildStatsCard(history),
                  const SizedBox(height: 24),

                  const Text('최근 기록', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 16),

                  Expanded(
                    child: history.isEmpty
                        ? const Center(child: Text('아직 기록이 없습니다', style: TextStyle(color: AppColors.textTertiary)))
                        : ListView.builder(
                          itemCount: history.length,
                          itemBuilder: (context, index) {
                            final record = history[history.length - 1 - index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: _buildHistoryCard(record),
                            );
                          },
                        ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatsCard(List history) {
    final totalDays = history.length;
    final successDays = history.where((r) => r.status.name == 'success').length;

    final totalQuests = history.fold<int>(0, (sum, r) => sum + (r.totalQuests as int));
    final completedQuests = history.fold<int>(0, (sum, r) => sum + (r.completedQuests as int));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.card(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(icon: Icons.calendar_today, label: '총 일수', value: '$totalDays일', color: AppColors.primary),
          _buildStatItem(icon: Icons.check_circle, label: '성공', value: '$successDays일', color: AppColors.success),
          _buildStatItem(icon: Icons.assignment, label: '완료', value: '$completedQuests/$totalQuests', color: AppColors.warning),
        ],
      ),
    );
  }

  Widget _buildStatItem({required IconData icon, required String label, required String value, required Color color}) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  // [Critical Fix] dynamic 레코드에서 String과 int 값을 안전하게 추출합니다.
  Widget _buildHistoryCard(dynamic record) {
    final String statusName = record.status.name as String;
    final String date = record.date as String;
    final int completed = record.completedQuests as int;
    final int total = record.totalQuests as int;

    // [Why] 완료율 계산 수식: $$ \text{rate} = \frac{\text{completed}}{\text{total}} \times 100 $$
    final int rate = total > 0 ? ((completed / total) * 100).round() : 0;

    final statusColor = _getStatusColor(statusName);
    final statusIcon = _getStatusIcon(statusName);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.featureCard(accentColor: statusColor),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: statusColor.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(statusIcon, color: statusColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text('$completed/$total 완료', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text('$rate%', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: statusColor)),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'success': return Colors.green;
      case 'partial': return Colors.orange;
      case 'fail': return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'success': return Icons.check_circle;
      case 'partial': return Icons.adjust;
      case 'fail': return Icons.cancel;
      default: return Icons.help;
    }
  }
}