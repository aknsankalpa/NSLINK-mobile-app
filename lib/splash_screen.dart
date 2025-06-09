import 'package:flutter/material.dart';
import 'package:nslink_new/admin/homeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nslink_new/auth/loginScreen.dart';
import 'package:nslink_new/student/studentDashboard.dart';
import 'lecture/lectureDashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 5));

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final userRole = prefs.getString('user_role');

    if (!isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      return;
    }

    // Navigate based on user role
    switch (userRole) {
      case 'admin':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
        );
        break;
      case 'student':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const StudentDashboard()),
        );
        break;
      case 'lecture':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LectureDashboard()),
        );
        break;
      default:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF5F5F5, // Light grey background
      ), // Cream color to match login screen
      body: Center(
        child: Image.asset('assets/images/NSBM.png', width: 500, height: 500),
      ),
    );
  }
}
