import 'package:flutter/material.dart';

import 'product_owner_dashboard_content.dart';
import 'widgets/dashboard/projects/projects_screen.dart';
import 'widgets/dashboard/team/team_screen.dart';
import 'widgets/dashboard/more/more_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProductOwnerDashboardScreen extends StatefulWidget {
  const ProductOwnerDashboardScreen({super.key});

  @override
  State<ProductOwnerDashboardScreen> createState() => _ProductOwnerDashboardScreenState();
}

class _ProductOwnerDashboardScreenState extends State<ProductOwnerDashboardScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const ProductOwnerDashboardContent(),
      const ProjectsScreen(),
      TeamScreen(
        onNavigateToProjects: () {
          _onItemTapped(1); 
        },
      ),
      const MoreScreen(),
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
              icon: SvgPicture.asset('assets/images/team.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(Colors.black87, BlendMode.srcIn),
              ),
              activeIcon: SvgPicture.asset('assets/images/team.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(Color(0xFF276572), BlendMode.srcIn),
              ),
              label: 'Team',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/images/more.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(Colors.black87, BlendMode.srcIn),
              ),
              activeIcon: SvgPicture.asset('assets/images/more.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(Color(0xFF276572), BlendMode.srcIn),
              ),
              label: 'More',
            ),
          ],
        ),
      ),
    );
  }
}
