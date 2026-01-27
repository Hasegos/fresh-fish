/// 장식 타입
enum DecorationType {
  plant,
  stone,
  coral,
  ornament;
}

/// 희귀도 (기존 DecorationRarity가 아니라 Rarity로 정의되어 있습니다)
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

  // [수정] 생성자 앞에 'const'를 추가하여 상수 생성이 가능하게 합니다.
  const Decoration({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.cost,
    required this.description,
    required this.rarity,
  });

  // factory와 toJson은 그대로 두셔도 됩니다.
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