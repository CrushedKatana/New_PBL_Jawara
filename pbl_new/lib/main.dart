import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'features/admin/screens/admin_dashboard_screen.dart';
import 'features/admin/screens/ml_statistics_screen.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/rt/screens/rt_dashboard_screen.dart';
import 'features/settings/addresses_page.dart';
import 'features/settings/language_page.dart';
import 'features/settings/notifications_page.dart';
import 'features/settings/payments_page.dart';
import 'features/settings/privacy_page.dart';
import 'features/settings/security_page.dart';
import 'features/settings/settings_home_page.dart';
import 'features/settings/support_page.dart';
import 'features/warga/screens/beranda_screen.dart';
import 'features/warga/screens/chat_screen.dart';
import 'features/warga/screens/clothing_detection_history_screen.dart';
import 'features/warga/screens/clothing_detection_screen.dart';
import 'features/warga/screens/jualan_screen.dart';
import 'features/warga/screens/profil_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with timeout and error handling
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        debugPrint('⚠️ Firebase initialization timeout - continuing without Firebase');
        throw Exception('Firebase timeout');
      },
    );
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('⚠️ Firebase initialization failed: $e');
    debugPrint('📱 App will continue without Firebase features');
    // App continues without Firebase - only affects FCM notifications
  }
  
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
      routes: {
        '/settings': (_) => const SettingsHomePage(),
        '/settings/security': (_) => const SecurityPage(),
        '/settings/notifications': (_) => const NotificationsPage(),
        '/settings/language': (_) => const LanguagePage(),
        '/settings/privacy': (_) => const PrivacyPage(),
        '/settings/addresses': (_) => const AddressesPage(),
        '/settings/payments': (_) => const PaymentsPage(),
        '/settings/support': (_) => const SupportPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/clothing_detection') {
          final userId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (_) => ClothingDetectionScreen(userId: userId),
          );
        }
        if (settings.name == '/clothing_detection_history') {
          final userId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (_) => ClothingDetectionHistoryScreen(userId: userId),
          );
        }
        if (settings.name == '/ml_statistics') {
          return MaterialPageRoute(
            builder: (_) => const MLStatisticsScreen(),
          );
        }
        return null;
      },
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
