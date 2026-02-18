import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';
import '../../providers/user_data_provider.dart';
import '../../models/timer_model.dart';
import '../../data/timer_categories.dart';
import '../../theme/app_colors.dart';
import '../../services/storage_service.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({Key? key}) : super(key: key);

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with WidgetsBindingObserver {
  final StorageService _storageService = StorageService();
  Timer? _timer;

  int _seconds = 0;
  int _elapsedBefore = 0;
  int? _startedAtMillis;
  bool _isRunning = false;
  String? _selectedCategory;

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
    _secondsNotifier.dispose();
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

  // ===========================================================
  // ✅ 단일 집중 모드 가드
  // ===========================================================

  bool _ensureQuestLinkedOrWarn() {
    if (_linkedQuestId != null) return true;
    if (!mounted) return false;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('단일 집중 모드: 먼저 퀘스트를 선택(연동)해야 타이머를 시작할 수 있어요.'),
      ),
    );
    return false;
  }

  Future<void> _pickLinkedQuest() async {
    // 단일 집중 모드라도 "연동 퀘스트 변경"은 허용(단, 실행 중에는 비활성화)
    final questProvider = context.read<UserDataProvider>();
    final userData = questProvider.userData;
    if (userData == null) return;

    final candidates = userData.quests.where((q) => q.completed != true).toList();

    if (candidates.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('연동할 진행 중 퀘스트가 없습니다. (퀘스트를 먼저 생성해줘)'),
        ),
      );
      return;
    }

    final pickedId = await showDialog<String>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('타이머와 연동할 퀘스트 선택'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: candidates.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final q = candidates[index];
                return ListTile(
                  leading: const Icon(Icons.flag_outlined),
                  title: Text(q.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text('난이도: ${q.difficulty.displayName}'),
                  onTap: () => Navigator.pop(context, q.id),
                );
              },
            ),
          ),
        );
      },
    );

    if (!mounted) return;
    if (pickedId == null) return;

    final pickedQuest = candidates.firstWhere((q) => q.id == pickedId);
    setState(() {
      _linkedQuestId = pickedQuest.id;
      _linkedQuestTitle = pickedQuest.title;
      _oneHourPopupShown = false;
    });
  }

  // ===========================================================
  // ✅ 타이머 실행/정지
  // ===========================================================

  void _startTimer(String category) {
    // ✅ 단일 집중 모드: 퀘스트 없으면 시작 불가
    if (!_ensureQuestLinkedOrWarn()) return;

    setState(() {
      if (_selectedCategory != category && !_isRunning) {
        _elapsedBefore = 0;
        _seconds = 0;
        _secondsNotifier.value = 0;
        _oneHourPopupShown = false;
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

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _elapsedBefore = _computeElapsedSeconds();
      _seconds = _elapsedBefore;
      _secondsNotifier.value = _seconds;
      _startedAtMillis = null;
    });
    _saveTimerState();
  }

  Future<void> _stopTimer() async {
    _timer?.cancel();
    final totalSeconds = _computeElapsedSeconds();

    // ✅ (1) 퀘스트 시간 누적: 분 단위로 저장
    await _persistLinkedQuestMinutes(totalSeconds);

    // ✅ (2) 기존 타이머 세션 보상/기록 로직 유지
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

    _resetTimerSessionState();
  }

  Future<void> _persistLinkedQuestMinutes(int totalSeconds) async {
    if (_linkedQuestId == null) return;
    if (totalSeconds <= 0) return;

    final minutes = (totalSeconds / 60).floor();
    if (minutes <= 0) return;

    try {
      await context.read<UserDataProvider>().addQuestDurationMinutes(
        questId: _linkedQuestId!,
        addMinutes: minutes,
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
      _seconds = 0;
      _elapsedBefore = 0;
      _startedAtMillis = null;
      _selectedCategory = null;

      _secondsNotifier.value = 0;
      _oneHourPopupShown = false;
      _isQuestClearDialogShowing = false;
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

      final current = _computeElapsedSeconds();

      setState(() {
        _seconds = current;
      });

      _secondsNotifier.value = current;

      _maybeShowOneHourPopup(current);
    });
  }

  void _syncElapsed() {
    final current = _computeElapsedSeconds();
    setState(() {
      _seconds = current;
    });
    _secondsNotifier.value = current;
    _maybeShowOneHourPopup(current);
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
    _secondsNotifier.value = _seconds;

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

  // ===========================================================
  // ✅ 1시간 조건 달성 팝업 + 완료 처리
  // ===========================================================

  void _maybeShowOneHourPopup(int currentSeconds) {
    if (!_isRunning) return;
    if (_linkedQuestId == null) return;
    if (_oneHourPopupShown) return;
    if (_isQuestClearDialogShowing) return;

    if (currentSeconds >= _oneHourSeconds) {
      _oneHourPopupShown = true;
      _isQuestClearDialogShowing = true;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;

        try {
          await showDialog(
            context: context,
            useRootNavigator: true,
            barrierDismissible: true,
            builder: (dialogContext) => _buildQuestConditionDialog(dialogContext),
          );
        } finally {
          if (mounted) {
            _isQuestClearDialogShowing = false;
          }
        }
      });
    }
  }

  Widget _buildQuestConditionDialog(BuildContext dialogContext) {
    final title = _linkedQuestTitle ?? '연동 퀘스트';

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 6),
            const Text(
              '🎉 퀘스트 클리어 조건 달성!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            Text(
              '"$title"\n집중 60분을 달성했어요.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, height: 1.35),
            ),
            const SizedBox(height: 14),
            ValueListenableBuilder<int>(
              valueListenable: _secondsNotifier,
              builder: (_, seconds, __) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.black.withOpacity(0.04),
                  ),
                  child: Column(
                    children: [
                      const Text('현재 경과 시간', style: TextStyle(fontSize: 12)),
                      const SizedBox(height: 6),
                      Text(
                        _formatTime(seconds),
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'monospace',
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
            const Text(
              '지금 완료 처리할까요?\n(완료 시 타이머는 종료 처리돼요)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.35),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        Navigator.of(dialogContext, rootNavigator: true).pop(),
                    child: const Text('나중에'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final questId = _linkedQuestId;
                      if (questId == null) {
                        Navigator.of(dialogContext, rootNavigator: true).pop();
                        return;
                      }

                      // ✅ 팝업 닫기
                      Navigator.of(dialogContext, rootNavigator: true).pop();

                      // ✅ 실제 퀘스트 완료 처리 (현재까지 누적 반영 포함)
                      await _completeLinkedQuestAndShowBigClearIfNeeded(questId);
                    },
                    child: const Text('완료하기'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================
  // ✅ 업적 달성 팝업 (요청 UI 스타일)
  // ===========================================================

  Future<void> _showAchievementUnlockedPopup({
    required String title,
    required String icon,
    String message = '계속 진행해보자',
  }) async {
    if (!mounted) return;

    await showDialog(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 22),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 14, 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '업적 달성',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(icon, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () =>
                        Navigator.of(dialogContext, rootNavigator: true).pop(),
                    child: const Text('확인'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showAchievementPopupsSequentially(List unlocked) async {
    for (final a in unlocked) {
      final String title = (a.title ?? '').toString();
      final String icon = (a.icon ?? '🏆').toString();
      if (title.trim().isEmpty) continue;

      await _showAchievementUnlockedPopup(
        title: title,
        icon: icon,
      );
    }
  }

  Future<void> _completeLinkedQuestAndShowBigClearIfNeeded(String questId) async {
    try {
      final provider = context.read<UserDataProvider>();

      // ✅ 현재까지 경과 시간을 분으로 누적 저장
      final totalSeconds = _computeElapsedSeconds();
      await _persistLinkedQuestMinutes(totalSeconds);

      // ✅ 퀘스트 완료 처리 (업적 리스트 반환)
      final unlocked = await provider.completeQuestById(questId);

      // ✅ 업적 달성 팝업
      if (unlocked.isNotEmpty) {
        await _showAchievementPopupsSequentially(unlocked);
      }

      // ✅ 완료된 퀘스트 다시 조회(스냅샷 isBigQuest 확인)
      final data = provider.userData;
      final completedQuest = data?.quests.firstWhere(
            (q) => q.id == questId,
        orElse: () => throw Exception('Quest not found after complete'),
      );

      final isBig = (completedQuest?.isBigQuest == true);

      if (!mounted) return;

      if (isBig) {
        _showBigQuestClearOverlay(
          title: completedQuest?.title ?? (_linkedQuestTitle ?? '퀘스트'),
          unlockedCount: unlocked.length,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ 퀘스트 완료!')),
        );
      }

      // ✅ 완료 처리 후: 세션 종료
      _timer?.cancel();
      _resetTimerSessionState();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('퀘스트 완료 처리 실패: $e')),
      );
    }
  }

  void _showBigQuestClearOverlay({
    required String title,
    required int unlockedCount,
  }) {
    showGeneralDialog(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      barrierLabel: '큰 퀘스트 클리어',
      barrierColor: Colors.black.withOpacity(0.70),
      pageBuilder: (_, __, ___) {
        return SafeArea(
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 18),
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '🏁 BIG QUEST CLEAR!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '큰 퀘스트 조건을 만족했어요.\n정말 잘했어요!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.35),
                    ),
                    const SizedBox(height: 16),
                    ValueListenableBuilder<int>(
                      valueListenable: _secondsNotifier,
                      builder: (_, seconds, __) {
                        return Text(
                          '현재 경과: ${_formatTime(seconds)}',
                          style: const TextStyle(fontSize: 13, color: Colors.black54),
                        );
                      },
                    ),
                    if (unlockedCount > 0) ...[
                      const SizedBox(height: 12),
                      Text(
                        '🏆 업적 $unlockedCount개 해금!',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                      ),
                    ],
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                        child: const Text('확인'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 220),
      transitionBuilder: (_, anim, __, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        return Transform.scale(
          scale: 0.92 + (0.08 * curved.value),
          child: Opacity(opacity: curved.value, child: child),
        );
      },
    );
  }

  // ===========================================================
  // ✅ UI
  // ===========================================================

  @override
  Widget build(BuildContext context) {
    final disabled = (_linkedQuestId == null) && !_isRunning;

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
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedCategory != null
                        ? '집중 중: $_selectedCategory'
                        : (_linkedQuestId == null
                        ? '퀘스트를 선택(연동)해야 시작할 수 있어요'
                        : '카테고리를 선택하여 시작하세요'),
                    style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 10),

                  // ✅ 연동 퀘스트 표시 (버튼 대신 "변경")
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.link,
                          size: 18,
                          color: _linkedQuestId == null
                              ? AppColors.textTertiary
                              : AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _linkedQuestId == null
                                ? '연동 퀘스트: 없음'
                                : '연동 퀘스트: ${_linkedQuestTitle ?? ''}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _isRunning ? null : _pickLinkedQuest,
                          child: const Text('변경'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  _buildTimerDisplay(),
                  const SizedBox(height: 20),
                  if (_selectedCategory != null) _buildControlPanel(),
                  const SizedBox(height: 24),

                  // ✅ "카테고리" 옆으로 안내 문구 이동
                  Row(
                    children: [
                      const Text(
                        '카테고리',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (disabled)
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Text(
                                '퀘스트를 연동하면 카테고리를 선택할 수 있어요',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child: ListView.separated(
                      itemCount: categories.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        if (index == categories.length) {
                          return _buildAddCategoryRow(
                            isDisabled: _isRunning || disabled,
                            onTap: (_isRunning || disabled)
                                ? null
                                : () => _openAddCategoryDialog(provider, categories.length),
                          );
                        }

                        final category = categories[index];
                        final isSelected = _selectedCategory == category.name;
                        final seconds = displayTotals[category.name] ?? 0;

                        return _buildCategoryRow(
                          category: category,
                          isSelected: isSelected,
                          seconds: seconds,
                          disabled: disabled,
                          onTap: (_isRunning && !isSelected) || disabled
                              ? null
                              : () {
                            if (!_ensureQuestLinkedOrWarn()) return;
                            _startTimer(category.name);
                          },
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
        style: const TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          fontFamily: 'monospace',
        ),
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
            onPressed: () {
              if (!_ensureQuestLinkedOrWarn()) return;
              _startTimer(_selectedCategory!);
            },
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
    required bool disabled,
    required VoidCallback? onTap,
  }) {
    final baseColor = _parseColor(category.color);
    final color = disabled ? Colors.grey : baseColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Opacity(
        opacity: disabled ? 0.45 : 1.0,
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
      ),
    );
  }

  Widget _buildAddCategoryRow({required bool isDisabled, required VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Opacity(
        opacity: isDisabled ? 0.55 : 1.0,
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

  Color _parseColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
