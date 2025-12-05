import 'package:flutter/material.dart';
import 'rt_dashboard_screen.dart';
import 'rt_warga_list_screen.dart';
import 'rt_approval_screen.dart';
import 'rt_profil_screen.dart';

class RtMainScreen extends StatefulWidget {
  const RtMainScreen({super.key});

  @override
  State<RtMainScreen> createState() => _RtMainScreenState();
}

class _RtMainScreenState extends State<RtMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const RtDashboardScreen(),
    const RtWargaListScreen(),
    const RtApprovalScreen(),
    const RtProfilScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF2D3FE3),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Warga',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Approval',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
