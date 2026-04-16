import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ca_khia_fc/core/theme/app_theme.dart';
import 'package:ca_khia_fc/features/settings/screens/about_screen.dart';

const _kConsentKey = 'privacy_consent_accepted';

Future<bool> hasAcceptedConsent() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_kConsentKey) ?? false;
}

Future<void> saveConsent() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_kConsentKey, true);
}

/// Shows the consent dialog on first launch.
/// Returns true if the user accepted, false if they declined.
Future<bool> showConsentDialogIfNeeded(BuildContext context) async {
  final accepted = await hasAcceptedConsent();
  if (accepted) return true;
  if (!context.mounted) return false;

  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _ConsentDialog(),
  );

  return result ?? false;
}

class _ConsentDialog extends StatefulWidget {
  const _ConsentDialog();

  @override
  State<_ConsentDialog> createState() => _ConsentDialogState();
}

class _ConsentDialogState extends State<_ConsentDialog> {
  bool _agreed = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Column(
        children: [
          Text('⚽', style: TextStyle(fontSize: 40)),
          Gap(8),
          Text(
            'Chào mừng đến Ca Khía FC!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '📋 Trước khi bắt đầu, hãy đọc qua:\n\n'
                '• Ứng dụng lưu điểm số và lịch sử chơi trên thiết bị của bạn.\n'
                '• Chúng tôi KHÔNG thu thập thông tin cá nhân.\n'
                '• Ứng dụng hoạt động hoàn toàn offline.',
                style: TextStyle(
                  color: AppColors.grey,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
            const Gap(12),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              ),
              child: const Text(
                'Xem Chính sách bảo mật đầy đủ →',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 13,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.secondary,
                ),
              ),
            ),
            const Gap(16),
            GestureDetector(
              onTap: () => setState(() => _agreed = !_agreed),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: _agreed ? AppColors.correct : Colors.transparent,
                      border: Border.all(
                        color: _agreed ? AppColors.correct : AppColors.grey,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: _agreed
                        ? const Icon(Icons.check, color: Colors.white, size: 14)
                        : null,
                  ),
                  const Gap(10),
                  const Expanded(
                    child: Text(
                      'Tôi đã đọc và đồng ý với Chính sách bảo mật và Điều khoản sử dụng',
                      style: TextStyle(color: AppColors.white, fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _agreed
                ? () async {
                    await saveConsent();
                    if (context.mounted) Navigator.pop(context, true);
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _agreed ? AppColors.primary : AppColors.cardBg,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Bắt đầu chơi 🔥',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
