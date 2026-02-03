/// 퀘스트 템플릿 데이터
class QuestTemplates {
  static const Map<String, List<String>> templates = {
    '학업': [
      '30분 공부하기',
      '강의 1개 듣기',
      '복습 30분 하기',
      '노트 정리하기',
      '과제 1개 완료하기',
      '새로운 개념 학습하기',
      '문제 10개 풀기',
      '요약 정리하기',
    ],
    '건강': [
      '30분 운동하기',
      '스트레칭 10분',
      '물 8잔 마시기',
      '산책 20분',
      '계단 오르기',
      '플랭크 1분',
      '요가 15분',
      '아침 운동 루틴',
    ],
    '자기계발': [
      '책 30페이지 읽기',
      '명상 10분',
      '새로운 것 배우기',
      '일기 쓰기',
      '아티클 3개 읽기',
      '독서 노트 작성',
      '감사일기 쓰기',
      '목표 점검하기',
    ],
    '생활': [
      '방 정리하기',
      '설거지하기',
      '빨래하기',
      '청소 10분',
      '책상 정리',
      '필요없는 물건 버리기',
      '이메일 정리',
      '일정 계획 세우기',
    ],
  };
  
  /// 카테고리별 퀘스트 가져오기
  static List<String> getQuestsForCategory(String category) {
    return templates[category] ?? ['퀘스트 완료하기'];
  }
  
  /// 랜덤 퀘스트 가져오기
  static String getRandomQuest(String category) {
    final quests = getQuestsForCategory(category);
    return quests[DateTime.now().millisecond % quests.length];
  }
}
