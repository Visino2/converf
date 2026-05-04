import 'package:flutter/material.dart';

import 'product_owner_dashboard_content.dart';
import 'widgets/dashboard/projects/projects_screen.dart';
import 'widgets/dashboard/team/team_screen.dart';
import 'widgets/dashboard/team/add_team_modal.dart';
import 'widgets/dashboard/more/more_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/models/email_verification_status.dart';
import '../../features/auth/providers/email_verification_provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../core/auth/session_manager.dart';

class ProductOwnerDashboardScreen extends ConsumerStatefulWidget {
  const ProductOwnerDashboardScreen({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  ConsumerState<ProductOwnerDashboardScreen> createState() =>
      _ProductOwnerDashboardScreenState();
}

class _ProductOwnerDashboardScreenState
    extends ConsumerState<ProductOwnerDashboardScreen> {
  late int _selectedIndex;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _pages = [
      ProductOwnerDashboardContent(
        onNavigateToProjects: () => _onItemTapped(1),
      ),
      const ProjectsScreen(),
      TeamScreen(
        onNavigateToProjects: () {
          _onItemTapped(1);
        },
      ),
      const MoreScreen(),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userId =
          ref.read(authProvider).value?.data?.user['id']?.toString() ?? '';
      final sessionManager = ref.read(sessionManagerProvider);
      if (sessionManager.isNewSignupSync(userId)) {
        await sessionManager.clearNewSignup(userId);
        if (mounted) _showNewUserWelcomePopup();
      }
    });
  }

  void _showNewUserWelcomePopup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NewUserWelcomeSheet(
        onInviteTeam: () {
          Navigator.of(context).pop();
          _onItemTapped(2);
        },
        onSkip: () => Navigator.of(context).pop(),
        onOpenInviteModal: () {
          Navigator.of(context).pop();
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => AddTeamModal(onNavigateToProjects: () {}),
          );
        },
      ),
    );
  }

  @override
  void didUpdateWidget(covariant ProductOwnerDashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex &&
        _selectedIndex != widget.initialIndex) {
      _selectedIndex = widget.initialIndex;
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final verificationState = ref.watch(emailVerificationStatusProvider);
    final verificationStatus =
        verificationState.asData?.value ?? EmailVerificationStatus.unknown;

    if (verificationState.isLoading ||
        verificationStatus == EmailVerificationStatus.unverified) {
      return const Scaffold(
        backgroundColor: Color(0xFFF9FAFB),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF276572)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(
        0xFFF9FAFB,
      ), // App background color from design
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF276572),
          unselectedItemColor: Colors.black87,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/images/home.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Colors.black87,
                  BlendMode.srcIn,
                ),
              ),
              activeIcon: SvgPicture.asset(
                'assets/images/home.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF276572),
                  BlendMode.srcIn,
                ),
              ),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/images/projects.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Colors.black87,
                  BlendMode.srcIn,
                ),
              ),
              activeIcon: SvgPicture.asset(
                'assets/images/projects.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF276572),
                  BlendMode.srcIn,
                ),
              ),
              label: 'Projects',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/images/team.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Colors.black87,
                  BlendMode.srcIn,
                ),
              ),
              activeIcon: SvgPicture.asset(
                'assets/images/team.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF276572),
                  BlendMode.srcIn,
                ),
              ),
              label: 'Team',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/images/more.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Colors.black87,
                  BlendMode.srcIn,
                ),
              ),
              activeIcon: SvgPicture.asset(
                'assets/images/more.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF276572),
                  BlendMode.srcIn,
                ),
              ),
              label: 'More',
            ),
          ],
        ),
      ),
    );
  }
}

class _NewUserWelcomeSheet extends StatelessWidget {
  final VoidCallback onInviteTeam;
  final VoidCallback onSkip;
  final VoidCallback onOpenInviteModal;

  const _NewUserWelcomeSheet({
    required this.onInviteTeam,
    required this.onSkip,
    required this.onOpenInviteModal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFE7F6EC),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.celebration_rounded, color: Color(0xFF276572), size: 36),
          ),
          const SizedBox(height: 16),
          const Text(
            'Welcome to Converf!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
              letterSpacing: -0.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Your account is ready. Would you like to invite\nteam members to collaborate on your projects?',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: onOpenInviteModal,
              icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 20),
              label: const Text(
                'Invite Team Members',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF276572),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: TextButton(
              onPressed: onSkip,
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: Text(
                'Skip for Now',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.grey.shade600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
