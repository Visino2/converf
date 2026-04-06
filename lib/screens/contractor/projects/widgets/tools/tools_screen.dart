import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:converf/screens/contractor/projects/widgets/tools/contractor_profile_screen.dart';
import 'package:converf/screens/contractor/projects/widgets/tools/marketplace_screen.dart';
import 'package:converf/screens/contractor/projects/widgets/tools/contractor_account_settings_screen.dart';
import 'package:converf/screens/contractor/projects/widgets/tools/contractor_bidding_preferences_screen.dart';
import 'package:converf/screens/contractor/projects/widgets/tools/contractor_notifications_screen.dart';
import 'package:converf/screens/contractor/projects/widgets/tools/contractor_project_settings_screen.dart';
import 'package:converf/screens/contractor/projects/widgets/tools/contractor_help_support_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:converf/features/auth/providers/auth_provider.dart';
import 'package:converf/screens/widgets/logout_confirmation_modal.dart';

class ToolsScreen extends ConsumerWidget {
  const ToolsScreen({super.key});

  void _navigate(BuildContext context, String title) {
    switch (title) {
      case 'Account Setting':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ContractorAccountSettingsScreen(),
          ),
        );
        break;
      case 'Bidding Preferences':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ContractorBiddingPreferencesScreen(),
          ),
        );
        break;
      case 'Notifications':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ContractorNotificationsScreen(),
          ),
        );
        break;
      case 'Privacy & Visibility':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ContractorProjectSettingsScreen(),
          ),
        );
        break;
      case 'Help & Support':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ContractorHelpSupportScreen(),
          ),
        );
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Map<String, String>> menuItems = [
      {'title': 'Account Setting', 'icon': 'assets/images/more.svg'},
      {'title': 'Bidding Preferences', 'icon': 'assets/images/Shield.svg'},
      {'title': 'Notifications', 'icon': 'assets/images/Bell.svg'},
      {'title': 'Privacy & Visibility', 'icon': 'assets/images/Shield.svg'},
      {'title': 'Help & Support', 'icon': 'assets/images/headset.svg'},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: Text(
                  'Tools',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Profile Card (Clickable) ────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ContractorProfileScreen(),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFF0F2F5),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Top portion with Image and Camera Circle
                        Stack(
                          alignment: Alignment.bottomCenter,
                          clipBehavior: Clip.none,
                          children: [
                            // Top Image
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              child: SizedBox(
                                height: 140,
                                width: double.infinity,
                                child: Image.asset(
                                  'assets/images/lekki-complex.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) =>
                                      Container(color: const Color(0xFF309DAA)),
                                ),
                              ),
                            ),
                            // Camera / Upload Circle
                            Positioned(
                              bottom: -40,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFF3C08B),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/images/camera.svg',
                                    width: 24,
                                    height: 24,
                                    colorFilter: const ColorFilter.mode(
                                      Colors.white,
                                      BlendMode.srcIn,
                                    ),
                                    errorBuilder: (_, _, _) => const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 50),
                        // Profile Info
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Converf Construction Ltd',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.verified,
                                    color: Color(0xFF309DAA),
                                    size: 20,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'assets/images/map.svg',
                                    width: 14,
                                    height: 14,
                                    colorFilter: const ColorFilter.mode(
                                      Color(0xFF6B7280),
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Lagos, Nigeria',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  SvgPicture.asset(
                                    'assets/images/calendar-3.svg',
                                    width: 14,
                                    height: 14,
                                    colorFilter: const ColorFilter.mode(
                                      Color(0xFF6B7280),
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Member since Jan 2021',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Marketplace Banner ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MarketplaceScreen(),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: double.infinity,
                      height: 88,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF309DAA), Color(0xFF2A8090)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Cross pattern background
                          Positioned.fill(
                            child: CustomPaint(painter: _CrossPatternPainter()),
                          ),
                          // Decorative vector
                          Positioned(
                            bottom: -20,
                            right: -20,
                            child: Image.asset(
                              'assets/images/vector-2.png',
                              width: 260,
                              height: 140,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const SizedBox(),
                            ),
                          ),
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/images/store.svg',
                                  width: 60,
                                  height: 60,
                                  colorFilter: const ColorFilter.mode(
                                    Colors.white,
                                    BlendMode.srcIn,
                                  ),
                                  errorBuilder: (_, _, _) => const Icon(
                                    Icons.storefront,
                                    color: Colors.white,
                                    size: 60,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Market Place',
                                  style: TextStyle(
                                    color: Color(0xFFFFFFFF),
                                    fontSize: 24,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.48,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Account',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Menu items
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    ...menuItems.map((item) => _buildMenuItem(context, item)),
                    const SizedBox(height: 16),

                    // Logout button
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
                            SvgPicture.asset(
                              'assets/images/logout.svg',
                              width: 22,
                              height: 22,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
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
                    const SizedBox(height: 24),
                  ],
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
            child: SvgPicture.asset(
              item['icon']!,
              width: 22,
              height: 22,
              colorFilter: const ColorFilter.mode(
                Color(0xFF276572),
                BlendMode.srcIn,
              ),
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

class _CrossPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const spacing = 28.0;
    const crossSize = 8.0;

    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        canvas.drawLine(
          Offset(x - crossSize, y),
          Offset(x + crossSize, y),
          paint,
        );
        canvas.drawLine(
          Offset(x, y - crossSize),
          Offset(x, y + crossSize),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
