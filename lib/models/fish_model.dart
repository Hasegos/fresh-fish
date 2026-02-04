/// 물고기 타입
enum FishType {
  goldfish,
  bluefish,
  redfish,
  tropical,    // 추가
  clownfish,   // 추가
  dolphin;     // 추가

  String get displayName {
    switch (this) {
      case FishType.goldfish:
        return '금붕어';
      case FishType.bluefish:
        return '파랑이';
      case FishType.redfish:
        return '빨강이';
      case FishType.tropical:
        return '열대어';
      case FishType.clownfish:
        return '니모';
      case FishType.dolphin:
        return '돌고래';
    }
  }

  String get emoji {
    switch (this) {
      case FishType.goldfish:
        return '🟡';
      case FishType.bluefish:
        return '🔵';
      case FishType.redfish:
        return '🔴';
      case FishType.tropical:
        return '🐠';
      case FishType.clownfish:
        return '🐡';
      case FishType.dolphin:
        return '🐬';
    }
  }

  String get colorHex {
    switch (this) {
      case FishType.goldfish:
        return '#FFD700';
      case FishType.bluefish:
        return '#4169E1';
      case FishType.redfish:
        return '#DC143C';
      case FishType.tropical:
        return '#FF6B9D';
      case FishType.clownfish:
        return '#FF8C00';
      case FishType.dolphin:
        return '#00CED1';
    }
  }

  String get description {
    switch (this) {
      case FishType.goldfish:
        return '행운과 부를 가져다주는\n황금빛 물고기';
      case FishType.bluefish:
        return '깊은 바다의 지혜를\n품은 물고기';
      case FishType.redfish:
        return '열정과 용기가 넘치는\n붉은 물고기';
      case FishType.tropical:
        return '화려한 색상의\n열대 물고기';
      case FishType.clownfish:
        return '귀엽고 사교적인\n니모 친구';
      case FishType.dolphin:
        return '영리하고 빠른\n바다의 천재';
    }
  }
}

/// 성장 단계 (시간 기반: 0-72시간)
enum GrowthStage {
  egg,      // 0-24시간
  juvenile, // 24-48시간
  adult;    // 48-72시간

  String get displayName {
    switch (this) {
      case GrowthStage.egg:
        return '알';
      case GrowthStage.juvenile:
        return '치어';
      case GrowthStage.adult:
        return '성체';
    }
  }
}

/// 진화 단계 (레벨 기반)
enum FishEvolution {
  egg,
  fish1,
  fish2,
  legendary;
}

/// 물고기 모델
class Fish {
  final String id;
  final FishType type;
  final int level;
  final int exp;
  final int hp;
  final int maxHp;
  final int? eggHatchedAt; // 밀리초 단위 타임스탬프
  final String eggColor; // 알 색상 (16진수 색상 코드: #RRGGBB 또는 이모지)

  Fish({
    required this.id,
    required this.type,
    required this.level,
    required this.exp,
    required this.hp,
    required this.maxHp,
    this.eggHatchedAt,
    this.eggColor = '🟡', // 기본값: 노란색 구
  });

  /// JSON → Fish
  factory Fish.fromJson(Map<String, dynamic> json) {
    return Fish(
      id: json['id'] as String,
      type: FishType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => FishType.goldfish,
      ),
      level: json['level'] as int? ?? 1,
      exp: json['exp'] as int? ?? 0,
      hp: json['hp'] as int? ?? 100,
      maxHp: json['maxHp'] as int? ?? 100,
      eggHatchedAt: json['eggHatchedAt'] as int?,
      eggColor: json['eggColor'] as String? ?? '🟡',
    );
  }

  /// Fish → JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'level': level,
      'exp': exp,
      'hp': hp,
      'maxHp': maxHp,
      'eggHatchedAt': eggHatchedAt,
      'eggColor': eggColor,
    };
  }

  /// copyWith
  Fish copyWith({
    String? id,
    FishType? type,
    int? level,
    int? exp,
    int? hp,
    int? maxHp,
    int? eggHatchedAt,
    String? eggColor,
  }) {
    return Fish(
      id: id ?? this.id,
      type: type ?? this.type,
      level: level ?? this.level,
      exp: exp ?? this.exp,
      hp: hp ?? this.hp,
      maxHp: maxHp ?? this.maxHp,
      eggHatchedAt: eggHatchedAt ?? this.eggHatchedAt,
      eggColor: eggColor ?? this.eggColor,
    );
  }
}