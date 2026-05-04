import 'package:flutter/material.dart';

import 'package:converf/screens/product_owner/widgets/dashboard/more/profile_information_screen.dart';
import 'package:converf/screens/product_owner/widgets/dashboard/more/security_screen.dart';
import 'package:converf/screens/product_owner/widgets/dashboard/notifications/notifications_screen.dart';
import 'package:converf/screens/product_owner/widgets/dashboard/more/billing/billing_screen.dart';
import 'package:converf/screens/product_owner/widgets/dashboard/more/help_support_screen.dart';
import 'package:converf/screens/product_owner/widgets/dashboard/more/privacy_settings_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:converf/screens/widgets/logout_confirmation_modal.dart';
import 'package:converf/features/auth/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:converf/screens/settings/delete_account_screen.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  void _navigate(BuildContext context, String title) {
    switch (title) {
      case 'Profile Information':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ProfileInformationScreen()));
        break;
      case 'Security':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SecurityScreen()));
        break;
      case 'Notifications':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const NotificationsScreen()));
        break;
      case 'Subscription':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const BillingScreen()));
        break;
      case 'Help & Support':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const HelpSupportScreen()));
        break;
      case 'Delete Account':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const DeleteAccountScreen()));
        break;
      case 'Privacy Settings':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const PrivacySettingsScreen()));
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Map<String, String>> menuItems = [
      {'title': 'Profile Information', 'icon': 'assets/images/more.svg'},
      {'title': 'Security', 'icon': 'assets/images/Shield.svg'},
      {'title': 'Notifications', 'icon': 'assets/images/Bell.svg'},
      {'title': 'Privacy Settings', 'icon': 'assets/images/Shield.svg'},
      {'title': 'Subscription', 'icon': 'assets/images/card.png'},
      {'title': 'Help & Support', 'icon': 'assets/images/headset.svg'},
      {'title': 'Delete Account', 'icon': 'assets/images/Shield.svg'},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Settings',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Menu Items
              ...menuItems.map((item) => _buildMenuItem(context, item)),

              const SizedBox(height: 16),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    showLogoutConfirmation(
                      context,
                      onConfirm: () {
                        ref.read(authProvider.notifier).logout();
                        // Redirection is handled by AppRouter
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      SvgPicture.asset('assets/images/logout.svg',
                        width: 22,
                        height: 22,
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.logout,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, Map<String, String> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Color(0xFFB7E7EA),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: item['icon']!.endsWith('.svg')
                ? SvgPicture.asset(
                    item['icon']!,
                    width: 22,
                    height: 22,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF276572),
                      BlendMode.srcIn,
                    ),
                  )
                : Image.asset(
                    item['icon']!,
                    width: 22,
                    height: 22,
                    color: const Color(0xFF276572),
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.settings,
                      color: Color(0xFF276572),
                      size: 22,
                    ),
                  ),
          ),
        ),
        title: Text(
          item['title']!,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF111827),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Color(0xFF9CA3AF),
          size: 24,
        ),
        onTap: () => _navigate(context, item['title']!),
      ),
    );
  }
}
