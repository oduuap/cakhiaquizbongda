import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ca_khia_fc/core/constants/app_constants.dart';
import 'package:ca_khia_fc/core/services/analytics_service.dart';
import 'package:ca_khia_fc/data/models/question.dart';
import 'package:ca_khia_fc/data/repositories/question_repository.dart';

enum QuizStatus { idle, running, answered, finished }

class QuizState {
  final List<Question> questions;
  final int currentIndex;
  final int? selectedOptionIndex;
  final int score;
  final int correctCount;
  final int timeLeft;
  final QuizStatus status;

  const QuizState({
    required this.questions,
    required this.currentIndex,
    required this.selectedOptionIndex,
    required this.score,
    required this.correctCount,
    required this.timeLeft,
    required this.status,
  });

  Question? get currentQuestion =>
      currentIndex < questions.length ? questions[currentIndex] : null;

  bool get isLastQuestion => currentIndex >= questions.length - 1;

  QuizState copyWith({
    List<Question>? questions,
    int? currentIndex,
    int? selectedOptionIndex,
    int? score,
    int? correctCount,
    int? timeLeft,
    QuizStatus? status,
    bool clearSelected = false,
  }) {
    return QuizState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedOptionIndex: clearSelected ? null : (selectedOptionIndex ?? this.selectedOptionIndex),
      score: score ?? this.score,
      correctCount: correctCount ?? this.correctCount,
      timeLeft: timeLeft ?? this.timeLeft,
      status: status ?? this.status,
    );
  }
}

class QuizNotifier extends StateNotifier<QuizState> {
  final QuestionRepository _repo;
  Timer? _timer;
  String _currentCategory = '';

  QuizNotifier(this._repo)
      : super(const QuizState(
          questions: [],
          currentIndex: 0,
          selectedOptionIndex: null,
          score: 0,
          correctCount: 0,
          timeLeft: AppConstants.secondsPerQuestion,
          status: QuizStatus.idle,
        ));

  void startGame(QuizCategory category) {
    _currentCategory = category.label;
    final questions = _repo.getRandomQuestions(category, AppConstants.questionsPerGame);
    state = QuizState(
      questions: questions,
      currentIndex: 0,
      selectedOptionIndex: null,
      score: 0,
      correctCount: 0,
      timeLeft: AppConstants.secondsPerQuestion,
      status: QuizStatus.running,
    );
    _startTimer();
    AnalyticsService.instance.logQuizStart(category: _currentCategory);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.timeLeft <= 1) {
        _onTimeUp();
      } else {
        state = state.copyWith(timeLeft: state.timeLeft - 1);
      }
    });
  }

  void _onTimeUp() {
    _timer?.cancel();
    final question = state.currentQuestion;
    if (question != null) {
      AnalyticsService.instance.logQuestionAnswered(
        category: _currentCategory,
        questionIndex: state.currentIndex,
        selectedIndex: -1,
        correctIndex: question.correctIndex,
        timeLeft: 0,
      );
    }
    state = state.copyWith(
      status: QuizStatus.answered,
      selectedOptionIndex: -1, // -1 = time up, no answer selected
    );
    Future.delayed(const Duration(milliseconds: 1500), _nextQuestion);
  }

  void selectAnswer(int index) {
    if (state.status != QuizStatus.running) return;
    _timer?.cancel();

    final question = state.currentQuestion!;
    final isCorrect = index == question.correctIndex;
    final timeBonus = isCorrect ? (state.timeLeft * AppConstants.bonusPointsForSpeed ~/ AppConstants.secondsPerQuestion) : 0;
    final points = isCorrect ? AppConstants.pointsPerCorrectAnswer + timeBonus : 0;

    AnalyticsService.instance.logQuestionAnswered(
      category: _currentCategory,
      questionIndex: state.currentIndex,
      selectedIndex: index,
      correctIndex: question.correctIndex,
      timeLeft: state.timeLeft,
    );

    state = state.copyWith(
      selectedOptionIndex: index,
      score: state.score + points,
      correctCount: state.correctCount + (isCorrect ? 1 : 0),
      status: QuizStatus.answered,
    );

    Future.delayed(const Duration(milliseconds: 1500), _nextQuestion);
  }

  void _nextQuestion() {
    if (state.isLastQuestion) {
      state = state.copyWith(status: QuizStatus.finished);
      return;
    }
    state = state.copyWith(
      currentIndex: state.currentIndex + 1,
      timeLeft: AppConstants.secondsPerQuestion,
      status: QuizStatus.running,
      clearSelected: true,
    );
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final questionRepoProvider = Provider((_) => QuestionRepository());

final quizProvider = StateNotifierProvider<QuizNotifier, QuizState>(
  (ref) => QuizNotifier(ref.read(questionRepoProvider)),
);
