/// 스킨 희귀도
enum SkinRarity {
  common,
  uncommon,
  rare,
  epic,
  legendary;
}

/// 스킨 테마 아이템
class Skin {
  final String id;
  final String name;
  final String icon;
  final int cost;
  final String description;
  final SkinRarity rarity;
  final String color; // 배경색이나 특수 효과 색상 코드

  const Skin({
    required this.id,
    required this.name,
    required this.icon,
    required this.cost,
    required this.description,
    required this.rarity,
    required this.color,
  });

  factory Skin.fromJson(Map<String, dynamic> json) {
    return Skin(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      cost: json['cost'] as int,
      description: json['description'] as String,
      rarity: SkinRarity.values.firstWhere(
        (e) => e.name == json['rarity'],
        orElse: () => SkinRarity.common,
      ),
      color: json['color'] as String? ?? '#FFFFFF',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'cost': cost,
      'description': description,
      'rarity': rarity.name,
      'color': color,
    };
  }
}