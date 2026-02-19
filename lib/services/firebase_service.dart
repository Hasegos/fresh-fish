import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart'; // 추가
import '../models/user_data_model.dart';

/// Firebase 서비스 (안전한 게터 방식)
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // 💡 [수정] 변수가 아닌 Getter로 변경합니다.
  // 이렇게 하면 Firebase.initializeApp()이 완전히 끝난 후에 호출되므로 안전합니다.
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  /// 현재 사용자 ID
  String? get currentUserId {
    if (Firebase.apps.isEmpty) return null;
    return _auth.currentUser?.uid;
  }

  /// 익명 로그인
  Future<User?> signInAnonymously() async {
    try {
      // 💡 실행 전 Firebase 앱이 있는지 한 번 더 체크하면 완벽합니다.
      if (Firebase.apps.isEmpty) return null;

      final userCredential = await _auth.signInAnonymously();
      return userCredential.user;
    } catch (e) {
      print('Firebase 익명 로그인 실패: $e');
      return null;
    }
  }

  /// 사용자 데이터 저장
  Future<void> saveUserData(UserData userData) async {
    if (Firebase.apps.isEmpty) return;
    if (currentUserId == null) {
      await signInAnonymously();
    }

    final uid = currentUserId;
    if (uid == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .set(userData.toJson());
    } catch (e) {
      print('Firebase 저장 실패: $e');
    }
  }

  /// 타이머 누적 시간 저장 (트랜잭션)
  ///
  /// Why:
  /// - 여러 디바이스/세션에서 동시에 종료가 발생해도 누적치가 꼬이지 않도록
  ///   Firestore 트랜잭션으로 원자적(atomic) 업데이트를 수행합니다.
  ///
  /// How:
  /// - users/{uid} 문서를 읽은 뒤 기존 누적값을 가져와
  ///   totalFocusSeconds, totalFocusSessions, 카테고리별 누적 seconds를 증가시킵니다.
  Future<void> accumulateFocusDuration({
    required String category,
    required int durationSeconds,
  }) async {
    if (durationSeconds <= 0) return;
    if (Firebase.apps.isEmpty) return;

    if (currentUserId == null) {
      await signInAnonymously();
    }

    final uid = currentUserId;
    if (uid == null) return;

    final userDoc = _firestore.collection('users').doc(uid);
    final safeCategoryKey = category
        .replaceAll('.', '_')
        .replaceAll('/', '_')
        .replaceAll('[', '_')
        .replaceAll(']', '_');

    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDoc);
        final data = snapshot.data() ?? <String, dynamic>{};

        final stats = (data['stats'] as Map<String, dynamic>?) ?? <String, dynamic>{};
        final categorySeconds =
            (stats['categorySeconds'] as Map<String, dynamic>?) ?? <String, dynamic>{};

        final currentTotalSeconds = (stats['totalFocusSeconds'] as num?)?.toInt() ?? 0;
        final currentTotalSessions = (stats['totalFocusSessions'] as num?)?.toInt() ?? 0;
        final currentCategorySeconds =
            (categorySeconds[safeCategoryKey] as num?)?.toInt() ?? 0;

        categorySeconds[safeCategoryKey] = currentCategorySeconds + durationSeconds;

        final nextStats = <String, dynamic>{
          ...stats,
          'totalFocusSeconds': currentTotalSeconds + durationSeconds,
          'totalFocusSessions': currentTotalSessions + 1,
          'lastFocusCategory': category,
          'updatedAt': FieldValue.serverTimestamp(),
          'categorySeconds': categorySeconds,
        };

        transaction.set(userDoc, {
          'stats': nextStats,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      });
    } catch (e) {
      print('Firebase 타이머 누적 저장 실패: $e');
    }
  }

  /// 사용자 데이터 불러오기
  Future<UserData?> getUserData() async {
    if (Firebase.apps.isEmpty) return null;
    if (currentUserId == null) {
      await signInAnonymously();
    }

    final uid = currentUserId;
    if (uid == null) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists && doc.data() != null) {
        return UserData.fromJson(doc.data()!);
      }
    } catch (e) {
      print('Firebase 불러오기 실패: $e');
    }

    return null;
  }

  /// 사용자 데이터 삭제
  Future<void> deleteUserData() async {
    if (Firebase.apps.isEmpty) return;
    final uid = currentUserId;
    if (uid == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .delete();
    } catch (e) {
      print('Firebase 삭제 실패: $e');
    }
  }

  /// 실시간 동기화 (Stream)
  Stream<UserData?>? watchUserData() {
    if (Firebase.apps.isEmpty) return null;
    final uid = currentUserId;
    if (uid == null) return null;

    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return UserData.fromJson(snapshot.data()!);
      }
      return null;
    });
  }
}
