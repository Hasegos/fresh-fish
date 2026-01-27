// lib/data/timer_categories.dart
import '../models/timer_model.dart';

/// 앱에서 사용할 타이머 카테고리 목록 데이터
const List<TimerCategory> defaultTimerCategories = [
  TimerCategory(name: '학업', icon: '📚', color: '#4FC3F7'),
  TimerCategory(name: '업무', icon: '💻', color: '#9575CD'),
  TimerCategory(name: '건강', icon: '🏃', color: '#81C784'),
  TimerCategory(name: '독서', icon: '📖', color: '#FFB74D'),
  TimerCategory(name: '자기계발', icon: '✨', color: '#F06292'),
  TimerCategory(name: '명상', icon: '🧘', color: '#90A4AE'),
];