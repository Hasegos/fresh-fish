import 'package:flutter/foundation.dart';
import '../models/models.dart' as m;
import '../services/storage_service.dart';

/// ✅ Achievement Seed (마스터 업적 정의)
class _AchievementSeed {
  final String title;
  final String icon;
  const _AchievementSeed(this.title, this.icon);
}

class UserDataProvider extends ChangeNotifier {
  m.UserData? _userData;
  bool _isLoading = true;

  final StorageService _storageService = StorageService();

  m.UserData? get userData => _userData;
  bool get isLoading => _isLoading;
  bool get isOnboardingComplete => _userData?.onboardingCompleted ?? false;

  // =============================
  // 초기화 / 로드 / 저장
  // =============================

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    debugPrint('[UserDataProvider] initialize: start loading');
    try {
      _userData = await _storageService.getUserData().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          debugPrint('[UserDataProvider] storage load timeout');
          return null;
        },
      );
      debugPrint('[UserDataProvider] initialize: loaded = ${_userData != null}');

      // ✅ 업적 씨드 보장
      if (_userData != null) {
        await _ensureAchievementSeeds();
      }
    } catch (e) {
      debugPrint('[UserDataProvider] initialize error: $e');
      _userData = null;
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('[UserDataProvider] initialize: done');
    }
  }

  Future<void> refreshUserData() async {
    try {
      _userData = await _storageService.getUserData();

      // ✅ refresh에서도 씨드 보장
      if (_userData != null) {
        await _ensureAchievementSeeds();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('[UserDataProvider] refresh error: $e');
    }
  }

  Future<void> saveUserData(m.UserData data) async {
    _userData = data;
    notifyListeners();
    await _storageService.saveUserData(data);
  }

  Future<void> updateUserData(m.UserData Function(m.UserData) updater) async {
    if (_userData == null) return;

    _userData = updater(_userData!);
    notifyListeners();
    await _storageService.saveUserData(_userData!);
  }

  Future<void> updateFish(m.Fish fish) async {
    if (_userData == null) return;
    await updateUserData((data) => data.copyWith(fish: fish));
  }

  Future<void> updateGold(int gold) async {
    if (_userData == null) return;
    await updateUserData((data) => data.copyWith(gold: gold));
  }

  Future<void> addGold(int amount) async {
    if (_userData == null) return;
    await updateGold(_userData!.gold + amount);
  }

  // =============================
  // ✅ 큰 퀘스트 판정(정책 반영)
  // =============================
  //
  // Condition A: (timer ≥ 60) AND (difficulty ≥ '보통')
  // Condition B: (오늘 완료한 퀘스트 수 ≥ 5)  ✅ (요청사항 반영)

  bool _isBigQuestByPolicy({
    required int timerMinutes,
    required m.Difficulty difficulty,
    required int completedTodayCount,
  }) {
    final conditionA =
        (timerMinutes >= 60) && (difficulty.index >= m.Difficulty.normal.index);

    final conditionB = (completedTodayCount >= 5);

    return conditionA || conditionB;
  }

  int _countCompletedTodayFrom(List<m.Quest> quests, int todayStart, int tomorrowStart) {
    int cnt = 0;
    for (final q in quests) {
      if (q.completed != true) continue;
      final at = q.completedAt;
      if (at == null) continue;
      if (at >= todayStart && at < tomorrowStart) cnt++;
    }
    return cnt;
  }

  int _countBigQuestClearsFrom(List<m.Quest> quests) {
    // ✅ 스냅샷이 있으면 스냅샷 기준
    // ✅ 스냅샷이 없는 구버전 데이터는 "레거시(타이머/체크리스트)"로만 보수적으로 계산
    //    (오늘 5개 완료 정책은 과거 데이터에서 재구성 불가)
    int cnt = 0;
    for (final q in quests) {
      if (q.completed != true) continue;

      final snap = q.isBigQuest;
      if (snap == true) {
        cnt++;
        continue;
      }
      if (snap == false) continue;

      // 레거시 fallback (구버전: 타이머+난이도 OR checklist>=5)
      final timer = q.durationMinutes ?? 0;
      final checklist = q.checklistCompletedCount ?? 0;
      final legacyBig =
          (timer >= 60 && q.difficulty.index >= m.Difficulty.normal.index) ||
              (checklist >= 5);

      if (legacyBig) cnt++;
    }
    return cnt;
  }

  // =============================
  // ✅ Quest CRUD (추가/수정/삭제) + 시간(reminderTime)
  // =============================

  Future<void> addQuest({
    required String title,
    required m.Difficulty difficulty,
    int expReward = 10,
    int goldReward = 0,
    String? reminderTime,
    String? category,
    m.QuestType? questType,
  }) async {
    if (_userData == null) return;

    final nowMs = DateTime.now().millisecondsSinceEpoch;

    final newQuest = m.Quest(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      category: category ?? '공부',
      completed: false,
      date: _userData!.currentDate,
      reminderTime: reminderTime,
      expReward: expReward,
      goldReward: goldReward,
      questType: questType ?? m.QuestType.daily,
      difficulty: difficulty,

      // ✅ 업적/통계용
      createdAt: nowMs,
      completedAt: null,
      deadlineAt: null,
      durationMinutes: null,

      // ✅ 큰 퀘스트 관련(초기값 null)
      checklistCompletedCount: null,
      finalTimerMinutes: null,
      finalChecklistCompletedCount: null,
      isBigQuest: null,
    );

    await updateUserData((data) {
      return data.copyWith(
        quests: [...data.quests, newQuest],
      );
    });

    await _ensureAchievementSeeds();
    await _unlockSeed('첫 퀘스트 만들기 (퀘스트 1개 생성)');
  }

  Future<void> updateQuest({
    required String questId,
    required String title,
    required m.Difficulty difficulty,
    int? expReward,
    int? goldReward,
    String? reminderTime,
  }) async {
    if (_userData == null) return;

    await updateUserData((data) {
      final updated = data.quests.map((q) {
        if (q.id != questId) return q;

        return q.copyWith(
          title: title,
          difficulty: difficulty,
          expReward: expReward ?? q.expReward,
          goldReward: goldReward ?? q.goldReward,
          reminderTime: reminderTime,
        );
      }).toList();

      return data.copyWith(quests: updated);
    });

    await _ensureAchievementSeeds();
    await _unlockSeed('첫 수정 (퀘스트 수정 1회)');
  }

  Future<void> deleteQuest(String questId) async {
    if (_userData == null) return;

    await updateUserData((data) {
      return data.copyWith(
        quests: data.quests.where((q) => q.id != questId).toList(),
      );
    });
  }

  // =============================
  // ✅ (선택) 타이머/체크리스트 카운트 업데이트용 메서드
  // =============================

  Future<void> addQuestDurationMinutes({
    required String questId,
    required int addMinutes,
  }) async {
    if (_userData == null) return;
    if (addMinutes <= 0) return;

    await updateUserData((data) {
      final updated = data.quests.map((q) {
        if (q.id != questId) return q;
        if (q.completed == true) return q; // 완료 후 변경 방지(스냅샷 보존)
        final cur = q.durationMinutes ?? 0;
        return q.copyWith(durationMinutes: cur + addMinutes);
      }).toList();
      return data.copyWith(quests: updated);
    });
  }

  Future<void> setQuestChecklistCompletedCount({
    required String questId,
    required int completedCount,
  }) async {
    if (_userData == null) return;
    if (completedCount < 0) return;

    await updateUserData((data) {
      final updated = data.quests.map((q) {
        if (q.id != questId) return q;
        if (q.completed == true) return q; // 완료 후 변경 방지
        return q.copyWith(checklistCompletedCount: completedCount);
      }).toList();
      return data.copyWith(quests: updated);
    });
  }

  // =============================
  // ✅ 퀘스트 완료 + 업적 연동(팝업용 반환)
  // =============================

  Future<List<m.Achievement>> completeQuest(
      String questId,
      int expGain,
      int goldGain,
      ) async {
    if (_userData == null) return [];

    final beforeCompleted =
        _userData!.quests.where((q) => q.completed == true).length;

    final now = DateTime.now().millisecondsSinceEpoch;

    // ✅ 이미 완료된 퀘스트면 아무 것도 안 함(중복 누적 방지)
    final target = _userData!.quests.firstWhere(
          (q) => q.id == questId,
      orElse: () => throw Exception('Quest not found: $questId'),
    );
    if (target.completed == true) return [];

    // ✅ "오늘 완료 개수" 계산 (완료 직후 기준으로 bigQuest 판정에 사용)
    final nowDt = DateTime.now();
    final todayStart = DateTime(nowDt.year, nowDt.month, nowDt.day).millisecondsSinceEpoch;
    final tomorrowStart = DateTime(nowDt.year, nowDt.month, nowDt.day + 1).millisecondsSinceEpoch;

    final completedTodayBefore = _countCompletedTodayFrom(_userData!.quests, todayStart, tomorrowStart);
    final completedTodayAfter = completedTodayBefore + 1; // 지금 이 퀘스트가 완료될 예정이므로 +1

    // ✅ 완료 스냅샷 계산
    final finalTimerMinutes = target.durationMinutes ?? 0;
    final finalChecklistCompletedCount = target.checklistCompletedCount ?? 0;

    // ✅ 큰 퀘스트 판정(정책 반영)
    final bigQuest = _isBigQuestByPolicy(
      timerMinutes: finalTimerMinutes,
      difficulty: target.difficulty,
      completedTodayCount: completedTodayAfter, // ✅ Condition B: 오늘 완료 5개 이상
    );

    final updatedQuests = _userData!.quests.map((q) {
      if (q.id == questId) {
        return q.copyWith(
          completed: true,
          completedAt: now,

          // ✅ 스냅샷 저장
          finalTimerMinutes: finalTimerMinutes,
          finalChecklistCompletedCount: finalChecklistCompletedCount,
          isBigQuest: bigQuest,
        );
      }
      return q;
    }).toList();

    // exp/gold 반영
    final updatedFish = _userData!.fish.copyWith(
      exp: _userData!.fish.exp + expGain,
    );

    await updateUserData((data) => data.copyWith(
      quests: updatedQuests,
      gold: data.gold + goldGain,
      fish: updatedFish,
    ));

    final afterCompleted =
        _userData!.quests.where((q) => q.completed == true).length;

    if (afterCompleted <= beforeCompleted) return [];

    await _ensureAchievementSeeds();

    final instantUnlocked = <m.Achievement>[];

    final a1 = await _unlockSeed('첫 클리어 (퀘스트 1개 완료)');
    if (a1 != null) instantUnlocked.add(a1);

    if (expGain > 0 || goldGain > 0) {
      final a2 = await _unlockSeed('첫 보상 수령 (보상/코인/경험치 첫 획득)');
      if (a2 != null) instantUnlocked.add(a2);
    }

    // ✅ 큰 퀘스트 업적: 1/10/50/100 (스냅샷 누적 기준)
    final bigQuestClears = _countBigQuestClearsFrom(updatedQuests);
    if (bigQuestClears >= 1) {
      final a = await _unlockSeed('큰 퀘스트 클리어 1회');
      if (a != null) instantUnlocked.add(a);
    }
    if (bigQuestClears >= 10) {
      final a = await _unlockSeed('큰 퀘스트 클리어 10회');
      if (a != null) instantUnlocked.add(a);
    }
    if (bigQuestClears >= 50) {
      final a = await _unlockSeed('큰 퀘스트 클리어 50회');
      if (a != null) instantUnlocked.add(a);
    }
    if (bigQuestClears >= 100) {
      final a = await _unlockSeed('큰 퀘스트 클리어 100회');
      if (a != null) instantUnlocked.add(a);
    }

    // ✅ 전체 조건 기반 추가 업적
    final newlyUnlocked = await checkAndUnlockAchievements();

    final merged = <String, m.Achievement>{};
    for (final a in [...instantUnlocked, ...newlyUnlocked]) {
      merged[a.title] = a;
    }
    return merged.values.toList();
  }

  Future<List<m.Achievement>> completeQuestById(String questId) async {
    if (_userData == null) return [];

    final quest = _userData!.quests.firstWhere(
          (q) => q.id == questId,
      orElse: () => throw Exception('Quest not found: $questId'),
    );

    return completeQuest(questId, quest.expReward, quest.goldReward);
  }

  // =============================
  // ✅ 업적(Unlock) 로직
  // =============================

  Future<m.Achievement?> unlockAchievement({
    required String title,
    required String icon,
    String description = '',
  }) async {
    if (_userData == null) return null;

    final achievements = List<m.Achievement>.from(_userData!.achievements);
    final idx = achievements.indexWhere((a) => a.title == title);

    if (idx != -1) {
      final current = achievements[idx];
      if (current.unlocked == true) return null;

      final updated = m.Achievement(
        id: current.id,
        title: current.title,
        description: (description.trim().isNotEmpty)
            ? description
            : current.description,
        icon: current.icon.isNotEmpty ? current.icon : icon,
        unlocked: true,
      );

      achievements[idx] = updated;
      await updateUserData((data) => data.copyWith(achievements: achievements));
      return updated;
    }

    final created = m.Achievement(
      id: title,
      title: title,
      description: description,
      icon: icon,
      unlocked: true,
    );

    achievements.add(created);
    await updateUserData((data) => data.copyWith(achievements: achievements));
    return created;
  }

  // =============================
  // ✅ 업적 씨드 관리
  // =============================

  List<_AchievementSeed> _achievementOrder() {
    return const <_AchievementSeed>[
      _AchievementSeed('첫 퀘스트 만들기 (퀘스트 1개 생성)', '📝'),
      _AchievementSeed('첫 클리어 (퀘스트 1개 완료)', '✅'),
      _AchievementSeed('첫 보상 수령 (보상/코인/경험치 첫 획득)', '💰'),
      _AchievementSeed('첫 수정 (퀘스트 수정 1회)', '✏️'),
      _AchievementSeed('연속 완료 3일', '🔥'),
      _AchievementSeed('연속 완료 7일', '🔥'),
      _AchievementSeed('스트릭 복구자 (끊긴 뒤 다시 3일 연속)', '🩹'),
      _AchievementSeed('10개 완료', '🔟'),
      _AchievementSeed('25개 완료', '🏅'),
      _AchievementSeed('50개 완료', '🥈'),
      _AchievementSeed('100개 완료', '🥇'),
      _AchievementSeed('하루 3개 완료', '📅'),
      _AchievementSeed('하루 5개 완료', '📆'),
      _AchievementSeed('주간 20개 완료', '🗓️'),
      _AchievementSeed('월간 100개 완료', '🗓️'),
      _AchievementSeed('서로 다른 카테고리 3개에서 각 1개 완료', '🧩'),
      _AchievementSeed('서로 다른 카테고리 5개에서 각 1개 완료', '🧠'),
      _AchievementSeed('공부 퀘스트 10개 완료', '📚'),
      _AchievementSeed('운동 퀘스트 10개 완료', '🏋️'),
      _AchievementSeed('청소/정리 퀘스트 10개 완료', '🧹'),
      _AchievementSeed('자기관리 퀘스트 20개 완료', '🧴'),
      _AchievementSeed('쉬움 퀘스트 30개 완료', '🙂'),
      _AchievementSeed('어려움 퀘스트 10개 완료', '😤'),

      // ✅ 큰 퀘스트 업적(정책 반영: 60분+보통 OR 오늘 5개 완료)
      _AchievementSeed('큰 퀘스트 클리어 1회', '🏁'),
      _AchievementSeed('큰 퀘스트 클리어 10회', '🔥'),
      _AchievementSeed('큰 퀘스트 클리어 50회', '⚔️'),
      _AchievementSeed('큰 퀘스트 클리어 100회', '👑'),

      _AchievementSeed('마감 전 완료 10회 (데드라인 있으면)', '⏰'),
      _AchievementSeed('아침형 인간 (06~09시 완료 10회)', '🌅'),
      _AchievementSeed('야행성 (23시 이후 완료 10회)', '🌙'),
      _AchievementSeed('주말에도 한다 (토/일 완료 20회)', '🎌'),
      _AchievementSeed('정리왕 (완료/아카이브 정리 20회)', '🗂️'),
      _AchievementSeed('완벽한 한 주 (주간 목표 100% 달성 1회)', '💯'),
    ];
  }

  _AchievementSeed? _seedByTitle(String title) {
    for (final s in _achievementOrder()) {
      if (s.title == title) return s;
    }
    return null;
  }

  Future<void> _ensureAchievementSeeds() async {
    if (_userData == null) return;

    final seeds = _achievementOrder();
    final current = List<m.Achievement>.from(_userData!.achievements);
    final existingTitles = current.map((a) => a.title).toSet();

    final toAdd = <m.Achievement>[];
    for (final s in seeds) {
      if (!existingTitles.contains(s.title)) {
        toAdd.add(m.Achievement(
          id: s.title,
          title: s.title,
          description: '',
          icon: s.icon,
          unlocked: false,
        ));
      }
    }

    if (toAdd.isEmpty) return;

    await updateUserData((data) => data.copyWith(
      achievements: [...data.achievements, ...toAdd],
    ));
  }

  Future<m.Achievement?> _unlockSeed(
      String title, {
        String description = '',
      }) async {
    final seed = _seedByTitle(title);
    if (seed == null) return null;
    return unlockAchievement(
      title: seed.title,
      icon: seed.icon,
      description: description,
    );
  }

  // =============================
  // ✅ 업적 조건 체크(전체)
  // =============================

  Future<List<m.Achievement>> checkAndUnlockAchievements() async {
    if (_userData == null) return [];
    await _ensureAchievementSeeds();

    final newlyUnlocked = <m.Achievement>[];

    Future<void> unlock(String title) async {
      final a = await _unlockSeed(title);
      if (a != null) newlyUnlocked.add(a);
    }

    final quests = _userData!.quests;
    final completed = quests.where((q) => q.completed == true).toList();

    // -------------------------
    // 누적 완료
    // -------------------------
    final totalCompleted = completed.length;
    if (totalCompleted >= 10) await unlock('10개 완료');
    if (totalCompleted >= 25) await unlock('25개 완료');
    if (totalCompleted >= 50) await unlock('50개 완료');
    if (totalCompleted >= 100) await unlock('100개 완료');

    // -------------------------
    // 난이도 누적
    // -------------------------
    int countDiff(m.Difficulty d) =>
        completed.where((q) => q.difficulty == d).length;

    if (countDiff(m.Difficulty.easy) >= 30) {
      await unlock('쉬움 퀘스트 30개 완료');
    }
    if (countDiff(m.Difficulty.hard) >= 10) {
      await unlock('어려움 퀘스트 10개 완료');
    }

    // -------------------------
    // ✅ 큰 퀘스트 누적(1/10/50/100)
    // -------------------------
    final bigQuestClears = _countBigQuestClearsFrom(quests);
    if (bigQuestClears >= 1) await unlock('큰 퀘스트 클리어 1회');
    if (bigQuestClears >= 10) await unlock('큰 퀘스트 클리어 10회');
    if (bigQuestClears >= 50) await unlock('큰 퀘스트 클리어 50회');
    if (bigQuestClears >= 100) await unlock('큰 퀘스트 클리어 100회');

    // -------------------------
    // 카테고리 다양성/누적
    // -------------------------
    final byCategory = <String, int>{};
    for (final q in completed) {
      final c = q.category.trim();
      if (c.isEmpty) continue;
      byCategory[c] = (byCategory[c] ?? 0) + 1;
    }

    final uniqueCats = byCategory.keys.length;
    if (uniqueCats >= 3) await unlock('서로 다른 카테고리 3개에서 각 1개 완료');
    if (uniqueCats >= 5) await unlock('서로 다른 카테고리 5개에서 각 1개 완료');

    if ((byCategory['공부'] ?? 0) >= 10) await unlock('공부 퀘스트 10개 완료');
    if ((byCategory['운동'] ?? 0) >= 10) await unlock('운동 퀘스트 10개 완료');

    final cleanCount = (byCategory['청소'] ?? 0) +
        (byCategory['정리'] ?? 0) +
        (byCategory['청소/정리'] ?? 0);
    if (cleanCount >= 10) await unlock('청소/정리 퀘스트 10개 완료');

    if ((byCategory['자기관리'] ?? 0) >= 20) await unlock('자기관리 퀘스트 20개 완료');

    // -------------------------
    // 시간 기반(하루/주간/월간/아침/야행/주말/스트릭)
    // -------------------------
    final completedWithTime =
    completed.where((q) => q.completedAt != null).toList();

    String ymd(DateTime dt) =>
        '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

    int weekKey(DateTime dt) {
      final first = DateTime(dt.year, 1, 1);
      final diffDays = dt.difference(first).inDays;
      final week = (diffDays / 7).floor() + 1;
      return dt.year * 100 + week;
    }

    int monthKey(DateTime dt) => dt.year * 100 + dt.month;

    final perDay = <String, int>{};
    final perWeek = <int, int>{};
    final perMonth = <int, int>{};

    int morning = 0;
    int night = 0;
    int weekend = 0;

    for (final q in completedWithTime) {
      final dt = DateTime.fromMillisecondsSinceEpoch(q.completedAt!);

      final day = ymd(dt);
      perDay[day] = (perDay[day] ?? 0) + 1;

      final wk = weekKey(dt);
      perWeek[wk] = (perWeek[wk] ?? 0) + 1;

      final mk = monthKey(dt);
      perMonth[mk] = (perMonth[mk] ?? 0) + 1;

      final h = dt.hour;
      if (h >= 6 && h <= 9) morning++;
      if (h >= 23) night++;
      if (dt.weekday == DateTime.saturday || dt.weekday == DateTime.sunday) {
        weekend++;
      }
    }

    int maxOf(Iterable<int> xs) {
      var mmax = 0;
      for (final v in xs) {
        if (v > mmax) mmax = v;
      }
      return mmax;
    }

    if (maxOf(perDay.values) >= 3) await unlock('하루 3개 완료');
    if (maxOf(perDay.values) >= 5) await unlock('하루 5개 완료');
    if (maxOf(perWeek.values) >= 20) await unlock('주간 20개 완료');
    if (maxOf(perMonth.values) >= 100) await unlock('월간 100개 완료');

    if (morning >= 10) await unlock('아침형 인간 (06~09시 완료 10회)');
    if (night >= 10) await unlock('야행성 (23시 이후 완료 10회)');
    if (weekend >= 20) await unlock('주말에도 한다 (토/일 완료 20회)');

    // -------------------------
    // 스트릭: 연속 완료 3/7 + 복구자
    // -------------------------
    final days = completedWithTime
        .map((q) {
      final dt = DateTime.fromMillisecondsSinceEpoch(q.completedAt!);
      return DateTime(dt.year, dt.month, dt.day);
    })
        .toSet()
        .toList()
      ..sort((a, b) => a.compareTo(b));

    int longest = 0;
    int cur = 0;
    bool recovered = false;

    for (int i = 0; i < days.length; i++) {
      if (i == 0) {
        cur = 1;
      } else {
        final diff = days[i].difference(days[i - 1]).inDays;
        cur = (diff == 1) ? (cur + 1) : 1;
      }
      if (cur > longest) longest = cur;
    }

    if (longest >= 3) await unlock('연속 완료 3일');
    if (longest >= 7) await unlock('연속 완료 7일');

    if (days.length >= 4) {
      for (int i = 1; i < days.length; i++) {
        final gap = days[i].difference(days[i - 1]).inDays;
        if (gap >= 2) {
          int streak = 1;
          for (int j = i + 1; j < days.length; j++) {
            final d = days[j].difference(days[j - 1]).inDays;
            if (d == 1) {
              streak++;
              if (streak >= 3) {
                recovered = true;
                break;
              }
            } else {
              streak = 1;
            }
          }
        }
        if (recovered) break;
      }
    }

    if (recovered) await unlock('스트릭 복구자 (끊긴 뒤 다시 3일 연속)');

    return newlyUnlocked;
  }

  // =============================
  // 기타
  // =============================

  void backToMain() {
    notifyListeners();
  }

  Future<void> reset() async {
    _userData = null;
    notifyListeners();
    await _storageService.clearUserData();
  }
}
