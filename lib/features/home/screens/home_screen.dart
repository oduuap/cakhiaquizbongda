import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ca_khia_fc/core/constants/app_constants.dart';
import 'package:ca_khia_fc/core/theme/app_theme.dart';
import 'package:ca_khia_fc/data/models/question.dart';
import 'package:ca_khia_fc/data/repositories/score_repository.dart';
import 'package:ca_khia_fc/features/leaderboard/screens/leaderboard_screen.dart';
import 'package:ca_khia_fc/features/quiz/providers/quiz_provider.dart';
import 'package:ca_khia_fc/features/quiz/screens/quiz_screen.dart';
import 'package:ca_khia_fc/features/settings/screens/about_screen.dart';
import 'package:ca_khia_fc/features/settings/widgets/consent_dialog.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _highScore = 0;
  int _totalGames = 0;
  int _streak = 0;
  double _accuracy = 0;
  GameScore? _lastGame;

  @override
  void initState() {
    super.initState();
    _loadStats();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkConsent());
  }

  Future<void> _checkConsent() async {
    if (!mounted) return;
    final accepted = await showConsentDialogIfNeeded(context);
    if (!accepted && mounted) {
      // User declined — exit app or keep showing dialog
      _checkConsent();
    }
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final repo = ScoreRepository(prefs);
    setState(() {
      _highScore = repo.getHighScore();
      _totalGames = repo.getTotalGames();
      _streak = repo.getStreak();
      _accuracy = repo.getOverallAccuracy();
      _lastGame = repo.getLastGame();
    });
  }

  void _startQuiz(QuizCategory category) {
    ref.read(quizProvider.notifier).startGame(category);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => QuizScreen(category: category)),
    ).then((_) => _loadStats());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(),
              const Gap(24),
              _buildHeroBanner(),
              const Gap(24),
              _buildStatsRow(),
              const Gap(12),
              _buildStatsRow2(),
              if (_lastGame != null) ...[
                const Gap(16),
                _buildLastGameCard(_lastGame!),
              ],
              const Gap(28),
              _buildCategoryTitle(),
              const Gap(16),
              _buildCategories(),
              const Gap(28),
              _buildQuickPlayButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Gôn! Quiz ⚽',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Quiz Bóng Đá Việt Nam',
              style: TextStyle(color: AppColors.grey, fontSize: 13),
            ),
          ],
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
              ).then((_) => _loadStats()),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.history_rounded, color: AppColors.secondary),
              ),
            ),
            const Gap(8),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              ),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.info_outline_rounded, color: AppColors.grey),
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE63946), Color(0xFFFF6B35)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🔥 Gôn! Quiz\nThách Thức!',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const Gap(8),
          const Text(
            'Bạn có đủ trình không?\nThử ngay 10 câu hỏi bóng đá!',
            style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
          ),
          const Gap(16),
          GestureDetector(
            onTap: () => _startQuiz(QuizCategory.vLeague),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Bắt đầu ngay →',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard('⭐ Điểm cao', '$_highScore', AppColors.secondary),
        ),
        const Gap(12),
        Expanded(
          child: _buildStatCard('🎮 Số trận', '$_totalGames', AppColors.correct),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildStatsRow2() {
    final accuracyStr = _totalGames == 0
        ? '--'
        : '${(_accuracy * 100).toStringAsFixed(0)}%';
    final streakStr = _streak == 0 ? '0' : '$_streak ngày';

    return Row(
      children: [
        Expanded(
          child: _buildStatCard('🎯 Tỷ lệ đúng', accuracyStr, const Color(0xFF00BCD4)),
        ),
        const Gap(12),
        Expanded(
          child: _buildStatCard('🔥 Chuỗi ngày', streakStr, const Color(0xFFFF5722)),
        ),
      ],
    ).animate().fadeIn(delay: 250.ms);
  }

  Widget _buildLastGameCard(GameScore game) {
    final pct = game.totalQuestions == 0
        ? 0
        : (game.correctCount * 100 ~/ game.totalQuestions);
    final isGood = pct >= 70;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isGood ? AppColors.correct : AppColors.wrong).withOpacity(0.4),
        ),
      ),
      child: Row(
        children: [
          Text(
            isGood ? '🏆' : '💪',
            style: const TextStyle(fontSize: 28),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Trận gần nhất',
                  style: TextStyle(color: AppColors.grey, fontSize: 11),
                ),
                const Gap(2),
                Text(
                  '${game.correctCount}/${game.totalQuestions} câu đúng  •  ${game.score} điểm',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$pct%',
            style: TextStyle(
              color: isGood ? AppColors.correct : AppColors.wrong,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
          const Gap(4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTitle() {
    return const Text(
      'Chọn chủ đề',
      style: TextStyle(
        color: AppColors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildCategories() {
    final categories = QuizCategory.values;
    final colors = [
      const Color(0xFF6C63FF),
      const Color(0xFF00BCD4),
      const Color(0xFF4CAF50),
      const Color(0xFFFF5722),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: categories.length,
      itemBuilder: (_, i) {
        final cat = categories[i];
        return GestureDetector(
          onTap: () => _startQuiz(cat),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors[i].withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors[i].withOpacity(0.3), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(cat.emoji, style: const TextStyle(fontSize: 28)),
                Text(
                  cat.label,
                  style: TextStyle(
                    color: colors[i],
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ).animate(delay: (i * 80).ms).fadeIn().slideY(begin: 0.1, end: 0);
      },
    );
  }

  Widget _buildQuickPlayButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _startQuiz(
          QuizCategory.values[DateTime.now().second % QuizCategory.values.length],
        ),
        icon: const Icon(Icons.bolt_rounded),
        label: const Text('Quick Play - Trộn hết!'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    ).animate().fadeIn(delay: 500.ms);
  }
}
