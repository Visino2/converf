import 'package:flutter/material.dart';

import 'widgets/dashboard/dashboard_content.dart';
import 'widgets/dashboard/projects_screen.dart';

class DashboardMainScreen extends StatefulWidget {
  const DashboardMainScreen({super.key});

  @override
  State<DashboardMainScreen> createState() => _DashboardMainScreenState();
}

class _DashboardMainScreenState extends State<DashboardMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardContent(),
    const ProjectsScreen(),
    const Center(child: Text('Team')),
    const Center(child: Text('More')),
  ];

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
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
              icon: Image.asset(
                'assets/images/home.png',
                width: 24,
                height: 24,
                color: Colors.black87,
              ),
              activeIcon: Image.asset(
                'assets/images/home.png',
                width: 24,
                height: 24,
                color: const Color(0xFF276572),
              ),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/projects.png',
                width: 24,
                height: 24,
                color: Colors.black87,
              ),
              activeIcon: Image.asset(
                'assets/images/projects.png',
                width: 24,
                height: 24,
                color: const Color(0xFF276572),
              ),
              label: 'Projects',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/team.png',
                width: 24,
                height: 24,
                color: Colors.black87,
              ),
              activeIcon: Image.asset(
                'assets/images/team.png',
                width: 24,
                height: 24,
                color: const Color(0xFF276572),
              ),
              label: 'Team',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/more.png',
                width: 24,
                height: 24,
                color: Colors.black87,
              ),
              activeIcon: Image.asset(
                'assets/images/more.png',
                width: 24,
                height: 24,
                color: const Color(0xFF276572),
              ),
              label: 'More',
            ),
          ],
        ),
      ),
    );
  }
}
