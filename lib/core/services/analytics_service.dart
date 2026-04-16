import 'package:firebase_analytics/firebase_analytics.dart';

/// Wraps [FirebaseAnalytics] with typed, domain-specific event methods.
///
/// All log calls are fire-and-forget (unawaited) — failures are silently
/// swallowed so analytics never blocks or crashes the game.
class AnalyticsService {
  AnalyticsService._();

  static final AnalyticsService instance = AnalyticsService._();

  final FirebaseAnalytics _fa = FirebaseAnalytics.instance;

  // ---------------------------------------------------------------------------
  // Quiz events
  // ---------------------------------------------------------------------------

  /// Fired when the player starts a new quiz round.
  Future<void> logQuizStart({required String category}) async {
    try {
      await _fa.logEvent(
        name: 'quiz_start',
        parameters: {'category': category},
      );
    } catch (_) {}
  }

  /// Fired after each question is answered (or time runs out).
  ///
  /// [selectedIndex] is -1 when the timer expired without a selection.
  Future<void> logQuestionAnswered({
    required String category,
    required int questionIndex,
    required int selectedIndex,
    required int correctIndex,
    required int timeLeft,
  }) async {
    try {
      final isCorrect = selectedIndex == correctIndex;
      final timedOut = selectedIndex == -1;
      await _fa.logEvent(
        name: 'question_answered',
        parameters: {
          'category': category,
          'question_index': questionIndex,
          'is_correct': isCorrect ? 1 : 0,
          'timed_out': timedOut ? 1 : 0,
          'time_left': timeLeft,
        },
      );
    } catch (_) {}
  }

  /// Fired when the full quiz round ends and the result screen is shown.
  Future<void> logQuizComplete({
    required String category,
    required int score,
    required int correctCount,
    required int totalQuestions,
  }) async {
    try {
      final accuracy = totalQuestions > 0
          ? (correctCount * 100 ~/ totalQuestions)
          : 0;
      await _fa.logEvent(
        name: 'quiz_complete',
        parameters: {
          'category': category,
          'score': score,
          'correct_count': correctCount,
          'total_questions': totalQuestions,
          'accuracy_pct': accuracy,
        },
      );
    } catch (_) {}
  }
}
