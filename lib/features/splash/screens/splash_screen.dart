import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ca_khia_fc/core/services/remote_config_service.dart';
import 'package:ca_khia_fc/core/theme/app_theme.dart';
import 'package:ca_khia_fc/features/home/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _configLoaded = false;
  bool _showPanel = false;
  List<FlagInfo> _flags = [];

  @override
  void initState() {
    super.initState();
    _initAndNavigate();
  }

  Future<void> _initAndNavigate() async {
    final config = RemoteConfigService.instance;

    // Respect minimum splash wait
    await Future.delayed(Duration(milliseconds: config.splashMinWaitMs));

    if (!mounted) return;

    setState(() {
      _configLoaded = true;
      _flags = config.allFlags();
      _showPanel = config.showFlagPanel;
    });

    // Maintenance mode ON → open URL instead of entering game
    if (config.maintenanceMode) {
      await _openMaintenanceUrl(config.maintenanceUrl);
      return;
    }

    // Debug panel OFF → go straight to game
    if (!_showPanel) {
      _goHome();
    }
    // Debug panel ON → wait for user to tap "Vào app"
  }

  Future<void> _openMaintenanceUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _goHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            _buildLogo(),
            const Spacer(),
            if (_configLoaded && _showPanel) ...[
              _buildFlagPanel(),
              const Gap(20),
              _buildEnterButton(),
              const Gap(32),
            ] else ...[
              _buildLoadingDots(),
              const Gap(48),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Image.asset(
          'assets/images/icon_master.png',
          width: 100,
          height: 100,
        )
            .animate()
            .fadeIn(duration: 600.ms)
            .scale(
              begin: const Offset(0.7, 0.7),
              end: const Offset(1, 1),
              curve: Curves.elasticOut,
              duration: 700.ms,
            ),
        const Gap(20),
        const Text(
          'Ca Khía FC',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
        const Gap(6),
        const Text(
          'Quiz Bóng Đá Việt Nam',
          style: TextStyle(color: AppColors.grey, fontSize: 14),
        ).animate().fadeIn(delay: 500.ms, duration: 500.ms),
      ],
    );
  }

  Widget _buildLoadingDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.secondary,
            shape: BoxShape.circle,
          ),
        )
            .animate(onPlay: (c) => c.repeat())
            .fadeIn(delay: (i * 200).ms, duration: 400.ms)
            .then()
            .fadeOut(duration: 400.ms);
      }),
    );
  }

  Widget _buildFlagPanel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.tune_rounded, color: AppColors.secondary, size: 18),
              const Gap(8),
              const Text(
                'Feature Flags',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.correct.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Firebase Remote Config',
                  style: TextStyle(
                    color: AppColors.correct,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Gap(14),
          ..._flags.map((f) => _buildFlagRow(f)),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildFlagRow(FlagInfo flag) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: flag.enabled ? AppColors.correct : AppColors.grey,
            ),
          ),
          const Gap(10),
          Expanded(
            child: Text(
              flag.label,
              style: const TextStyle(color: AppColors.white, fontSize: 13),
            ),
          ),
          Text(
            flag.value,
            style: TextStyle(
              color: flag.enabled ? AppColors.correct : AppColors.grey,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnterButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _goHome,
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('Vào game'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }
}
