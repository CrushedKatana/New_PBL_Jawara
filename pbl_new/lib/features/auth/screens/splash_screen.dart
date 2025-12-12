import 'package:flutter/material.dart';

import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to login screen after 2 seconds (reduced from 3)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D3FE3), // Blue background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Shopping bag icon with sparkle
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4E5FE8),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    size: 100,
                    color: Color(0xFFFFD700), // Yellow/gold color
                  ),
                ),
                const Positioned(
                  right: 40,
                  top: 40,
                  child: Icon(
                    Icons.auto_awesome,
                    size: 40,
                    color: Color(0xFFFFD700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            // App title
            const Text(
              'Jawara',
              style: TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            // Subtitle
            const Text(
              'MARKETPLACE PAKAIAN',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFFFFD700),
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 60),
            // Description
            const Text(
              'Pasar lokal untuk',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Komunitas RT/RW Indonesia',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFFFFD700),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 60),
            // Loading indicator (dots)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: index == 1 ? const Color(0xFFFFD700) : Colors.white54,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
