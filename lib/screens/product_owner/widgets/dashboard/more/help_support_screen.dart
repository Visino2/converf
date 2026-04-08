import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Help center',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            const Text(
              'Help Center',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Manage your professional Converf subscription plan',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 28),

            const Text(
              'Chat',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 17),
            _buildItem(
              icon: 'assets/images/chat.svg',
              title: 'Live Chat',
              subtitle: 'Start a conversation on live chat',
              arrowAsset: 'assets/images/right-arrow.svg',
              iconBg: const Color(0xFFE0F4F5),
              iconColor: const Color(0xFF2A8090),
              onTap: () => _launchUri(context, 'https://converf.com/support/chat'),
            ),
            const SizedBox(height: 17),
            _buildItem(
              icon: 'assets/images/chat.svg',
              title: 'Email',
              subtitle: 'We aim to respond in a day',
              arrowAsset: 'assets/images/right-arrow.svg',
              iconBg: const Color(0xFFE0F4F5),
              iconColor: const Color(0xFF2A8090),
              onTap: () => _launchUri(context, 'mailto:support@converf.com?subject=Converf%20Support'),
            ),
            const SizedBox(height: 28),

            const Text(
              'Social Media',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),
            _buildItem(
              icon: 'assets/images/twitter.svg',
              title: 'Twitter (X)',
              arrowAsset: 'assets/images/right-arrow.svg',
              onTap: () => _launchUri(context, 'https://twitter.com/converf'),
            ),
            const SizedBox(height: 12),
            _buildItem(
              icon: 'assets/images/instagram.svg',
              title: 'Instagram',
              arrowAsset: 'assets/images/right-arrow.svg',
              onTap: () => _launchUri(context, 'https://instagram.com/converf'),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2A8090),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Back to Settings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUri(BuildContext context, String value) async {
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri.tryParse(value);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!context.mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
    }
  }

  Widget _buildItem({
    required String icon,
    required String title,
    String? subtitle,
    required String arrowAsset,
    Color? iconBg,
    Color iconColor = Colors.black,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBg ?? Colors.transparent,
                shape: BoxShape.circle,
                border: (iconBg == null || iconBg == Colors.transparent)
                    ? Border.all(color: const Color(0xFFE5E7EB))
                    : null,
              ),
              child: Center(
                child: icon.endsWith('.svg')
                    ? SvgPicture.asset(
                        icon,
                        width: 22,
                        height: 22,
                        colorFilter: (iconBg == null || iconBg == Colors.transparent)
                            ? null
                            : ColorFilter.mode(iconColor, BlendMode.srcIn),
                        errorBuilder: (_, _, _) => Icon(
                          Icons.help_outline,
                          color: iconColor,
                          size: 20,
                        ),
                      )
                    : Image.asset(
                        icon,
                        width: 22,
                        height: 22,
                        color: (iconBg == null || iconBg == Colors.transparent) ? null : iconColor,
                        errorBuilder: (_, _, _) => Icon(
                          Icons.help_outline,
                          color: iconColor,
                          size: 20,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            arrowAsset.endsWith('.svg')
                ? SvgPicture.asset(
                    arrowAsset,
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(Color(0xFF9CA3AF), BlendMode.srcIn),
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF9CA3AF),
                      size: 22,
                    ),
                  )
                : Image.asset(
                    arrowAsset,
                    width: 20,
                    height: 20,
                    color: const Color(0xFF9CA3AF),
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF9CA3AF),
                      size: 22,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
