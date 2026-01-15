import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_data_model.dart';

/// Firebase 서비스
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 현재 사용자 ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// 익명 로그인
  Future<User?> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      return userCredential.user;
    } catch (e) {
      print('Firebase 익명 로그인 실패: $e');
      return null;
    }
  }

  /// 사용자 데이터 저장
  Future<void> saveUserData(UserData userData) async {
    if (currentUserId == null) {
      await signInAnonymously();
    }

    if (currentUserId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .set(userData.toJson());
    } catch (e) {
      print('Firebase 저장 실패: $e');
    }
  }

  /// 사용자 데이터 불러오기
  Future<UserData?> getUserData() async {
    if (currentUserId == null) {
      await signInAnonymously();
    }

    if (currentUserId == null) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(currentUserId)
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
    if (currentUserId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .delete();
    } catch (e) {
      print('Firebase 삭제 실패: $e');
    }
  }

  /// 실시간 동기화 (Stream)
  Stream<UserData?>? watchUserData() {
    if (currentUserId == null) return null;

    return _firestore
        .collection('users')
        .doc(currentUserId)
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists && snapshot.data() != null) {
            return UserData.fromJson(snapshot.data()!);
          }
          return null;
        });
  }
}
