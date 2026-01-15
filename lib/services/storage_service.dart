import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user_data_model.dart';
import '../models/fish_model.dart';
import '../models/quest_model.dart';
import 'firebase_service.dart';

/// 로컬 저장소 서비스
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static const String _userDataKey = 'user_data';
  final FirebaseService _firebaseService = FirebaseService();
  final Uuid _uuid = const Uuid();

  /// 사용자 데이터 저장 (로컬 + Firebase)
  Future<void> saveUserData(UserData userData) async {
    try {
      // 로컬 저장
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(userData.toJson());
      await prefs.setString(_userDataKey, jsonString);

      // Firebase 저장 (백그라운드)
      _firebaseService.saveUserData(userData).catchError((e) {
        print('Firebase 저장 실패 (무시): $e');
      });
    } catch (e) {
      print('로컬 저장 실패: $e');
      rethrow;
    }
  }

  /// 사용자 데이터 불러오기
  Future<UserData?> getUserData() async {
    try {
      // 먼저 로컬에서 불러오기
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_userDataKey);

      if (jsonString != null) {
        final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
        return UserData.fromJson(jsonMap);
      }

      // 로컬에 없으면 Firebase에서 시도
      final firebaseData = await _firebaseService.getUserData();
      if (firebaseData != null) {
        // Firebase 데이터를 로컬에 저장
        await saveUserData(firebaseData);
        return firebaseData;
      }
    } catch (e) {
      print('데이터 불러오기 실패: $e');
    }

    return null;
  }

  /// 사용자 데이터 삭제
  Future<void> clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userDataKey);
      await _firebaseService.deleteUserData();
    } catch (e) {
      print('데이터 삭제 실패: $e');
    }
  }

  /// 초기 사용자 생성
  UserData createInitialUser(
    FishType fishType,
    List<String> selectedCategories,
  ) {
    final now = DateTime.now();
    final dateString = _formatDate(now);

    return UserData(
      id: _uuid.v4(),
      fish: Fish(
        id: _uuid.v4(),
        type: fishType,
        level: 1,
        exp: 0,
        hp: 100,
        maxHp: 100,
        eggHatchedAt: now.millisecondsSinceEpoch,
      ),
      gold: 0,
      currentDate: dateString,
      quests: _generateInitialQuests(selectedCategories, dateString),
      habits: [],
      todos: [],
      history: [],
      onboardingCompleted: true,
      selectedCategories: selectedCategories,
      waterQuality: 100,
      achievements: [],
      customRewards: [],
      decorations: [],
      ownedDecorations: [],
    );
  }

  /// 초기 퀘스트 생성
  List<Quest> _generateInitialQuests(List<String> categories, String date) {
    final quests = <Quest>[];

    for (final category in categories) {
      // 각 카테고리마다 2개의 퀘스트 생성
      quests.add(Quest(
        id: _uuid.v4(),
        title: _getQuestTitle(category, Difficulty.easy),
        category: category,
        completed: false,
        date: date,
        expReward: 15,
        goldReward: 8,
        questType: QuestType.daily,
        difficulty: Difficulty.easy,
      ));

      quests.add(Quest(
        id: _uuid.v4(),
        title: _getQuestTitle(category, Difficulty.normal),
        category: category,
        completed: false,
        date: date,
        expReward: 25,
        goldReward: 15,
        questType: QuestType.daily,
        difficulty: Difficulty.normal,
      ));
    }

    return quests;
  }

  /// 카테고리별 퀘스트 제목
  String _getQuestTitle(String category, Difficulty difficulty) {
    final templates = {
      '학업': ['30분 공부하기', '강의 1개 듣기', '복습 30분 하기'],
      '건강': ['30분 운동하기', '스트레칭 10분', '물 8잔 마시기'],
      '자기계발': ['책 30페이지 읽기', '명상 10분', '새로운 것 배우기'],
      '생활': ['방 정리하기', '설거지하기', '청소 10분'],
    };

    final categoryTemplates = templates[category] ?? ['퀘스트 완료하기'];
    final index = difficulty.index % categoryTemplates.length;
    return categoryTemplates[index];
  }

  /// 날짜 포맷
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
