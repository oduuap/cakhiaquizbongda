import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ca_khia_fc/core/constants/app_constants.dart';
import 'package:ca_khia_fc/core/services/analytics_service.dart';
import 'package:ca_khia_fc/core/theme/app_theme.dart';
import 'package:ca_khia_fc/data/models/question.dart';
import 'package:ca_khia_fc/data/repositories/score_repository.dart';
import 'package:ca_khia_fc/features/quiz/providers/quiz_provider.dart';

final scoreRepoProvider = FutureProvider<ScoreRepository>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return ScoreRepository(prefs);
});

class ResultScreen extends ConsumerStatefulWidget {
  final int score;
  final int correctCount;
  final int totalQuestions;
  final QuizCategory category;

  const ResultScreen({
    super.key,
    required this.score,
    required this.correctCount,
    required this.totalQuestions,
    required this.category,
  });

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  @override
  void initState() {
    super.initState();
    _saveScore();
  }

  Future<void> _saveScore() async {
    final prefs = await SharedPreferences.getInstance();
    final repo = ScoreRepository(prefs);
    await repo.saveScore(GameScore(
      score: widget.score,
      correctCount: widget.correctCount,
      totalQuestions: widget.totalQuestions,
      playedAt: DateTime.now(),
      category: widget.category.label,
    ));
    AnalyticsService.instance.logQuizComplete(
      category: widget.category.label,
      score: widget.score,
      correctCount: widget.correctCount,
      totalQuestions: widget.totalQuestions,
    );
  }

  String get _rankEmoji {
    final ratio = widget.correctCount / widget.totalQuestions;
    if (ratio >= 0.9) return '👑';
    if (ratio >= 0.7) return '🔥';
    if (ratio >= 0.5) return '😎';
    return '🐣';
  }

  String get _rankTitle {
    final ratio = widget.correctCount / widget.totalQuestions;
    if (ratio >= 0.9) return 'Vua Ca Khía!';
    if (ratio >= 0.7) return 'Cao Thủ!';
    if (ratio >= 0.5) return 'Dân Chơi!';
    return 'Tân Binh!';
  }

  String get _rankComment {
    final ratio = widget.correctCount / widget.totalQuestions;
    if (ratio >= 0.9) return 'Xuất sắc! Bạn biết tất cả về bóng đá Việt Nam 🎉';
    if (ratio >= 0.7) return 'Không tệ! Chút nữa là Vua Ca Khía rồi 💪';
    if (ratio >= 0.5) return 'Ổn đấy, nhưng cần cày thêm đấy nhé 😄';
    return 'Còn nhiều điều cần học hỏi, cố lên! 📚';
  }

  void _shareResult() {
    final text =
        'Tôi vừa đạt ${widget.score} điểm trong Ca Khía FC Quiz!\n'
        'Trả lời đúng ${widget.correctCount}/${widget.totalQuestions} câu.\n'
        'Danh hiệu: $_rankTitle $_rankEmoji\n'
        'Bạn có thể làm tốt hơn không? 🔥';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã copy kết quả! Dán vào Facebook/Zalo để khoe nhé 😎'),
        backgroundColor: AppColors.correct,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              _buildRankBadge(),
              const Gap(24),
              _buildScoreCard(),
              const Gap(32),
              _buildActions(),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRankBadge() {
    return Column(
      children: [
        Text(
          _rankEmoji,
          style: const TextStyle(fontSize: 80),
        ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
        const Gap(12),
        Text(
          _rankTitle,
          style: const TextStyle(
            color: AppColors.secondary,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(delay: 300.ms),
        const Gap(8),
        Text(
          _rankComment,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.grey,
            fontSize: 15,
            height: 1.4,
          ),
        ).animate().fadeIn(delay: 500.ms),
      ],
    );
  }

  Widget _buildScoreCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat('${widget.score}', 'ĐIỂM SỐ', AppColors.secondary),
          _divider(),
          _buildStat('${widget.correctCount}/${widget.totalQuestions}', 'ĐÚNG', AppColors.correct),
          _divider(),
          _buildStat(
            '${(widget.correctCount / widget.totalQuestions * 100).round()}%',
            'CHÍNH XÁC',
            AppColors.primary,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildStat(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap(4),
        Text(
          label,
          style: const TextStyle(color: AppColors.grey, fontSize: 11),
        ),
      ],
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 40,
        color: AppColors.white.withOpacity(0.1),
      );

  Widget _buildActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              ref.read(quizProvider.notifier).startGame(widget.category);
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.replay_rounded),
            label: const Text('Chơi lại'),
          ),
        ),
        const Gap(12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _shareResult,
            icon: const Icon(Icons.share_rounded, color: AppColors.secondary),
            label: const Text(
              'Chia sẻ kết quả',
              style: TextStyle(color: AppColors.secondary),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.secondary),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const Gap(12),
        TextButton(
          onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
          child: const Text(
            'Về trang chủ',
            style: TextStyle(color: AppColors.grey),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 600.ms);
  }
}
