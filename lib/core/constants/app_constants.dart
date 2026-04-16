class AppConstants {
  static const int questionsPerGame = 10;
  static const int secondsPerQuestion = 15;
  static const int pointsPerCorrectAnswer = 100;
  static const int bonusPointsForSpeed = 50;

  static const String appName = 'Ca Khía FC';
  static const String tagline = 'Thách thức tri thức bóng đá!';

  // SharedPreferences keys
  static const String keyHighScore = 'high_score';
  static const String keyTotalGames = 'total_games';
  static const String keyPlayerName = 'player_name';
  static const String keyScoreHistory = 'score_history';
  static const String keyStreak = 'streak';
  static const String keyLastPlayedDate = 'last_played_date';
  static const String keyTotalCorrect = 'total_correct';
  static const String keyTotalAnswered = 'total_answered';
}

enum QuizCategory {
  vLeague('V-League', '🏆'),
  nationalTeam('Đội Tuyển VN', '🇻🇳'),
  worldFootball('Bóng Đá Thế Giới', '🌍'),
  cakhia('Ca Khía Kinh Điển', '🔥');

  const QuizCategory(this.label, this.emoji);
  final String label;
  final String emoji;
}
