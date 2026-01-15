import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';

/// 캘린더 화면
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A3A52),
            Color(0xFF0D1B2A),
          ],
        ),
      ),
      child: SafeArea(
        child: Consumer<AppProvider>(
          builder: (context, provider, child) {
            final userData = provider.userData;
            if (userData == null) {
              return const Center(child: Text('데이터 없음'));
            }

            final history = userData.history;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 헤더
                  const Text(
                    '활동 기록',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${history.length}일 기록됨',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 통계 카드
                  _buildStatsCard(history),
                  const SizedBox(height: 24),

                  // 히스토리 목록
                  const Text(
                    '최근 기록',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Expanded(
                    child: history.isEmpty
                        ? const Center(
                            child: Text(
                              '아직 기록이 없습니다',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white54,
                              ),
                            ),
                          )
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
    final totalQuests = history.fold<int>(0, (sum, r) => sum + r.totalQuests as int);
    final completedQuests = history.fold<int>(0, (sum, r) => sum + r.completedQuests as int);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2A3A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.calendar_today,
            label: '총 일수',
            value: '$totalDays일',
            color: const Color(0xFF4FC3F7),
          ),
          _buildStatItem(
            icon: Icons.check_circle,
            label: '성공',
            value: '$successDays일',
            color: Colors.green,
          ),
          _buildStatItem(
            icon: Icons.assignment,
            label: '완료',
            value: '$completedQuests/$totalQuests',
            color: Colors.amber,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryCard(record) {
    final statusColor = _getStatusColor(record.status.name);
    final statusIcon = _getStatusIcon(record.status.name);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2A3A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // 아이콘
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusColor),
          ),
          const SizedBox(width: 16),

          // 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.date,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${record.completedQuests}/${record.totalQuests} 완료',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // 완료율
          Text(
            '${((record.completedQuests / record.totalQuests) * 100).round()}%',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'success':
        return Colors.green;
      case 'partial':
        return Colors.orange;
      case 'fail':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'success':
        return Icons.check_circle;
      case 'partial':
        return Icons.adjust;
      case 'fail':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }
}
