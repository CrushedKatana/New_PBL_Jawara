import 'package:flutter/material.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/warga/screens/beranda_screen.dart';
import 'features/warga/screens/jualan_screen.dart';
import 'features/warga/screens/chat_screen.dart';
import 'features/warga/screens/profil_screen.dart';
import 'features/rt/screens/rt_dashboard_screen.dart';
import 'features/admin/screens/admin_dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jawara Marketplace',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2D3FE3)),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, this.userRole = 'warga'});
  
  final String userRole;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _initializeScreens();
  }

  void _initializeScreens() {
    switch (widget.userRole) {
      case 'rt':
        _screens = const [
          RtDashboardScreen(rt: '05'),
          JualanScreen(),
          ChatScreen(),
          ProfilScreen(),
        ];
        break;
      case 'admin':
        _screens = [
          const AdminDashboardScreen(),
          const JualanScreen(),
          const ChatScreen(),
          const ProfilScreen(),
        ];
        break;
      case 'warga':
      default:
        _screens = const [
          BerandaScreen(),
          JualanScreen(),
          ChatScreen(),
          ProfilScreen(),
        ];
    }
  }

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
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Jualan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            label: 'Chat',
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
