// lib/models/quest_model.dart

class ToDo {
  final String id;
  final String title;
  final int goldReward;
  final int expReward;
  final bool completed;

  ToDo({
    required this.id,
    required this.title,
    this.goldReward = 10,
    this.expReward = 5,
    this.completed = false,
  });

  // JSON 변환 및 복사를 위한 메서드 (필수)
  factory ToDo.fromJson(Map<String, dynamic> json) {
    return ToDo(
      id: json['id'] as String,
      title: json['title'] as String,
      goldReward: json['goldReward'] as int? ?? 10,
      expReward: json['expReward'] as int? ?? 5,
      completed: json['completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'goldReward': goldReward,
    'expReward': expReward,
    'completed': completed,
  };

  ToDo copyWith({bool? completed}) {
    return ToDo(
      id: id,
      title: title,
      goldReward: goldReward,
      expReward: expReward,
      completed: completed ?? this.completed,
    );
  }
}