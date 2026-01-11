import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_data.dart';
import '../models/quest.dart';
import '../models/daily_record.dart';

class StorageService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 앱 시작 시 한 번 호출 (main.dart에서 이미 호출 중)
  /// - Firebase Auth 익명 로그인 보장
  static Future<void> init() async {
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }
  }

  static String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Firebase Auth user is null. StorageService.init() 먼저 호출해야 합니다.');
    }
    return user.uid;
  }

  static DocumentReference<Map<String, dynamic>> get _userDoc =>
      _db.collection('users').doc(_uid);

  // ======================
  // User Data
  // ======================
  static Future<void> saveUserData(UserData userData) async {
    await _userDoc.set(
      {
        'userData': userData.toJson(),
      },
      SetOptions(merge: true),
    );
  }

  static Future<UserData?> getUserData() async {
    final snap = await _userDoc.get();
    if (!snap.exists) return null;

    final data = snap.data();
    if (data == null) return null;

    final userJson = data['userData'];
    if (userJson == null) return null;

    // userJson 이 Map<String, dynamic> 형태라고 가정
    return UserData.fromJson(
      Map<String, dynamic>.from(userJson as Map),
    );
  }

  static Future<void> deleteUserData() async {
    await _userDoc.update({
      'userData': FieldValue.delete(),
    });
  }

  // ======================
  // Daily Quests
  // ======================
  /// date 예: '2026-01-09'
  static Future<void> saveDailyQuests(List<Quest> quests, String date) async {
    final questsJson = quests.map((q) => q.toJson()).toList();

    await _userDoc.set(
      {
        'dailyQuests': questsJson,
        'questDate': date,
      },
      SetOptions(merge: true),
    );
  }

  static Future<List<Quest>?> getDailyQuests(String date) async {
    final snap = await _userDoc.get();
    if (!snap.exists) return null;

    final data = snap.data();
    if (data == null) return null;

    final savedDate = data['questDate'] as String?;
    if (savedDate != date) return null;

    final questsJson = data['dailyQuests'] as List<dynamic>?;
    if (questsJson == null) return null;

    return questsJson
        .map(
          (q) => Quest.fromJson(
        Map<String, dynamic>.from(q as Map),
      ),
    )
        .toList();
  }

  // ======================
  // History
  // ======================
  static Future<void> saveHistory(List<DailyRecord> history) async {
    final historyJson = history.map((r) => r.toJson()).toList();

    await _userDoc.set(
      {
        'history': historyJson,
      },
      SetOptions(merge: true),
    );
  }

  static Future<List<DailyRecord>> getHistory() async {
    final snap = await _userDoc.get();
    if (!snap.exists) return [];

    final data = snap.data();
    if (data == null) return [];

    final historyJson = data['history'] as List<dynamic>?;
    if (historyJson == null) return [];

    return historyJson
        .map(
          (r) => DailyRecord.fromJson(
        Map<String, dynamic>.from(r as Map),
      ),
    )
        .toList();
  }

  // ======================
  // Clear all data (이 유저의 문서 통째로 삭제)
  // ======================
  static Future<void> clearAll() async {
    await _userDoc.delete();
  }

  // ======================
  // Quest Templates (기존 로직 그대로 유지)
  // ======================
  static List<Map<String, dynamic>> getQuestTemplates() {
    return [
      {'title': '물 8잔 마시기', 'exp': 50},
      {'title': '30분 운동하기', 'exp': 100},
      {'title': '아침 먹기', 'exp': 50},
      {'title': '10분 명상하기', 'exp': 80},
      {'title': '책 30분 읽기', 'exp': 70},
      {'title': '스트레칭 15분', 'exp': 60},
      {'title': '10,000보 걷기', 'exp': 120},
      {'title': '간식 줄이기', 'exp': 60},
      {'title': '일찍 잠자리에 들기', 'exp': 80},
      {'title': '감사 일기 쓰기', 'exp': 70},
      {'title': '핸드폰 사용 1시간 줄이기', 'exp': 90},
      {'title': '채소 먹기', 'exp': 50},
    ];
  }

  static List<Quest> generateRandomQuests() {
    final templates = getQuestTemplates()..shuffle();
    final selected = templates.take(4).toList();

    return selected.asMap().entries.map((entry) {
      final index = entry.key;
      final template = entry.value;
      return Quest(
        id: 'quest-$index-${DateTime.now().millisecondsSinceEpoch}',
        title: template['title'] as String,
        exp: template['exp'] as int,
        completed: false,
      );
    }).toList();
  }
}