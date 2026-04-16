import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ca_khia_fc/core/theme/app_theme.dart';

enum OptionState { idle, correct, wrong, missed }

class OptionButton extends StatelessWidget {
  final String text;
  final OptionState optionState;
  final VoidCallback? onTap;
  final int index;

  const OptionButton({
    super.key,
    required this.text,
    required this.optionState,
    required this.index,
    this.onTap,
  });

  Color get _bgColor => switch (optionState) {
        OptionState.correct => AppColors.correct,
        OptionState.wrong => AppColors.wrong,
        OptionState.missed => AppColors.correct.withOpacity(0.6),
        OptionState.idle => AppColors.cardBg,
      };

  IconData? get _icon => switch (optionState) {
        OptionState.correct => Icons.check_circle_rounded,
        OptionState.wrong => Icons.cancel_rounded,
        OptionState.missed => Icons.check_circle_outline_rounded,
        OptionState.idle => null,
      };

  @override
  Widget build(BuildContext context) {
    final labels = ['A', 'B', 'C', 'D'];

    return GestureDetector(
      onTap: optionState == OptionState.idle ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: optionState == OptionState.idle
                ? AppColors.white.withOpacity(0.1)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                labels[index],
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (_icon != null)
              Icon(_icon, color: AppColors.white, size: 22),
          ],
        ),
      ).animate(target: optionState != OptionState.idle ? 1 : 0).shake(
            duration: optionState == OptionState.wrong ? 400.ms : 0.ms,
          ),
    );
  }
}
