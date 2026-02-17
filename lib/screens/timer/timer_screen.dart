import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/timer_model.dart';
import '../../models/user_data_model.dart';
import '../../data/timer_categories.dart';
import '../../theme/app_colors.dart';
import '../../services/notification_service.dart';

/// [TimerScreen]
/// 사용자가 특정 카테고리를 선택해 집중 시간을 측정하고 보상을 받는 화면입니다.
class TimerScreen extends StatefulWidget {
  const TimerScreen({Key? key}) : super(key: key);

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

enum PomodoroPhase {
  focus,
  shortBreak,
  longBreak,
}

class _TimerScreenState extends State<TimerScreen> {
  Timer? _timer;
  int _seconds = 0;
  bool _isRunning = false;
  String? _selectedCategory;
  PomodoroPhase _pomodoroPhase = PomodoroPhase.focus;
  int _pomodoroPhaseSeconds = 0;
  int _completedFocusSessions = 0;
  int? _pomodoroPhaseStartMs;
  bool _showTodayTotals = true;

  @override
  void dispose() {
    // [Why] 화면을 벗어날 때 타이머를 멈추지 않으면 메모리 누수(Memory Leak)가 발생합니다.
    _timer?.cancel();
    super.dispose();
  }

  /// 타이머 시작/재개 로직
  void _startTimer(String category) {
    final pomodoro = context.read<AppProvider>().pomodoroSettings;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    setState(() {
      _selectedCategory = category;
      _isRunning = true;
      _seconds = 0;
      _pomodoroPhase = PomodoroPhase.focus;
      _pomodoroPhaseSeconds = 0;
      _completedFocusSessions = 0;
      _pomodoroPhaseStartMs = nowMs;
    });

    if (pomodoro.enabled) {
      NotificationService.instance.cancelPomodoroNotifications();
      _schedulePomodoroNotification(pomodoro);
    }

    _timer?.cancel(); // 기존 타이머가 있다면 중복 방지를 위해 취소
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      final shouldAdvancePhase = pomodoro.enabled && () {
        final currentMs = DateTime.now().millisecondsSinceEpoch;
        final startMs = _pomodoroPhaseStartMs ?? currentMs;
        final elapsed = ((currentMs - startMs) / 1000).floor();
        final phaseLimit = _pomodoroPhaseDurationSeconds(pomodoro);
        return elapsed >= phaseLimit;
      }();

      if (shouldAdvancePhase) {
        await _advancePomodoroPhase(pomodoro);
      }

      setState(() {
        if (pomodoro.enabled) {
          final currentMs = DateTime.now().millisecondsSinceEpoch;
          final startMs = _pomodoroPhaseStartMs ?? currentMs;
          _pomodoroPhaseSeconds = ((currentMs - startMs) / 1000).floor();
        } else {
          _seconds++;
        }
      });
    });
  }

  /// 타이머 일시정지
  void _pauseTimer() {
    _timer?.cancel();
    NotificationService.instance.cancelPomodoroNotifications();
    setState(() {
      _isRunning = false;
    });
  }

  /// 타이머 종료 및 보상 지급
  Future<void> _stopTimer() async {
    _timer?.cancel();
    NotificationService.instance.cancelPomodoroNotifications();
    final pomodoro = context.read<AppProvider>().pomodoroSettings;

    // [How] 1분(60초) 이상 집중했을 때만 데이터로 기록하고 보상을 줍니다.
    final focusSeconds = pomodoro.enabled && _pomodoroPhase == PomodoroPhase.focus
        ? _pomodoroPhaseSeconds
        : _seconds;
    
    debugPrint('⏹️ Timer Stop - focusSeconds: $focusSeconds, category: $_selectedCategory');
    
    if (focusSeconds >= 60 && _selectedCategory != null) {
      final provider = context.read<AppProvider>();
      debugPrint('💾 Saving timer session: $_selectedCategory for $focusSeconds seconds');
      
      await provider.completeTimerSession(
        category: _selectedCategory!,
        durationSeconds: focusSeconds,
      );
      
      debugPrint('✅ Timer session saved successfully');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 ${(focusSeconds / 60).floor()}분 집중 완료! 물고기가 기뻐합니다.'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (focusSeconds > 0) {
      final elapsed = _formatTime(focusSeconds);
      debugPrint('⏱️ Short session - $elapsed');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⏱️ 이번 집중 시간: $elapsed'),
          backgroundColor: AppColors.primaryPastel,
        ),
      );
    }

    setState(() {
      _isRunning = false;
      _seconds = 0;
      _selectedCategory = null;
      _pomodoroPhaseSeconds = 0;
      _pomodoroPhase = PomodoroPhase.focus;
      _completedFocusSessions = 0;
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

  int _displaySeconds(PomodoroSettings settings) {
    return settings.enabled ? _pomodoroPhaseSeconds : _seconds;
  }

  int _pomodoroPhaseDurationSeconds(PomodoroSettings settings) {
    switch (_pomodoroPhase) {
      case PomodoroPhase.focus:
        return settings.focusMinutes * 60;
      case PomodoroPhase.shortBreak:
        return settings.shortBreakMinutes * 60;
      case PomodoroPhase.longBreak:
        return settings.longBreakMinutes * 60;
    }
  }

  Future<void> _advancePomodoroPhase(PomodoroSettings settings) async {
    if (_pomodoroPhase == PomodoroPhase.focus && _selectedCategory != null) {
      await context.read<AppProvider>().completeTimerSession(
        category: _selectedCategory!,
        durationSeconds: settings.focusMinutes * 60,
      );
      _completedFocusSessions++;
    }

    if (_pomodoroPhase == PomodoroPhase.focus) {
      final isLongBreak = _completedFocusSessions % settings.sessionsPerCycle == 0;
      _pomodoroPhase = isLongBreak ? PomodoroPhase.longBreak : PomodoroPhase.shortBreak;
    } else {
      _pomodoroPhase = PomodoroPhase.focus;
    }

    _pomodoroPhaseSeconds = 0;
    _pomodoroPhaseStartMs = DateTime.now().millisecondsSinceEpoch;

    if (_isRunning) {
      _schedulePomodoroNotification(settings);
    }
  }

  void _schedulePomodoroNotification(PomodoroSettings settings) {
    final phaseSeconds = _pomodoroPhaseDurationSeconds(settings);
    final title = _pomodoroPhase == PomodoroPhase.focus
        ? 'Focus Time 완료'
        : 'Break Time 완료';
    final nextLabel = _pomodoroPhase == PomodoroPhase.focus
        ? '휴식을 시작하세요'
        : '집중을 시작하세요';
    NotificationService.instance.schedulePomodoroPhaseEnd(
      secondsFromNow: phaseSeconds - _pomodoroPhaseSeconds,
      title: title,
      body: nextLabel,
    );
  }

  String _pomodoroPhaseLabel(PomodoroPhase phase) {
    switch (phase) {
      case PomodoroPhase.focus:
        return 'Focus Time';
      case PomodoroPhase.shortBreak:
        return 'Short Break';
      case PomodoroPhase.longBreak:
        return 'Long Break';
    }
  }

  /// Hex 색상 문자열을 Color 객체로 변환
  Color _parseColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  int _categoryTotalSeconds(
    List<TimerSession> sessions,
    String category, {
    required bool onlyToday,
  }) {
    final today = DateTime.now();
    var total = 0;
    for (final session in sessions) {
      if (session.category != category) continue;
      if (onlyToday) {
        final date = DateTime.fromMillisecondsSinceEpoch(session.startTime);
        final isSameDay = date.year == today.year && date.month == today.month && date.day == today.day;
        if (!isSameDay) continue;
      }
      total += session.durationSeconds;
    }
    return total;
  }

  String _formatCompactDuration(int seconds) {
    if (seconds <= 0) return '0m';
    final minutes = (seconds / 60).floor();
    final hours = minutes ~/ 60;
    final remaining = minutes % 60;
    if (hours > 0) {
      return '${hours}h ${remaining}m';
    }
    return '${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final userData = provider.userData;
    final pomodoro = provider.pomodoroSettings;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildHeroSection(pomodoro),
              const SizedBox(height: 24),

              // 컨트롤 버튼 (카테고리 선택 시에만 노출)
              if (_selectedCategory != null) _buildControlPanel(),
              const SizedBox(height: 24),

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      '카테고리',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ),
                  ChoiceChip(
                    label: const Text('오늘'),
                    selected: _showTodayTotals,
                    onSelected: (value) {
                      setState(() {
                        _showTodayTotals = true;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('전체'),
                    selected: !_showTodayTotals,
                    onSelected: (value) {
                      setState(() {
                        _showTodayTotals = false;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 카테고리 목록
              Expanded(
                child: ListView.separated(
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemCount: defaultTimerCategories.length,
                  itemBuilder: (context, index) {
                    final category = defaultTimerCategories[index];
                    final isSelected = _selectedCategory == category.name;
                    final totalSeconds = _categoryTotalSeconds(
                      userData?.timerSessions ?? [],
                      category.name,
                      onlyToday: _showTodayTotals,
                    );

                    return _buildCategoryCard(
                      category: category,
                      isSelected: isSelected,
                      totalSeconds: totalSeconds,
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
  Widget _buildHeroSection(PomodoroSettings settings) {
    final hasCategory = _selectedCategory != null;
    final displaySeconds = _displaySeconds(settings);
    final statusText = !hasCategory
        ? '카테고리를 선택하세요'
        : _isRunning
            ? '집중 중: $_selectedCategory · ${_formatTime(displaySeconds)}'
            : '준비 완료: $_selectedCategory';

    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.28,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: BoxDecoration(
        gradient: AppColors.progressGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            _formatTime(displaySeconds),
            style: const TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1,
            ),
          ),
          const SizedBox(height: 10),
          if (settings.enabled && hasCategory)
            Text(
              '${_pomodoroPhaseLabel(_pomodoroPhase)} · Session ${_completedFocusSessions + 1}/${settings.sessionsPerCycle}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.95),
            ),
          ),
        ],
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
    required int totalSeconds,
    required VoidCallback? onTap,
  }) {
    final color = _parseColor(category.color);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.12) : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : AppColors.textTertiary.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.2) : AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.play_arrow,
                size: 24,
                color: isSelected ? color : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                category.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? color : AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              _formatCompactDuration(totalSeconds),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
