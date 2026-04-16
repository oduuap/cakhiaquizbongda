import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:ca_khia_fc/core/constants/app_constants.dart';
import 'package:ca_khia_fc/core/theme/app_theme.dart';
import 'package:ca_khia_fc/features/quiz/providers/quiz_provider.dart';
import 'package:ca_khia_fc/features/quiz/widgets/option_button.dart';
import 'package:ca_khia_fc/features/quiz/widgets/timer_widget.dart';
import 'package:ca_khia_fc/features/result/screens/result_screen.dart';

class QuizScreen extends ConsumerWidget {
  final QuizCategory category;

  const QuizScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizState = ref.watch(quizProvider);

    // Navigate to result when finished
    ref.listen<QuizState>(quizProvider, (_, next) {
      if (next.status == QuizStatus.finished) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              score: next.score,
              correctCount: next.correctCount,
              totalQuestions: next.questions.length,
              category: category,
            ),
          ),
        );
      }
    });

    final question = quizState.currentQuestion;
    if (question == null) return const SizedBox.shrink();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, quizState),
              const Gap(20),
              _buildProgressBar(quizState),
              const Gap(28),
              _buildQuestionCard(question, quizState),
              const Gap(20),
              _buildOptions(question, quizState, ref),
              if (quizState.status == QuizStatus.answered &&
                  question.explanation != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: _buildExplanationBox(question.explanation!),
                ),
              const Spacer(),
              _buildScoreDisplay(quizState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, QuizState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => _confirmExit(context),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.close_rounded, color: AppColors.white),
          ),
        ),
        Text(
          '${state.currentIndex + 1} / ${state.questions.length}',
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        TimerWidget(timeLeft: state.timeLeft),
      ],
    );
  }

  Widget _buildProgressBar(QuizState state) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: (state.currentIndex + 1) / state.questions.length,
        minHeight: 8,
        backgroundColor: AppColors.white.withOpacity(0.1),
        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
      ),
    );
  }

  Widget _buildQuestionCard(question, QuizState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              question.category.emoji + ' ' + question.category.label,
              style: const TextStyle(
                color: AppColors.secondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Gap(12),
          Text(
            question.text,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildOptions(question, QuizState state, WidgetRef ref) {
    return Column(
      children: List.generate(question.options.length, (i) {
        final optionState = _getOptionState(state, i, question.correctIndex);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: OptionButton(
            text: question.options[i],
            optionState: optionState,
            index: i,
            onTap: () => ref.read(quizProvider.notifier).selectAnswer(i),
          ).animate(delay: (i * 80).ms).fadeIn(duration: 300.ms).slideX(begin: 0.1, end: 0),
        );
      }),
    );
  }

  OptionState _getOptionState(QuizState state, int index, int correctIndex) {
    if (state.status == QuizStatus.running) return OptionState.idle;

    final selected = state.selectedOptionIndex;
    if (index == correctIndex) {
      return selected == correctIndex ? OptionState.correct : OptionState.missed;
    }
    if (index == selected && selected != correctIndex) return OptionState.wrong;
    return OptionState.idle;
  }

  Widget _buildExplanationBox(String explanation) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.correct.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.correct.withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.correct, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              explanation,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildScoreDisplay(QuizState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.star_rounded, color: AppColors.secondary, size: 20),
        const SizedBox(width: 6),
        Text(
          '${state.score} điểm',
          style: const TextStyle(
            color: AppColors.secondary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _confirmExit(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Bỏ cuộc?', style: TextStyle(color: AppColors.white)),
        content: const Text(
          'Điểm số sẽ không được lưu nếu bạn thoát giữa chừng.',
          style: TextStyle(color: AppColors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tiếp tục', style: TextStyle(color: AppColors.correct)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Thoát', style: TextStyle(color: AppColors.wrong)),
          ),
        ],
      ),
    );
  }
}
