/// 장식 타입
enum DecorationType {
  plant,
  stone,
  coral,
  ornament;
}

/// 희귀도
enum Rarity {
  common,
  rare,
  epic,
  legendary;
}

/// 장식 아이템
class Decoration {
  final String id;
  final String name;
  final DecorationType type;
  final String icon;
  final int cost;
  final String description;
  final Rarity rarity;

  const Decoration({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.cost,
    required this.description,
    required this.rarity,
  });

  factory Decoration.fromJson(Map<String, dynamic> json) {
    return Decoration(
      id: json['id'] as String,
      name: json['name'] as String,
      type: DecorationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => DecorationType.plant,
      ),
      icon: json['icon'] as String,
      cost: json['cost'] as int,
      description: json['description'] as String,
      rarity: Rarity.values.firstWhere(
        (e) => e.name == json['rarity'],
        orElse: () => Rarity.common,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'icon': icon,
      'cost': cost,
      'description': description,
      'rarity': rarity.name,
    };
  }
}

/// 배치된 장식
class PlacedDecoration {
  final String decorationId;
  final double x; // 퍼센트 위치
  final double y; // 퍼센트 위치

  PlacedDecoration({
    required this.decorationId,
    required this.x,
    required this.y,
  });

  factory PlacedDecoration.fromJson(Map<String, dynamic> json) {
    return PlacedDecoration(
      decorationId: json['decorationId'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'decorationId': decorationId,
      'x': x,
      'y': y,
    };
  }

  PlacedDecoration copyWith({
    String? decorationId,
    double? x,
    double? y,
  }) {
    return PlacedDecoration(
      decorationId: decorationId ?? this.decorationId,
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }
}
