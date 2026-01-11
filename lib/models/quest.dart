class Quest {
  final String id;
  final String title;
  final int exp;
  final bool completed;

  Quest({
    required this.id,
    required this.title,
    required this.exp,
    this.completed = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'exp': exp,
      'completed': completed,
    };
  }

  factory Quest.fromJson(Map<String, dynamic> json) {
    return Quest(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      exp: json['exp'] ?? 0,
      completed: json['completed'] ?? false,
    );
  }

  Quest copyWith({
    String? id,
    String? title,
    int? exp,
    bool? completed,
  }) {
    return Quest(
      id: id ?? this.id,
      title: title ?? this.title,
      exp: exp ?? this.exp,
      completed: completed ?? this.completed,
    );
  }
}