import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  final String nickname;
  final int selectedFish;
  final int level;
  final int exp;
  final int gold;
  final bool notificationsEnabled;

  final DateTime? lastLogin;

  UserData({
    required this.nickname,
    required this.selectedFish,
    required this.level,
    required this.exp,
    required this.gold,
    required this.notificationsEnabled,
    this.lastLogin,
  });

  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'selectedFish': selectedFish,
      'level': level,
      'exp': exp,
      'gold': gold,
      'notificationsEnabled': notificationsEnabled,
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : FieldValue.serverTimestamp(),
    };
  }

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      nickname: json['nickname'] ?? '',
      selectedFish: json['selectedFish'] ?? 0,
      level: json['level'] ?? 1,
      exp: json['exp'] ?? 0,
      gold: json['gold'] ?? 100,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      lastLogin: json['lastLogin'] is Timestamp
          ? (json['lastLogin'] as Timestamp).toDate()
          : null,
    );
  }

  factory UserData.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) throw Exception("User data not found");

    return UserData.fromJson(data);
  }

  UserData copyWith({
    String? nickname,
    int? selectedFish,
    int? level,
    int? exp,
    int? gold,
    bool? notificationsEnabled,
    DateTime? lastLogin,
  }) {
    return UserData(
      nickname: nickname ?? this.nickname,
      selectedFish: selectedFish ?? this.selectedFish,
      level: level ?? this.level,
      exp: exp ?? this.exp,
      gold: gold ?? this.gold,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  int get expNeeded => level * 100;
  double get expPercentage => exp / expNeeded;
}