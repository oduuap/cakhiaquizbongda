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
  @override
  void initState() {
    super.initState();
    _initAndNavigate();
  }

  Future<void> _initAndNavigate() async {
    final config = RemoteConfigService.instance;

    await Future.delayed(Duration(milliseconds: config.splashMinWaitMs));

    if (!mounted) return;

    if (config.maintenanceMode) {
      await _openMaintenanceUrl(config.maintenanceUrl);
      return;
    }

    _goHome();
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
            _buildLoadingDots(),
            const Gap(48),
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
}
