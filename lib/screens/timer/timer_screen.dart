import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/timer_model.dart';
import '../../data/timer_categories.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_decorations.dart';

/// [TimerScreen]
/// 사용자가 특정 카테고리를 선택해 집중 시간을 측정하고 보상을 받는 화면입니다.
class TimerScreen extends StatefulWidget {
  const TimerScreen({Key? key}) : super(key: key);

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  Timer? _timer;
  int _seconds = 0;
  bool _isRunning = false;
  String? _selectedCategory;

  @override
  void dispose() {
    // [Why] 화면을 벗어날 때 타이머를 멈추지 않으면 메모리 누수(Memory Leak)가 발생합니다.
    _timer?.cancel();
    super.dispose();
  }

  /// 타이머 시작/재개 로직
  void _startTimer(String category) {
    setState(() {
      _selectedCategory = category;
      _isRunning = true;
    });

    _timer?.cancel(); // 기존 타이머가 있다면 중복 방지를 위해 취소
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  /// 타이머 일시정지
  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  /// 타이머 종료 및 보상 지급
  void _stopTimer() {
    _timer?.cancel();

    // [How] 1분(60초) 이상 집중했을 때만 데이터로 기록하고 보상을 줍니다.
    if (_seconds >= 60 && _selectedCategory != null) {
      final provider = context.read<AppProvider>();
      provider.completeTimerSession(
        category: _selectedCategory!,
        durationSeconds: _seconds,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 ${(_seconds / 60).floor()}분 집중 완료! 물고기가 기뻐합니다.'),
          backgroundColor: Colors.green,
        ),
      );
    }

    setState(() {
      _isRunning = false;
      _seconds = 0;
      _selectedCategory = null;
    });
  }

  /// 초 단위를 00:00:00 형식으로 변환
  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                '⏱️ Timer',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                _selectedCategory != null ? '집중 중: $_selectedCategory' : '카테고리를 선택하여 시작하세요',
                style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),

              // 중앙 타이머 원형 디스플레이
              _buildTimerDisplay(),
              const SizedBox(height: 32),

              // 컨트롤 버튼 (카테고리 선택 시에만 노출)
              if (_selectedCategory != null) _buildControlPanel(),
              const SizedBox(height: 32),

              const Text('카테고리', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 16),

              // 카테고리 그리드 목록
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: defaultTimerCategories.length,
                  itemBuilder: (context, index) {
                    final category = defaultTimerCategories[index];
                    final isSelected = _selectedCategory == category.name;

                    return _buildCategoryCard(
                      category: category,
                      isSelected: isSelected,
                      onTap: _isRunning ? null : () => _startTimer(category.name),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimerDisplay() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: _isRunning ? AppColors.primary : AppColors.textTertiary,
          width: 4,
        ),
      ),
      child: Text(
        _formatTime(_seconds),
        style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontFamily: 'monospace'),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!_isRunning)
          _buildControlButton(
            icon: Icons.play_arrow,
            label: '시작',
            color: Colors.green,
            onPressed: () => _startTimer(_selectedCategory!),
          ),
        if (_isRunning)
          _buildControlButton(
            icon: Icons.pause,
            label: '일시정지',
            color: Colors.orange,
            onPressed: _pauseTimer,
          ),
        const SizedBox(width: 16),
        _buildControlButton(
          icon: Icons.stop,
          label: '종료',
          color: Colors.red,
          onPressed: _stopTimer,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 24),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }

  Widget _buildCategoryCard({
    required TimerCategory category,
    required bool isSelected,
    required VoidCallback? onTap,
  }) {
    final color = _parseColor(category.color);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : AppColors.textTertiary.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(category.icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 4),
            Text(
              category.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? color : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 헥사 코드 문자열을 Color 객체로 변환
  Color _parseColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}