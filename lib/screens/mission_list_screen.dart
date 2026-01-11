import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user_data.dart';
import '../models/quest.dart';
import '../models/daily_record.dart';
import '../services/storage_service.dart';

class MissionListScreen extends StatefulWidget {
  final UserData userData;

  const MissionListScreen({super.key, required this.userData});

  @override
  State<MissionListScreen> createState() => _MissionListScreenState();
}

class _MissionListScreenState extends State<MissionListScreen> {
  late UserData _userData;
  List<Quest> _quests = [];
  String? _successQuestId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _userData = widget.userData;
    _loadQuests();
  }

  Future<void> _loadQuests() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final savedQuests = await StorageService.getDailyQuests(today);

    setState(() {
      if (savedQuests != null) {
        _quests = savedQuests;
      } else {
        _quests = StorageService.generateRandomQuests();
        StorageService.saveDailyQuests(_quests, today);
      }
      _isLoading = false;
    });
  }

  Future<void> _completeQuest(String questId) async {
    final quest = _quests.firstWhere((q) => q.id == questId);
    if (quest.completed) return;

    setState(() {
      _quests = _quests
          .map((q) => q.id == questId ? q.copyWith(completed: true) : q)
          .toList();
      _successQuestId = questId;
    });

    // Save quests
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await StorageService.saveDailyQuests(_quests, today);

    // Update user data
    final newExp = _userData.exp + quest.exp;
    final expNeeded = _userData.level * 100;

    int newLevel = _userData.level;
    int finalExp = newExp;

    if (newExp >= expNeeded) {
      newLevel += 1;
      finalExp = newExp - expNeeded;
    }

    final updatedUser = _userData.copyWith(
      exp: finalExp,
      level: newLevel,
      gold: _userData.gold + 10,
    );

    setState(() {
      _userData = updatedUser;
    });

    await StorageService.saveUserData(updatedUser);

    // Update history
    final completedCount = _quests.where((q) => q.completed).length;
    final history = await StorageService.getHistory();
    final existingIndex = history.indexWhere((r) => r.date == today);

    final record = DailyRecord(
      date: today,
      quests: _quests,
      completedCount: completedCount,
      totalCount: _quests.length,
    );

    if (existingIndex >= 0) {
      history[existingIndex] = record;
    } else {
      history.add(record);
    }

    await StorageService.saveHistory(history);

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _successQuestId = null;
        });
      }
    });
  }

  Future<void> _refreshQuests() async {
    if (_userData.gold < 50) return;

    final newQuests = StorageService.generateRandomQuests();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    setState(() {
      _quests = newQuests;
      _userData = _userData.copyWith(gold: _userData.gold - 50);
    });

    await StorageService.saveDailyQuests(_quests, today);
    await StorageService.saveUserData(_userData);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final completedCount = _quests.where((q) => q.completed).length;
    final totalCount = _quests.length;
    final allCompleted = completedCount == totalCount && totalCount > 0;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF60A5FA), Color(0xFF2563EB)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context, _userData),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '오늘의 미션',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '완료: $completedCount / $totalCount',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Progress
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '전체 진행도',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          Text(
                            '${totalCount > 0 ? ((completedCount / totalCount) * 100).round() : 0}%',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: totalCount > 0 ? completedCount / totalCount : 0,
                          minHeight: 16,
                          backgroundColor: const Color(0xFFE5E7EB),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF3B82F6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Quests
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _quests.length,
                  itemBuilder: (context, index) {
                    final quest = _quests[index];
                    final isSuccess = _successQuestId == quest.id;
                    return _buildQuestCard(quest, isSuccess);
                  },
                ),
              ),

              // Refresh Button
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _userData.gold >= 50 ? _refreshQuests : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF3B82F6),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.refresh),
                            const SizedBox(width: 8),
                            Text(
                              _userData.gold >= 50
                                  ? '미션 새로고침 (50 G)'
                                  : '골드 부족 (50 G 필요)',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (allCompleted) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF34D399), Color(0xFF3B82F6)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
                          children: [
                            Text('🎉', style: TextStyle(fontSize: 48)),
                            SizedBox(height: 12),
                            Text(
                              '오늘의 미션 완료!',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '정말 잘하셨어요! 내일도 화이팅!',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestCard(Quest quest, bool isSuccess) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => !quest.completed ? _completeQuest(quest.id) : null,
                child: Icon(
                  quest.completed ? Icons.check_circle : Icons.circle_outlined,
                  color: quest.completed
                      ? const Color(0xFF10B981)
                      : const Color(0xFFD1D5DB),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quest.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: quest.completed
                            ? const Color(0xFF6B7280)
                            : const Color(0xFF1F2937),
                        decoration: quest.completed
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          color: Color(0xFFF59E0B),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '+${quest.exp} EXP',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '+10 G',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isSuccess) ...[
            const SizedBox(height: 12),
            const Text(
              '성공! 🎉',
              style: TextStyle(
                color: Color(0xFF10B981),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}