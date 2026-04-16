import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ca_khia_fc/core/constants/app_constants.dart';
import 'package:ca_khia_fc/data/models/question.dart';

class ScoreRepository {
  final SharedPreferences _prefs;

  ScoreRepository(this._prefs);

  int getHighScore() => _prefs.getInt(AppConstants.keyHighScore) ?? 0;

  int getTotalGames() => _prefs.getInt(AppConstants.keyTotalGames) ?? 0;

  int getStreak() => _prefs.getInt(AppConstants.keyStreak) ?? 0;

  int getTotalCorrect() => _prefs.getInt(AppConstants.keyTotalCorrect) ?? 0;

  int getTotalAnswered() => _prefs.getInt(AppConstants.keyTotalAnswered) ?? 0;

  double getOverallAccuracy() {
    final answered = getTotalAnswered();
    if (answered == 0) return 0;
    return getTotalCorrect() / answered;
  }

  String getPlayerName() => _prefs.getString(AppConstants.keyPlayerName) ?? 'Khách';

  Future<void> savePlayerName(String name) =>
      _prefs.setString(AppConstants.keyPlayerName, name);

  Future<void> saveScore(GameScore score) async {
    // High score
    if (score.score > getHighScore()) {
      await _prefs.setInt(AppConstants.keyHighScore, score.score);
    }

    // Total games
    await _prefs.setInt(AppConstants.keyTotalGames, getTotalGames() + 1);

    // Accuracy tracking
    await _prefs.setInt(AppConstants.keyTotalCorrect, getTotalCorrect() + score.correctCount);
    await _prefs.setInt(AppConstants.keyTotalAnswered, getTotalAnswered() + score.totalQuestions);

    // Streak
    await _updateStreak();

    // History
    final history = getScoreHistory();
    history.insert(0, score);
    await _prefs.setString(
      AppConstants.keyScoreHistory,
      jsonEncode(history.take(20).map((s) => s.toJson()).toList()),
    );
  }

  Future<void> _updateStreak() async {
    final lastRaw = _prefs.getString(AppConstants.keyLastPlayedDate);
    final today = _todayKey();

    if (lastRaw == null) {
      await _prefs.setInt(AppConstants.keyStreak, 1);
    } else if (lastRaw == today) {
      // Already played today — streak unchanged
      return;
    } else if (lastRaw == _yesterdayKey()) {
      // Played yesterday — extend streak
      await _prefs.setInt(AppConstants.keyStreak, getStreak() + 1);
    } else {
      // Streak broken
      await _prefs.setInt(AppConstants.keyStreak, 1);
    }

    await _prefs.setString(AppConstants.keyLastPlayedDate, today);
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String _yesterdayKey() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
  }

  GameScore? getLastGame() {
    final history = getScoreHistory();
    return history.isEmpty ? null : history.first;
  }

  List<GameScore> getScoreHistory() {
    final raw = _prefs.getString(AppConstants.keyScoreHistory);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => GameScore.fromJson(e as Map<String, dynamic>)).toList();
  }
}
