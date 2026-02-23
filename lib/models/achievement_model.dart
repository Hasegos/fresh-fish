/// 업적 모델
class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool unlocked;
  final String? unlockedDate;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.unlocked,
    this.unlockedDate,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      unlocked: json['unlocked'] as bool? ?? false,
      unlockedDate: json['unlockedDate'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'unlocked': unlocked,
      'unlockedDate': unlockedDate,
    };
  }

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    bool? unlocked,
    String? unlockedDate,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      unlocked: unlocked ?? this.unlocked,
      unlockedDate: unlockedDate ?? this.unlockedDate,
    );
  }
}
