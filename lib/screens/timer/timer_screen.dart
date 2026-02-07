import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/timer_model.dart';
import '../../data/timer_categories.dart';
import '../../theme/app_colors.dart';
import '../../services/storage_service.dart';

/// [TimerScreen]
/// 사용자가 특정 카테고리를 선택해 집중 시간을 측정하고 보상을 받는 화면입니다.
class TimerScreen extends StatefulWidget {
  const TimerScreen({Key? key}) : super(key: key);

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with WidgetsBindingObserver {
  final StorageService _storageService = StorageService();
  Timer? _timer;
  int _seconds = 0;
  int _elapsedBefore = 0;
  int? _startedAtMillis;
  bool _isRunning = false;
  String? _selectedCategory;

  static const List<String> _fallbackColors = [
    '#4FC3F7',
    '#9575CD',
    '#81C784',
    '#FFB74D',
    '#F06292',
    '#90A4AE',
    '#64B5F6',
    '#AED581',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _restoreTimerState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // [Why] 화면을 벗어날 때 타이머를 멈추지 않으면 메모리 누수(Memory Leak)가 발생합니다.
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _saveTimerState();
      _timer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      _syncElapsed();
      if (_isRunning) {
        _startTicker();
      }
    }
  }

  /// 타이머 시작/재개 로직
  void _startTimer(String category) {
    setState(() {
      if (_selectedCategory != category && !_isRunning) {
        _elapsedBefore = 0;
        _seconds = 0;
      }
      _selectedCategory = category;
      _isRunning = true;
      if (_startedAtMillis == null) {
        _startedAtMillis = DateTime.now().millisecondsSinceEpoch;
      }
    });

    _startTicker();
    _saveTimerState();
  }

  /// 타이머 일시정지
  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _elapsedBefore = _computeElapsedSeconds();
      _seconds = _elapsedBefore;
      _startedAtMillis = null;
    });
    _saveTimerState();
  }

  /// 타이머 종료 및 보상 지급
  Future<void> _stopTimer() async {
    _timer?.cancel();
    final totalSeconds = _computeElapsedSeconds();

    if (_selectedCategory != null && totalSeconds > 0) {
      final provider = context.read<AppProvider>();
      if (totalSeconds >= 60) {
        await provider.completeTimerSession(
          category: _selectedCategory!,
          durationSeconds: totalSeconds,
        );

        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 ${(totalSeconds / 60).floor()}분 집중 완료! 물고기가 기뻐합니다.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await provider.addTimerSession(
          category: _selectedCategory!,
          durationSeconds: totalSeconds,
        );

        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('기록 완료! (1분 미만)'),
            backgroundColor: Colors.blueGrey,
          ),
        );
      }
    }

    setState(() {
      _isRunning = false;
      _seconds = 0;
      _elapsedBefore = 0;
      _startedAtMillis = null;
      _selectedCategory = null;
    });
    _storageService.clearTimerState();
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

  int _computeElapsedSeconds() {
    if (!_isRunning || _startedAtMillis == null) return _elapsedBefore;
    final now = DateTime.now().millisecondsSinceEpoch;
    final diffSeconds = ((now - _startedAtMillis!) / 1000).floor();
    return _elapsedBefore + diffSeconds;
  }

  void _startTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _seconds = _computeElapsedSeconds();
      });
    });
  }

  void _syncElapsed() {
    setState(() {
      _seconds = _computeElapsedSeconds();
    });
  }

  Future<void> _restoreTimerState() async {
    final state = await _storageService.getTimerState();
    if (state == null) return;

    setState(() {
      _selectedCategory = state.category;
      _elapsedBefore = state.elapsedSeconds;
      _startedAtMillis = state.startedAtMillis;
      _isRunning = state.isRunning && _selectedCategory != null;
      _seconds = _computeElapsedSeconds();
    });

    if (_isRunning) {
      _startTicker();
    }
  }

  Future<void> _saveTimerState() async {
    final state = TimerRunState(
      isRunning: _isRunning,
      category: _selectedCategory,
      elapsedSeconds: _elapsedBefore,
      startedAtMillis: _isRunning ? _startedAtMillis : null,
    );
    await _storageService.saveTimerState(state);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<AppProvider>(
          builder: (context, provider, child) {
            final userData = provider.userData;
            final categories = userData?.timerCategories ?? defaultTimerCategories;
            final sessions = userData?.timerSessions ?? <TimerSession>[];
            final todayTotals = _buildTodayTotals(sessions);
            final displayTotals = _buildDisplayTotals(todayTotals);

            return Padding(
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
                  const SizedBox(height: 24),

                  // 중앙 타이머 원형 디스플레이
                  _buildTimerDisplay(),
                  const SizedBox(height: 20),

                  // 컨트롤 버튼 (카테고리 선택 시에만 노출)
                  if (_selectedCategory != null) _buildControlPanel(),
                  const SizedBox(height: 24),

                  const Text('카테고리', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),

                  Expanded(
                    child: ListView.separated(
                      itemCount: categories.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        if (index == categories.length) {
                          return _buildAddCategoryRow(
                            isDisabled: _isRunning,
                            onTap: _isRunning ? null : () => _openAddCategoryDialog(provider, categories.length),
                          );
                        }

                        final category = categories[index];
                        final isSelected = _selectedCategory == category.name;
                        final seconds = displayTotals[category.name] ?? 0;

                        return _buildCategoryRow(
                          category: category,
                          isSelected: isSelected,
                          seconds: seconds,
                          onTap: _isRunning && !isSelected
                              ? null
                              : () => _startTimer(category.name),
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

  Widget _buildCategoryRow({
    required TimerCategory category,
    required bool isSelected,
    required int seconds,
    required VoidCallback? onTap,
  }) {
    final color = _parseColor(category.color);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.12) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : AppColors.borderLight,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Text(category.icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                category.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? color : AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              _formatTime(seconds),
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

  Widget _buildAddCategoryRow({required bool isDisabled, required VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Icon(
              Icons.add_circle_outline,
              color: isDisabled ? AppColors.textTertiary : AppColors.primary,
            ),
            const SizedBox(width: 10),
            Text(
              '카테고리 추가',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDisabled ? AppColors.textTertiary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, int> _buildTodayTotals(List<TimerSession> sessions) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final tomorrowStart = DateTime(now.year, now.month, now.day + 1).millisecondsSinceEpoch;
    final totals = <String, int>{};

    for (final session in sessions) {
      if (session.startTime >= todayStart && session.startTime < tomorrowStart) {
        totals[session.category] = (totals[session.category] ?? 0) + session.durationSeconds;
      }
    }

    return totals;
  }

  Map<String, int> _buildDisplayTotals(Map<String, int> baseTotals) {
    final totals = Map<String, int>.from(baseTotals);
    if (_selectedCategory != null) {
      final extra = _computeElapsedSeconds();
      totals[_selectedCategory!] = (totals[_selectedCategory!] ?? 0) + extra;
    }
    return totals;
  }

  Future<void> _openAddCategoryDialog(AppProvider provider, int categoryCount) async {
    final nameController = TextEditingController();
    final iconController = TextEditingController(text: '🧩');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('카테고리 추가'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: '카테고리 이름'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: iconController,
                decoration: const InputDecoration(labelText: '아이콘 (이모지)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('추가'),
            ),
          ],
        );
      },
    );

    if (result != true) return;
    final name = nameController.text.trim();
    if (name.isEmpty) return;

    final icon = iconController.text.trim().isEmpty ? '🧩' : iconController.text.trim();
    final color = _fallbackColors[categoryCount % _fallbackColors.length];

    await provider.addTimerCategory(
      TimerCategory(name: name, icon: icon, color: color),
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