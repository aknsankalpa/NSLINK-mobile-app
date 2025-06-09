import 'package:firebase_core/firebase_core.dart';
import 'package:nslink_new/auth/loginScreen.dart';
import 'package:nslink_new/admin/homeScreen.dart';
import 'package:nslink_new/student/studentDashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:nslink_new/lecture/lectureDashboard.dart';
import 'package:nslink_new/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Check for logged-in user
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final userRole = prefs.getString('user_role');

  Widget initialScreen = LoginScreen();

  if (isLoggedIn && userRole != null) {
    switch (userRole) {
      case 'admin':
        initialScreen = const AdminHomeScreen();
        break;
      case 'student':
        initialScreen = const StudentDashboard();
        break;
      case 'lecture':
        initialScreen =
            const LectureDashboard(); // Placeholder for lecturer dashboard
        // Add lecturer dashboard when available
        break;
      default:
        initialScreen = LoginScreen();
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: const SplashScreen(), // Changed from LoginScreen to SplashScreen
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          primary: Colors.teal,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.teal),
          ),
        ),
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }
}
