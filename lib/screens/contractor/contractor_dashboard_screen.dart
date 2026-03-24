import 'package:flutter/material.dart';

import 'contractor_dashboard_content.dart';
import 'projects/contractor_projects_screen.dart';
import 'contractor_milestone_screen.dart';
import 'projects/widgets/tools/tools_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ContractorDashboardScreen extends StatefulWidget {
  const ContractorDashboardScreen({super.key});

  @override
  State<ContractorDashboardScreen> createState() => _ContractorDashboardScreenState();
}

class _ContractorDashboardScreenState extends State<ContractorDashboardScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      ContractorDashboardContent(
        onNavigateToProjects: () => _onItemTapped(1),
      ),
      const ContractorProjectsScreen(),
      const ContractorMilestoneScreen(),
      const ToolsScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF9FAFB,
      ), // App background color from design
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
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
              icon: SvgPicture.asset('assets/images/home.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(Colors.black87, BlendMode.srcIn),
              ),
              activeIcon: SvgPicture.asset('assets/images/home.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(Color(0xFF276572), BlendMode.srcIn),
              ),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/images/projects.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(Colors.black87, BlendMode.srcIn),
              ),
              activeIcon: SvgPicture.asset('assets/images/projects.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(Color(0xFF276572), BlendMode.srcIn),
              ),
              label: 'Projects',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/images/target-1.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(Colors.black87, BlendMode.srcIn),
              ),
              activeIcon: SvgPicture.asset('assets/images/target-1.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(Color(0xFF276572), BlendMode.srcIn),
              ),
              label: 'Milestone',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/images/case-1.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(Colors.black87, BlendMode.srcIn),
              ),
              activeIcon: SvgPicture.asset('assets/images/case-1.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(Color(0xFF276572), BlendMode.srcIn),
              ),
              label: 'Tools',
            ),
          ],
        ),
      ),
    );
  }
}
