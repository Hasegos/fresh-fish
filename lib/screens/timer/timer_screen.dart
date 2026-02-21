import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';
import '../../providers/user_data_provider.dart';
import '../../models/timer_model.dart';
import '../../models/user_data_model.dart';
import '../../data/timer_categories.dart';
import '../../theme/app_colors.dart';
import '../../services/notification_service.dart';

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

class _TimerScreenState extends State<TimerScreen> with WidgetsBindingObserver {
  Timer? _timer;
  bool _isRunning = false;
  String? _selectedCategory;
  PomodoroPhase _pomodoroPhase = PomodoroPhase.focus;
  int _pomodoroPhaseSeconds = 0;
  int _completedFocusSessions = 0;
  int? _pomodoroPhaseStartMs;
  bool _showTodayTotals = true;
  bool? _lastPomodoroEnabled;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final provider = context.read<AppProvider>();
    _selectedCategory = provider.activeTimerCategory;
    _isRunning = provider.isTimerRunning;

    if (_isRunning) {
      _startUiTicker();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final pomodoro = context.watch<AppProvider>().pomodoroSettings;
    final wasEnabled = _lastPomodoroEnabled;
    _lastPomodoroEnabled = pomodoro.enabled;

    if (wasEnabled == null || wasEnabled == pomodoro.enabled) {
      return;
    }

    if (pomodoro.enabled) {
      _pomodoroPhase = PomodoroPhase.focus;
      _pomodoroPhaseSeconds = 0;
      _pomodoroPhaseStartMs = DateTime.now().millisecondsSinceEpoch;
      if (_isRunning) {
        _schedulePomodoroNotification(pomodoro);
        _startUiTicker();
      }
    } else {
      NotificationService.instance.cancelPomodoroNotifications();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;

    if (state == AppLifecycleState.resumed) {
      if (_isRunning) {
        _startUiTicker();
      } else {
        setState(() {});
      }
      return;
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _timer?.cancel();
    }
  }

  // ✅ 단일 집중 모드: 타이머는 반드시 퀘스트와 연동되어야 함
  String? _linkedQuestId;
  String? _linkedQuestTitle;

  // ✅ 팝업에서도 시간이 실시간으로 갱신되도록 공유하는 노티파이어
  final ValueNotifier<int> _secondsNotifier = ValueNotifier<int>(0);

  // ✅ 팝업 중복 방지
  bool _oneHourPopupShown = false;
  bool _isQuestClearDialogShowing = false;

  // ✅ 1시간
  // 테스트 = 5
  static const int _oneHourSeconds = 60 * 60;

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

  // ✅ 라우트 arguments는 build 이후에 받는 게 안전해서 didChangeDependencies에서 1회 처리
  bool _didApplyRouteArgs = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _restoreTimerState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didApplyRouteArgs) return;
    _didApplyRouteArgs = true;

    // ✅ quests_screen.dart에서 pushNamed('/timer', arguments:{questId, questTitle})로 넘어오는 값 수신
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map) {
      final questId = args['questId']?.toString();
      final questTitle = args['questTitle']?.toString();

      if ((questId ?? '').trim().isNotEmpty) {
        setState(() {
          _linkedQuestId = questId;
          _linkedQuestTitle =
          (questTitle ?? '').trim().isEmpty ? null : questTitle;
          _oneHourPopupShown = false;
        });
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _startUiTicker() {
    _timer?.cancel();
    final pomodoro = context.read<AppProvider>().pomodoroSettings;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted || !_isRunning) return;

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

      if (!mounted) return;
      setState(() {
        if (pomodoro.enabled) {
          final currentMs = DateTime.now().millisecondsSinceEpoch;
          final startMs = _pomodoroPhaseStartMs ?? currentMs;
          _pomodoroPhaseSeconds = ((currentMs - startMs) / 1000).floor();
        }
      });
    });
  }

  /// 타이머 시작/재개 로직
  Future<void> _startTimer(String category) async {
    final provider = context.read<AppProvider>();
    final pomodoro = provider.pomodoroSettings;
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    await provider.startTimer(category);

    setState(() {
      if (_selectedCategory != category && !_isRunning) {
        _elapsedBefore = 0;
        _seconds = 0;
        _secondsNotifier.value = 0;
        _oneHourPopupShown = false;
      }

      _selectedCategory = category;
      _isRunning = true;
      _pomodoroPhase = PomodoroPhase.focus;
      _pomodoroPhaseSeconds = 0;
      _completedFocusSessions = 0;
      _pomodoroPhaseStartMs = nowMs;
    });

    if (pomodoro.enabled) {
      NotificationService.instance.cancelPomodoroNotifications();
      _schedulePomodoroNotification(pomodoro);
    }

    _startUiTicker();
  }

  /// 타이머 일시정지
  Future<void> _pauseTimer() async {
    await context.read<AppProvider>().pauseTimer();
    if (!mounted) return;
    _timer?.cancel();
    NotificationService.instance.cancelPomodoroNotifications();
    setState(() {
      _isRunning = false;
      _elapsedBefore = _computeElapsedSeconds();
      _seconds = _elapsedBefore;
      _secondsNotifier.value = _seconds;
      _startedAtMillis = null;
    });
    _saveTimerState();
  }

  Future<void> _resumeTimer() async {
    final category = _selectedCategory;
    if (category == null) return;

    await context.read<AppProvider>().resumeTimer();
    if (!mounted) return;
    setState(() {
      _isRunning = true;
      if (_pomodoroPhaseStartMs == null) {
        _pomodoroPhaseStartMs = DateTime.now().millisecondsSinceEpoch;
      }
    });

    final pomodoro = context.read<AppProvider>().pomodoroSettings;
    if (pomodoro.enabled) {
      _schedulePomodoroNotification(pomodoro);
    }
    _startUiTicker();
  }

  /// 타이머 종료 및 보상 지급
  Future<void> _stopTimer() async {
    _timer?.cancel();
    NotificationService.instance.cancelPomodoroNotifications();
    final appProvider = context.read<AppProvider>();
    final pomodoro = appProvider.pomodoroSettings;
    final elapsedFromProvider = await appProvider.stopTimer();
    if (!mounted) return;

    // [How] 1분(60초) 이상 집중했을 때만 데이터로 기록하고 보상을 줍니다.
    final focusSeconds = pomodoro.enabled && _pomodoroPhase == PomodoroPhase.focus
        ? _pomodoroPhaseSeconds
        : elapsedFromProvider;
    
    debugPrint('⏹️ Timer Stop - focusSeconds: $focusSeconds, category: $_selectedCategory');
    
    if (focusSeconds > 0 && _selectedCategory != null) {
      debugPrint('💾 Saving timer session: $_selectedCategory for $focusSeconds seconds');
      
      await appProvider.completeTimerSession(
        category: _selectedCategory!,
        durationSeconds: focusSeconds,
      );
      if (!mounted) return;

      // 메인 대시보드(UserDataProvider)가 즉시 반영되도록 동기화
      await context.read<UserDataProvider>().refreshUserData();
      if (!mounted) return;
      
      debugPrint('✅ Timer session saved successfully');

      if (!mounted) return;
      final elapsed = _formatTime(focusSeconds);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⏱️ 이번 집중 시간: $elapsed'),
          backgroundColor: Colors.green,
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⏱️ "${_linkedQuestTitle ?? '퀘스트'}"에 $minutes분 누적 저장됨'),
            backgroundColor: Colors.black87,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('퀘스트 시간 누적 실패: $e')),
        );
      }
    }
  }

  void _resetTimerSessionState() {
    setState(() {
      _isRunning = false;
      _selectedCategory = null;
      _pomodoroPhaseSeconds = 0;
      _pomodoroPhase = PomodoroPhase.focus;
      _completedFocusSessions = 0;
      _pomodoroPhaseStartMs = null;
    });
    _storageService.clearTimerState();
  }

  // ===========================================================
  // ✅ 시간 계산/저장
  // ===========================================================

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')}';
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
      if (!mounted) return;
      await context.read<UserDataProvider>().refreshUserData();
      if (!mounted) return;
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
    final now = DateTime.now();
    var total = 0;
    for (final session in sessions) {
      if (session.category != category) continue;

      final date = DateTime.fromMillisecondsSinceEpoch(session.startTime);

      if (onlyToday) {
        final isSameDay =
            date.year == now.year && date.month == now.month && date.day == now.day;
        if (!isSameDay) continue;
      } else {
        final startOfToday = DateTime(now.year, now.month, now.day);
        final startOfRange = startOfToday.subtract(const Duration(days: 6));
        if (date.isBefore(startOfRange)) continue;
      }

      total += session.durationSeconds;
    }
    return total;
  }

  int _todayTotalSeconds(List<TimerSession> sessions) {
    final today = DateTime.now();
    var total = 0;

    for (final session in sessions) {
      final date = DateTime.fromMillisecondsSinceEpoch(session.startTime);
      final isSameDay =
          date.year == today.year && date.month == today.month && date.day == today.day;
      if (!isSameDay) continue;
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
    final todayTotalSeconds = _todayTotalSeconds(userData?.timerSessions ?? []);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildHeroSection(pomodoro, provider, todayTotalSeconds),
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
                    label: const Text('주간'),
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
            );
          },
        ),
      ),
    );
  }
  Widget _buildHeroSection(
    PomodoroSettings settings,
    AppProvider provider,
    int todayTotalSeconds,
  ) {
    final hasCategory = _selectedCategory != null;
    final currentRunningSeconds = provider.isTimerRunning
      ? provider.activeTimerElapsedSecondsToday
      : 0;
    final displaySeconds = settings.enabled
      ? (_pomodoroPhaseDurationSeconds(settings) - (_isRunning ? _pomodoroPhaseSeconds : 0))
        .clamp(0, _pomodoroPhaseDurationSeconds(settings))
      : todayTotalSeconds + currentRunningSeconds;

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
          if (settings.enabled && hasCategory && _isRunning)
            Text(
              '${_pomodoroPhaseLabel(_pomodoroPhase)} · Session ${_completedFocusSessions + 1}/${settings.sessionsPerCycle}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          if (hasCategory) const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    final appProvider = context.watch<AppProvider>();
    final elapsed = appProvider.activeTimerElapsedSeconds;
    final canResume = !_isRunning && (_selectedCategory != null) && elapsed > 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!_isRunning)
          _buildControlButton(
            icon: canResume ? Icons.play_circle : Icons.play_arrow,
            label: canResume ? '재개' : '시작',
            color: Colors.green,
            onPressed: canResume
                ? _resumeTimer
                : () => _startTimer(_selectedCategory!),
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
    required int totalSeconds,
    required VoidCallback? onTap,
  }) {
    final baseColor = _parseColor(category.color);
    final color = disabled ? Colors.grey : baseColor;

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
      ),
    );
  }
}
