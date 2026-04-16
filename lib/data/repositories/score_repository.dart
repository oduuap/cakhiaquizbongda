import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ca_khia_fc/core/constants/app_constants.dart';
import 'package:ca_khia_fc/data/models/question.dart';

class ScoreRepository {
  final SharedPreferences _prefs;

  ScoreRepository(this._prefs);

  int getHighScore() => _prefs.getInt(AppConstants.keyHighScore) ?? 0;

  int getTotalGames() => _prefs.getInt(AppConstants.keyTotalGames) ?? 0;

  String getPlayerName() => _prefs.getString(AppConstants.keyPlayerName) ?? 'Khách';

  Future<void> savePlayerName(String name) =>
      _prefs.setString(AppConstants.keyPlayerName, name);

  Future<void> saveScore(GameScore score) async {
    final currentHigh = getHighScore();
    if (score.score > currentHigh) {
      await _prefs.setInt(AppConstants.keyHighScore, score.score);
    }

    await _prefs.setInt(AppConstants.keyTotalGames, getTotalGames() + 1);

    final history = getScoreHistory();
    history.insert(0, score);
    final limited = history.take(20).toList();
    await _prefs.setString(
      AppConstants.keyScoreHistory,
      jsonEncode(limited.map((s) => s.toJson()).toList()),
    );
  }

  List<GameScore> getScoreHistory() {
    final raw = _prefs.getString(AppConstants.keyScoreHistory);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => GameScore.fromJson(e as Map<String, dynamic>)).toList();
  }
}
