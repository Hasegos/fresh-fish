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

  // ✅ 헤더 (+ 추가 버튼 포함)
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
              color: AppColors.primaryPastel.withOpacity(0.12),
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

  // ✅ 카드 (완료 + 수정/삭제 메뉴 + 시간 표시)
  Widget _buildQuestCard(
      BuildContext context,
      Quest quest,
      UserDataProvider provider,
      ) {
    final difficultyColor = _getDifficultyColor(quest.difficulty);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: quest.completed == true
              ? AppColors.statusSuccess.withOpacity(0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: quest.completed == true
                ? AppColors.statusSuccess.withOpacity(0.2)
                : AppColors.borderLight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: quest.completed == true,
                    onChanged: (quest.completed == true)
                        ? null
                        : (_) => _completeQuest(context, quest, provider),
                    activeColor: AppColors.statusSuccess,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quest.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: quest.completed == true
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                            decoration: quest.completed == true
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        if (quest.reminderTime != null &&
                            quest.reminderTime!.trim().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.schedule,
                                    size: 14, color: AppColors.textTertiary),
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
                          ),
                      ],
                    ),
                  ),

                  // ✅ 수정/삭제 메뉴
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _openQuestForm(context, quest: quest);
                      } else if (value == 'delete') {
                        _confirmDeleteQuest(context, quest.id);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('수정')),
                      PopupMenuItem(value: 'delete', child: Text('삭제')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 48.0),
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: difficultyColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    quest.difficulty.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: difficultyColor,
                    ),
                  ),
                ),
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
        return AppColors.statusSuccess;
      case Difficulty.normal:
        return AppColors.primaryPastel;
      case Difficulty.hard:
        return AppColors.highlightPink;
    }
  }

  // ✅ 완료 처리(기존 로직 그대로 + 업적 팝업)
  Future<void> _completeQuest(
      BuildContext context,
      Quest quest,
      UserDataProvider provider,
      ) async {
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
      _showAchievementPopup(context, icon: a.icon, title: a.title);
    }
  }

  void _showAchievementPopup(
      BuildContext context, {
        required String icon,
        required String title,
      }) {
    showDialog(
      context: context,
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

  // ==========================
  // ✅ 추가/수정/삭제 UI 연결
  // ==========================

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
  late final TextEditingController _exp;
  late final TextEditingController _gold;

  Difficulty _difficulty = Difficulty.normal;
  TimeOfDay? _time;

  @override
  void initState() {
    super.initState();
    final q = widget.existing;

    _title = TextEditingController(text: q?.title ?? '');
    _exp = TextEditingController(text: (q?.expReward ?? 10).toString());
    _gold = TextEditingController(text: (q?.goldReward ?? 0).toString());
    _difficulty = q?.difficulty ?? Difficulty.normal;

    // ✅ 기존 시간(HH:mm) 파싱
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
    _exp.dispose();
    _gold.dispose();
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
                  .map((d) =>
                  DropdownMenuItem(value: d, child: Text(d.displayName)))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _difficulty = v ?? Difficulty.normal),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _exp,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'EXP 보상'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _gold,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Gold 보상'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ✅ 시간 선택
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
                  final exp = int.tryParse(_exp.text) ?? 10;
                  final gold = int.tryParse(_gold.text) ?? 0;

                  // ✅ HH:mm 저장
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
                      expReward: exp,
                      goldReward: gold,
                      reminderTime: reminderTime,
                    );
                  } else {
                    await provider.addQuest(
                      title: title,
                      difficulty: _difficulty,
                      expReward: exp,
                      goldReward: gold,
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
