import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ca_khia_fc/core/theme/app_theme.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() => _version = '${info.version} (${info.buildNumber})');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Về ứng dụng'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildAppInfo(),
          const Gap(24),
          _buildSection(
            'Chính sách bảo mật',
            Icons.privacy_tip_rounded,
            AppColors.secondary,
            child: _buildPrivacyPolicy(),
          ),
          const Gap(16),
          _buildSection(
            'Điều khoản sử dụng',
            Icons.article_rounded,
            AppColors.correct,
            child: _buildTerms(),
          ),
          const Gap(16),
          _buildSection(
            'Liên hệ',
            Icons.email_rounded,
            AppColors.primary,
            child: _buildContact(),
          ),
          const Gap(32),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildAppInfo() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE63946), Color(0xFFFF6B35)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text('⚽', style: TextStyle(fontSize: 56)),
          const Gap(8),
          const Text(
            'Ca Khía FC',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(4),
          const Text(
            'Quiz Bóng Đá Việt Nam',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          if (_version.isNotEmpty) ...[
            const Gap(8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Phiên bản $_version',
                style: const TextStyle(color: AppColors.white, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildSection(
    String title,
    IconData icon,
    Color color, {
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(icon, color: color, size: 22),
          title: Text(
            title,
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          iconColor: AppColors.grey,
          collapsedIconColor: AppColors.grey,
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [child],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildPrivacyPolicy() {
    const sections = [
      _PolicySection(
        title: '1. Thông tin chúng tôi thu thập',
        body:
            'Ứng dụng Ca Khía FC KHÔNG thu thập bất kỳ thông tin cá nhân nào. '
            'Tất cả dữ liệu (điểm số, lịch sử chơi) chỉ được lưu trữ cục bộ '
            'trên thiết bị của bạn và không được gửi đến bất kỳ máy chủ nào.',
      ),
      _PolicySection(
        title: '2. Dữ liệu lưu trữ cục bộ',
        body:
            'Chúng tôi lưu trữ các thông tin sau trên thiết bị của bạn:\n'
            '• Điểm số cao nhất\n'
            '• Số trận đã chơi\n'
            '• Lịch sử 20 trận gần nhất\n\n'
            'Bạn có thể xóa toàn bộ dữ liệu bằng cách gỡ cài đặt ứng dụng.',
      ),
      _PolicySection(
        title: '3. Quyền truy cập',
        body:
            'Ứng dụng không yêu cầu bất kỳ quyền đặc biệt nào (camera, vị trí, '
            'danh bạ, v.v.). Ứng dụng hoạt động hoàn toàn offline.',
      ),
      _PolicySection(
        title: '4. Chia sẻ dữ liệu',
        body:
            'Chúng tôi không chia sẻ, bán hoặc chuyển giao bất kỳ thông tin nào '
            'của người dùng cho bên thứ ba.',
      ),
      _PolicySection(
        title: '5. Trẻ em',
        body:
            'Ứng dụng phù hợp cho mọi lứa tuổi. Chúng tôi không thu thập '
            'thông tin từ trẻ em dưới 13 tuổi.',
      ),
      _PolicySection(
        title: '6. Thay đổi chính sách',
        body:
            'Nếu có thay đổi về chính sách bảo mật, chúng tôi sẽ thông báo '
            'qua cập nhật ứng dụng. Chính sách cập nhật lần cuối: 01/01/2025.',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections
          .map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.title,
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    s.body,
                    style: const TextStyle(
                      color: AppColors.grey,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildTerms() {
    return const Text(
      'Bằng cách sử dụng Ca Khía FC, bạn đồng ý với các điều khoản sau:\n\n'
      '• Ứng dụng chỉ dành cho mục đích giải trí.\n'
      '• Nội dung câu hỏi được biên soạn theo thông tin công khai về bóng đá.\n'
      '• Chúng tôi không chịu trách nhiệm về tính chính xác tuyệt đối '
      'của từng câu hỏi. Nếu phát hiện sai sót, vui lòng liên hệ để chúng tôi chỉnh sửa.\n'
      '• Nghiêm cấm sao chép, phân phối lại nội dung của ứng dụng khi chưa '
      'được sự đồng ý bằng văn bản.',
      style: TextStyle(color: AppColors.grey, fontSize: 13, height: 1.5),
    );
  }

  Widget _buildContact() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Có câu hỏi hoặc góp ý? Liên hệ với chúng tôi:',
          style: TextStyle(color: AppColors.grey, fontSize: 13, height: 1.5),
        ),
        const Gap(8),
        _contactRow(Icons.email_outlined, 'support@cakhiafc.app'),
        const Gap(4),
        _contactRow(Icons.language_outlined, 'Việt Nam 🇻🇳'),
      ],
    );
  }

  Widget _contactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.grey, size: 16),
        const Gap(8),
        Text(text, style: const TextStyle(color: AppColors.grey, fontSize: 13)),
      ],
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Text(
        '© 2025 Ca Khía FC. All rights reserved.\nMade with ❤️ in Việt Nam',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.grey.withValues(alpha: 0.6),
          fontSize: 12,
          height: 1.6,
        ),
      ),
    );
  }
}

class _PolicySection {
  final String title;
  final String body;
  const _PolicySection({required this.title, required this.body});
}
