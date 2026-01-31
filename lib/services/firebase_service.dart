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
