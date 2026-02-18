import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_colors.dart';
import '../../providers/user_data_provider.dart';
import '../../widgets/common/cards.dart';
import '../../models/models.dart';

class QuestsScreen extends StatelessWidget {
  const QuestsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<UserDataProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const LoadingIndicator(message: '로딩 중...');
            }

            final userData = provider.userData;
            if (userData == null) {
              return const EmptyState(
                message: '데이터를 불러올 수 없습니다',
                icon: Icons.error_outline,
              );
            }

            final allQuests = userData.quests.toList();

            return Column(
              children: [
                _buildHeader(context, allQuests),

                // ✅ 타이머 연동 안내 배너(문구 보강)
                _buildTimerHintBanner(context),

                Expanded(
                  child: allQuests.isEmpty
                      ? const EmptyState(
                    message: '진행 중인 퀘스트가 없습니다',
                    icon: Icons.task_alt,
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: allQuests.length,
                    itemBuilder: (context, index) {
                      return _buildQuestCard(
                        context,
                        allQuests[index],
                        provider,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, List<Quest> quests) {
    final completed = quests.where((q) => q.completed == true).length;
    final total = quests.length;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const Text(
            '퀘스트',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => _openQuestForm(context),
            icon: const Icon(Icons.add, color: AppColors.textPrimary),
            tooltip: '퀘스트 추가',
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryPastel.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$completed/$total 완료',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryPastel,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerHintBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryPastel.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primaryPastel.withValues(alpha: 0.20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Text('⏱️', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '이 퀘스트, 타이머로 집중해볼까요?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '퀘스트를 연동해야 타이머가 활성화돼요.\n각 퀘스트 오른쪽 ⏱ 버튼으로 바로 연동할 수 있어요.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => _openTimer(context),
                child: const Text('타이머 열기'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openTimer(BuildContext context) {
    try {
      Navigator.pushNamed(context, '/timer');
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('타이머 화면 라우트(/timer)가 연결되어 있지 않습니다.'),
        ),
      );
    }
  }

  // ✅ 퀘스트를 들고 타이머 화면으로 이동(=자동 연동)
  void _openTimerLinkedToQuest(BuildContext context, Quest quest) {
    try {
      Navigator.pushNamed(
        context,
        '/timer',
        arguments: {
          'questId': quest.id,
          'questTitle': quest.title,
        },
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('타이머 화면 라우트(/timer)가 연결되어 있지 않습니다.'),
        ),
      );
    }
  }

  Widget _buildQuestCard(
      BuildContext context,
      Quest quest,
      UserDataProvider provider,
      ) {
    final difficultyColor = _getDifficultyColor(quest.difficulty);

    final hasTime =
        quest.reminderTime != null && quest.reminderTime!.trim().isNotEmpty;

    final isChecked = quest.completed == true;
    final uncheckedBorderColor = Colors.grey.shade500;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: difficultyColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: difficultyColor.withValues(alpha: 0.20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Checkbox(
                value: isChecked,
                onChanged: isChecked ? null : (_) => _completeQuest(context, quest),
                fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                  final selected = states.contains(MaterialState.selected);
                  return selected ? uncheckedBorderColor : Colors.white;
                }),
                checkColor: Colors.white,
                side: BorderSide(
                  color: uncheckedBorderColor,
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        quest.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isChecked
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                          decoration:
                          isChecked ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                    if (hasTime) ...[
                      const SizedBox(width: 10),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.schedule,
                            size: 14,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            quest.reminderTime!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textTertiary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // ✅ ⏱ 타이머 연동 버튼 (완료된 퀘스트는 비활성화)
              IconButton(
                tooltip: isChecked ? '완료된 퀘스트는 연동할 수 없어요' : '이 퀘스트로 타이머 연동',
                onPressed: isChecked ? null : () => _openTimerLinkedToQuest(context, quest),
                icon: Icon(
                  Icons.timer_outlined,
                  color: isChecked ? AppColors.textTertiary : AppColors.primary,
                ),
              ),

              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'edit') {
                    _openQuestForm(context, quest: quest);
                    return;
                  }
                  if (value == 'delete') {
                    _confirmDeleteQuest(context, quest.id);
                    return;
                  }
                },
                itemBuilder: (_) {
                  final items = <PopupMenuEntry<String>>[
                    const PopupMenuItem(value: 'edit', child: Text('수정')),
                    const PopupMenuItem(value: 'delete', child: Text('삭제')),
                  ];

                  if (kDebugMode) {
                    items.add(const PopupMenuDivider());
                    items.add(const PopupMenuItem(
                      value: 'dev_big_b',
                      child: Text('DEV: 큰 퀘스트(체크리스트 5개)로 완료'),
                    ));
                    items.add(const PopupMenuItem(
                      value: 'dev_big_a',
                      child: Text('DEV: 큰 퀘스트(타이머 60분)로 완료'),
                    ));
                  }

                  return items;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return Colors.green;
      case Difficulty.normal:
        return Colors.amber;
      case Difficulty.hard:
        return Colors.red;
    }
  }

  Future<void> _completeQuest(BuildContext context, Quest quest) async {
    final provider = context.read<UserDataProvider>();
    List<Achievement> newlyUnlocked = [];

    try {
      newlyUnlocked = await provider.completeQuest(
        quest.id,
        quest.expReward,
        quest.goldReward,
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('퀘스트 완료 처리 실패: $e')),
      );
      return;
    }

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${quest.title} 완료! (+${quest.goldReward}G, +${quest.expReward}EXP)',
        ),
        backgroundColor: AppColors.statusSuccess,
        duration: const Duration(seconds: 2),
      ),
    );

    for (final a in newlyUnlocked) {
      if (!context.mounted) return;
      await _showAchievementPopup(context, icon: a.icon, title: a.title);
    }
  }

  Future<void> _showAchievementPopup(
      BuildContext context, {
        required String icon,
        required String title,
      }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('업적 달성'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 30)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              '계속 진행해보자',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _openQuestForm(BuildContext context, {Quest? quest}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _QuestFormSheet(existing: quest),
    );
  }

  void _confirmDeleteQuest(BuildContext context, String questId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('삭제하겠습니까?'),
        content: const Text('퀘스트 삭제 시 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<UserDataProvider>().deleteQuest(questId);
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}

class _QuestFormSheet extends StatefulWidget {
  final Quest? existing;
  const _QuestFormSheet({this.existing});

  @override
  State<_QuestFormSheet> createState() => _QuestFormSheetState();
}

class _QuestFormSheetState extends State<_QuestFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _title;

  Difficulty _difficulty = Difficulty.normal;
  TimeOfDay? _time;

  @override
  void initState() {
    super.initState();
    final q = widget.existing;

    _title = TextEditingController(text: q?.title ?? '');
    _difficulty = q?.difficulty ?? Difficulty.normal;

    final rt = q?.reminderTime;
    if (rt != null && rt.contains(':')) {
      final parts = rt.split(':');
      final h = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      if (h != null && m != null) {
        _time = TimeOfDay(hour: h, minute: m);
      }
    }
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  isEdit ? '퀘스트 수정' : '퀘스트 추가',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: '제목'),
              validator: (v) =>
              (v == null || v.trim().isEmpty) ? '제목을 입력해줘' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Difficulty>(
              value: _difficulty,
              decoration: const InputDecoration(labelText: '난이도'),
              items: Difficulty.values
                  .map(
                    (d) => DropdownMenuItem(
                  value: d,
                  child: Text(d.displayName),
                ),
              )
                  .toList(),
              onChanged: (v) =>
                  setState(() => _difficulty = v ?? Difficulty.normal),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.schedule),
                    label: Text(
                      _time == null ? '시간 선택(선택)' : _time!.format(context),
                    ),
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: _time ?? TimeOfDay.now(),
                      );
                      if (picked != null) setState(() => _time = picked);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                if (_time != null)
                  IconButton(
                    tooltip: '시간 제거',
                    onPressed: () => setState(() => _time = null),
                    icon: const Icon(Icons.clear),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  final provider = context.read<UserDataProvider>();
                  final title = _title.text.trim();

                  String? reminderTime;
                  if (_time != null) {
                    final hh = _time!.hour.toString().padLeft(2, '0');
                    final mm = _time!.minute.toString().padLeft(2, '0');
                    reminderTime = '$hh:$mm';
                  }

                  if (isEdit) {
                    await provider.updateQuest(
                      questId: widget.existing!.id,
                      title: title,
                      difficulty: _difficulty,
                      reminderTime: reminderTime,
                    );
                  } else {
                    await provider.addQuest(
                      title: title,
                      difficulty: _difficulty,
                      reminderTime: reminderTime,
                    );
                  }

                  if (!mounted) return;
                  Navigator.pop(context);
                },
                child: Text(isEdit ? '수정 완료' : '추가'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
