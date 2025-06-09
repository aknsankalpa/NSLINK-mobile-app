import 'package:flutter/material.dart';
import 'package:nslink_new/lecture/meetingListScreen.dart';
import 'package:nslink_new/lecture/requestLeaveScreen.dart';
import 'package:nslink_new/lecture/lecture-student%20MeetingDashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nslink_new/auth/loginScreen.dart';
import 'package:nslink_new/common/work_in_progress_screen.dart';

class LectureDashboard extends StatefulWidget {
  const LectureDashboard({super.key});

  @override
  State<LectureDashboard> createState() => _LectureDashboardState();
}

class _LectureDashboardState extends State<LectureDashboard> {
  int _selectedIndex = 0;
  String? _email;

  @override
  void initState() {
    super.initState();
    _loadEmail();
  }

  Future<void> _loadEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _email = prefs.getString('user_email') ?? 'No email';
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _showLogoutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout Confirmation'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                if (!mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            // Add SingleChildScrollView to handle overflow
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 0,
                          top: 8.0,
                          left: 8.0,
                          right: 8.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image(
                              image: const AssetImage('assets/images/NSBM.png'),
                              width: screenWidth * 0.2, // Increased from 0.1
                              height: 60, // Increased from 30
                            ),
                            TextButton.icon(
                              onPressed: _showLogoutDialog,
                              icon: const Icon(Icons.logout, color: Colors.red),
                              label: const Text(
                                "Logout",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 16.0, // Reduced padding
                          top: 8.0,
                          left: 8.0,
                          right: 8.0,
                        ),
                        child: Stack(
                          children: [
                            Container(
                              height: 150, // Reduced height
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                image: const DecorationImage(
                                  image: AssetImage(
                                    'assets/images/NSBM_home.jpg',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 12,
                              left: 12,
                              child: Text(
                                _email ?? '',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18, // Slightly smaller text
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 4,
                                      color: Colors.black.withOpacity(0.7),
                                      offset: const Offset(1, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Action buttons grid
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: GridView.count(
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(), // Disable GridView scrolling
                          crossAxisCount: 2,
                          childAspectRatio: 1.1, // Adjusted for better fit
                          mainAxisSpacing: 16, // Reduced spacing
                          crossAxisSpacing: 16, // Reduced spacing
                          children: [
                            ActionButton(
                              title: 'Staff Meetings',
                              imagePath: 'assets/images/07.png',
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const MeetingListScreen(),
                                  ),
                                );
                              },
                            ),
                            ActionButton(
                              title: 'Student Meetings',
                              imagePath: 'assets/images/07.png',
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const LecturerMeetingDashboard(),
                                  ),
                                );
                              },
                            ),
                            ActionButton(
                              title: 'Add Leave',
                              imagePath: 'assets/images/07.png',
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RequestLeaveScreen(),
                                  ),
                                );
                              },
                            ),
                            ActionButton(
                              title: 'My Schedule',
                              imagePath: 'assets/images/07.png',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const WorkInProgressScreen(
                                          title: 'My Schedule',
                                        ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16), // Add some bottom padding
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  final String imagePath;

  const ActionButton({
    required this.title,
    this.onPressed,
    required this.imagePath,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          foregroundColor: const Color.fromARGB(255, 0, 0, 0),
          padding: const EdgeInsets.symmetric(vertical: 12), // Reduced padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        onPressed: onPressed ?? () {},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 40, // Slightly reduced size
              height: 40, // Slightly reduced size
            ),
            const SizedBox(height: 8), // Reduced spacing
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ), // Smaller text
            ),
          ],
        ),
      ),
    );
  }
}
