import 'package:ca_khia_fc/core/constants/app_constants.dart';

class Question {
  final String id;
  final String text;
  final List<String> options;
  final int correctIndex;
  final QuizCategory category;
  final String? explanation;

  const Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.category,
    this.explanation,
  });

  String get correctAnswer => options[correctIndex];
}

class GameScore {
  final int score;
  final int correctCount;
  final int totalQuestions;
  final DateTime playedAt;
  final String category;

  const GameScore({
    required this.score,
    required this.correctCount,
    required this.totalQuestions,
    required this.playedAt,
    required this.category,
  });

  double get accuracy => correctCount / totalQuestions;

  String get rank {
    if (accuracy >= 0.9) return 'Vua Ca Khía 👑';
    if (accuracy >= 0.7) return 'Cao Thủ 🔥';
    if (accuracy >= 0.5) return 'Dân Chơi 😎';
    return 'Tân Binh 🐣';
  }

  Map<String, dynamic> toJson() => {
        'score': score,
        'correctCount': correctCount,
        'totalQuestions': totalQuestions,
        'playedAt': playedAt.toIso8601String(),
        'category': category,
      };

  factory GameScore.fromJson(Map<String, dynamic> json) => GameScore(
        score: json['score'] as int,
        correctCount: json['correctCount'] as int,
        totalQuestions: json['totalQuestions'] as int,
        playedAt: DateTime.parse(json['playedAt'] as String),
        category: json['category'] as String,
      );
}
