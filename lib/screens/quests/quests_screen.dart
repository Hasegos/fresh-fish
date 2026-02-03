import 'package:flutter/material.dart'; // UI 기본 위젯
import 'package:provider/provider.dart'; // 상태관리 접근

// 앱 공통 색/텍스트 스타일
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

import '../../providers/user_data_provider.dart'; // 퀘스트/습관 데이터와 CRUD 로직을 가진 Provider
import '../../widgets/common/cards.dart'; // 공통 카드/상태 UI 위젯
import '../../widgets/common/dialogs.dart'; // CommonDialogs.showInputDialog,
// showChoiceDialog, showConfirmDialog, showBottomSheet 제공
import '../../models/models.dart'; // UserData, Quest, Habit, Difficulty,
// Category, QuestsType 등 모델/enum.

//  ✅ QuestsScreen 위젯
// 퀘스트/습관 목록 화면
// StatelessWidth : 내부 상태 없이 Provider 상태 변화로만 리빌드
class QuestsScreen extends StatelessWidget {
  const QuestsScreen({Key? key}) : super(key: key);

  // 💡 화면 전체 구성
  @override
  Widget build(BuildContext context) {
    return Scaffold( // 화면 골격(배경, body)
      backgroundColor: AppColors.background,
      body: SafeArea( // 노치/상단바 영역 피해서 UI 배치
        child: Consumer<UserDataProvider>( // Provider 값이 바뀌면 builder 재실행 -> UI 갱신
          builder: (context, provider, child) { // builder로 provider를 받아서 데이터 기반 렌더링
            if (provider.isLoading) { // 로딩 중이라면 리스트 대신 로딩 위젯 표시
              return const LoadingIndicator(message: '로딩 중...');
            }

            // userData null 처리
            // 데이터가 아직 없거나 로드 실패 등으로 null이라면 에러 상태 UI
            final userData = provider.userData;
            if (userData == null) {
              return const EmptyState(
                message: '사용자 데이터를 불러올 수 없습니다',
                icon: Icons.error_outline,
              );
            }

            // 실제 데이터 추출 및 카테고리 목록 준비
            // toList()로 새 리스트 생성
            final quests = userData.quests.toList();
            final habits = userData.habits.toList();

            // categories : 선택된 카테고리가 있으면 그걸,
            // 없으면 전체 카테고리 사용
            final categories = _availableCategories(userData);

            // 메인 UI 레이아웃(Header + List)
            return Column( // 위에 헤더, 아래에 리스트
              children: [
                _buildHeader( // 상단 타이틀 + 추가 버튼 + 완료/전체 카운트
                  context,
                  quests,
                      () => _addQuest(context, provider, categories),
                ),
                Expanded( // 리스트가 남은 영역 전부 채우도록
                  child: ListView( // 스크롤 가능한 목록
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (quests.isEmpty)
                        _buildEmptyText('등록된 퀘스트가 없습니다')
                      else
                        ...quests.map(
                              (q) => _buildQuestCard(context, q, provider),
                        ),
                      const SizedBox(height: 16),
                      _buildSectionHeader(
                        '습관',
                            () => _openHabitForm(
                          context,
                          provider,
                          categories,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (habits.isEmpty)
                        _buildEmptyText('등록된 습관이 없습니다')
                      else
                        ...habits.map(
                              (h) => _buildHabitCard(
                            context,
                            h,
                            provider,
                            categories,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<String> _availableCategories(UserData userData) {
    // 카테고리 선택값 우선
    // 없으면 전체 카테고리 이름 목록
    if (userData.selectedCategories.isNotEmpty) {
      return userData.selectedCategories;
    }
    return Category.values.map((e) => e.displayName).toList();
  }

  Widget _buildHeader(
      BuildContext context,
      List<Quest> quests,
      VoidCallback onAddQuest,
      ) {
    final completed = quests.where((q) => q.completed).length;

    return Padding(
      padding: const EdgeInsets.all(16),
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
            onPressed: onAddQuest,
            icon: const Icon(Icons.add_circle_outline),
            color: AppColors.primaryPastel,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryPastel.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$completed/${quests.length} 완료',
              style: const TextStyle(
                color: AppColors.primaryPastel,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onAdd) {
    return Row(
      children: [
        Text(title, style: AppTextStyles.h4),
        const Spacer(),
        IconButton(
          onPressed: onAdd,
          icon: const Icon(Icons.add_circle_outline),
          color: AppColors.primaryPastel,
        ),
      ],
    );
  }

  Widget _buildEmptyText(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        message,
        style: AppTextStyles.bodySmall,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildQuestCard(
      BuildContext context,
      Quest quest,
      UserDataProvider provider,
      ) {
    final color = _difficultyColor(quest.difficulty);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: quest.completed
              ? AppColors.statusSuccess.withOpacity(0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: quest.completed
                ? AppColors.statusSuccess.withOpacity(0.2)
                : AppColors.borderLight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  Checkbox(
                    value: quest.completed,
                    onChanged: quest.completed
                        ? null
                        : (_) => _completeQuest(context, quest, provider),
                  ),
                  Expanded(
                    child: Text(
                      quest.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        decoration:
                        quest.completed ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'edit') {
                        await _editQuest(context, provider, quest);
                      } else {
                        await _deleteQuest(context, provider, quest);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('수정')),
                      PopupMenuItem(value: 'delete', child: Text('삭제')),
                    ],
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(left: 48),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    quest.difficulty.displayName,
                    style: TextStyle(color: color),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHabitCard(
      BuildContext context,
      Habit habit,
      UserDataProvider provider,
      List<String> categories,
      ) {
    final color = _difficultyColor(habit.difficulty);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => provider.completeHabit(habit.id),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.title,
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(habit.category, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${habit.completionCount}회'),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(habit.difficulty.displayName),
                  ),
                ],
              ),
              PopupMenuButton<String>(
                onSelected: (v) async {
                  if (v == 'edit') {
                    await _openHabitForm(
                      context,
                      provider,
                      categories,
                      habit: habit,
                    );
                  } else {
                    await _deleteHabit(context, provider, habit);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('수정')),
                  PopupMenuItem(value: 'delete', child: Text('삭제')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _difficultyColor(Difficulty d) {
    switch (d) {
      case Difficulty.easy:
        return AppColors.statusSuccess;
      case Difficulty.normal:
        return AppColors.primaryPastel;
      case Difficulty.hard:
        return AppColors.highlightPink;
    }
  }

  Future<void> _completeQuest(
      BuildContext context,
      Quest quest,
      UserDataProvider provider,
      ) async {
    await provider.completeQuestById(quest.id);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${quest.title} 완료!')),
    );
  }

  /// ✅ 수정: rootNavigator context 저장/재사용 제거 + await 후 mounted 체크
  Future<void> _addQuest(
      BuildContext context,
      UserDataProvider provider,
      List<String> categories,
      ) async {
    if (!context.mounted) return;
    final rootContext = Navigator.of(context, rootNavigator: true).context;
    final title = await CommonDialogs.showInputDialog(
      context,
      title: '퀘스트 추가',
      hint: '퀘스트 이름',
      confirmText: '추가',
    );

    if (!context.mounted) return;
    if (title == null || title.trim().isEmpty) return;

    final category = await CommonDialogs.showChoiceDialog<String>(
      context,
      title: '카테고리 선택',
      choices: categories.map((c) => ChoiceItem(label: c, value: c)).toList(),
    );

    if (!context.mounted) return;
    if (category == null) return;

    final difficulty = await CommonDialogs.showChoiceDialog<Difficulty>(
      context,
      title: '난이도 선택',
      choices: Difficulty.values
          .map((d) => ChoiceItem(label: d.displayName, value: d))
          .toList(),
    );

    if (!context.mounted) return;
    if (difficulty == null) return;

    await provider.createQuest(
      title: title.trim(),
      category: category,
      difficulty: difficulty,
      questType: QuestType.sub,
    );
  }

  Future<void> _editQuest(
      BuildContext context,
      UserDataProvider provider,
      Quest quest,
      ) async {
    if (!context.mounted) return;
    final rootContext = Navigator.of(context, rootNavigator: true).context;
    final title = await CommonDialogs.showInputDialog(
      rootContext,
      title: '퀘스트 수정',
      initialValue: quest.title,
      confirmText: '저장',
    );

    if (!context.mounted) return;
    if (title == null || title.trim().isEmpty) return;

    await provider.updateQuest(quest.copyWith(title: title.trim()));
  }

  Future<void> _deleteQuest(
      BuildContext context,
      UserDataProvider provider,
      Quest quest,
      ) async {
    if (!context.mounted) return;
    final rootContext = Navigator.of(context, rootNavigator: true).context;
    final ok = await CommonDialogs.showConfirmDialog(
      rootContext,
      title: '퀘스트 삭제',
      message: '"${quest.title}"을 삭제할까요?',
      isDangerous: true,
    );

    if (!context.mounted || !ok) return;
    await provider.deleteQuest(quest.id);
  }

  Future<void> _openHabitForm(
      BuildContext context,
      UserDataProvider provider,
      List<String> categories, {
        Habit? habit,
      }) async {
    if (!context.mounted) return;
    final rootContext = Navigator.of(context, rootNavigator: true).context;
    final result = await CommonDialogs.showBottomSheet<HabitFormResult>(
      context,
      child: HabitFormSheet(
        habit: habit,
        categories: categories,
      ),
    );

    if (!context.mounted || result == null) return;

    if (habit == null) {
      await provider.createHabit(
        title: result.title,
        category: result.category,
        difficulty: result.difficulty,
      );
    } else {
      await provider.updateHabit(
        habit.copyWith(
          title: result.title,
          category: result.category,
          difficulty: result.difficulty,
        ),
      );
    }
  }

  Future<void> _deleteHabit(
      BuildContext context,
      UserDataProvider provider,
      Habit habit,
      ) async {
    if (!context.mounted) return;
    final rootContext = Navigator.of(context, rootNavigator: true).context;
    final ok = await CommonDialogs.showConfirmDialog(
      rootContext,
      title: '습관 삭제',
      message: '"${habit.title}"을 삭제할까요?',
      isDangerous: true,
    );

    if (!context.mounted || !ok) return;
    await provider.deleteHabit(habit.id);
  }
}

class HabitFormResult {
  final String title;
  final String category;
  final Difficulty difficulty;

  HabitFormResult({
    required this.title,
    required this.category,
    required this.difficulty,
  });
}

class HabitFormSheet extends StatefulWidget {
  final Habit? habit;
  final List<String> categories;

  const HabitFormSheet({
    super.key,
    this.habit,
    required this.categories,
  });

  @override
  State<HabitFormSheet> createState() => _HabitFormSheetState();
}

class _HabitFormSheetState extends State<HabitFormSheet> {
  late final TextEditingController _titleController;
  late String _category;
  late Difficulty _difficulty;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.habit?.title ?? '');
    _category = widget.habit?.category ?? widget.categories.first;
    _difficulty = widget.habit?.difficulty ?? Difficulty.normal;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.habit != null;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isEdit ? '습관 수정' : '습관 추가', style: AppTextStyles.h3),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: '습관 이름',
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _category,
              items: widget.categories
                  .map(
                    (c) => DropdownMenuItem(
                  value: c,
                  child: Text(c),
                ),
              )
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Difficulty>(
              value: _difficulty,
              items: Difficulty.values
                  .map(
                    (d) => DropdownMenuItem(
                  value: d,
                  child: Text(d.displayName),
                ),
              )
                  .toList(),
              onChanged: (v) => setState(() => _difficulty = v!),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('취소'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final title = _titleController.text.trim();
                      if (title.isEmpty) return;
                      Navigator.of(context).pop(
                        HabitFormResult(
                          title: title,
                          category: _category,
                          difficulty: _difficulty,
                        ),
                      );
                    },
                    child: Text(isEdit ? '저장' : '추가'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
