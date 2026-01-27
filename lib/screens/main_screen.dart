import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'statistics_screen.dart';
import '../core/app_theme.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const StatisticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          backgroundColor: AppTheme.backgroundColor,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: Colors.white.withValues(alpha: 0.5),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart_rounded),
              label: 'Statistics',
            ),
          ],
        ),
      ),
    );
  }
}
