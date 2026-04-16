import 'package:flutter/material.dart';
import 'package:ca_khia_fc/core/constants/app_constants.dart';
import 'package:ca_khia_fc/core/theme/app_theme.dart';

class TimerWidget extends StatelessWidget {
  final int timeLeft;

  const TimerWidget({super.key, required this.timeLeft});

  Color get _color {
    final ratio = timeLeft / AppConstants.secondsPerQuestion;
    if (ratio > 0.6) return AppColors.correct;
    if (ratio > 0.3) return AppColors.secondary;
    return AppColors.wrong;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: timeLeft / AppConstants.secondsPerQuestion,
            strokeWidth: 5,
            backgroundColor: AppColors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(_color),
          ),
          Text(
            '$timeLeft',
            style: TextStyle(
              color: _color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
