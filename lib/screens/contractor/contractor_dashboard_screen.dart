import 'package:flutter/material.dart';

import 'contractor_dashboard_content.dart';
import 'projects/contractor_projects_screen.dart';
import 'projects/widgets/tools/marketplace_screen.dart';
import 'projects/widgets/tools/tools_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/models/email_verification_status.dart';
import '../../features/auth/providers/email_verification_provider.dart';

class ContractorDashboardScreen extends ConsumerStatefulWidget {
  const ContractorDashboardScreen({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  ConsumerState<ContractorDashboardScreen> createState() =>
      _ContractorDashboardScreenState();
}

class _ContractorDashboardScreenState
    extends ConsumerState<ContractorDashboardScreen> {
  late int _selectedIndex;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _pages = [
      ContractorDashboardContent(onNavigateToProjects: () => _onItemTapped(1)),
      const ContractorProjectsScreen(),
      const MarketplaceScreen(showBackButton: false),
      const ToolsScreen(),
    ];
  }

  @override
  void didUpdateWidget(covariant ContractorDashboardScreen oldWidget) {
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
                'assets/images/store.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Colors.black87,
                  BlendMode.srcIn,
                ),
              ),
              activeIcon: SvgPicture.asset(
                'assets/images/store.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF276572),
                  BlendMode.srcIn,
                ),
              ),
              label: 'Marketplace',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/images/case-1.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Colors.black87,
                  BlendMode.srcIn,
                ),
              ),
              activeIcon: SvgPicture.asset(
                'assets/images/case-1.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF276572),
                  BlendMode.srcIn,
                ),
              ),
              label: 'Tools',
            ),
          ],
        ),
      ),
    );
  }
}
