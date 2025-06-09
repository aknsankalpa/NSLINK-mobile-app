import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nslink_new/admin/homeScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddLectureScreen extends StatefulWidget {
  const AddLectureScreen({super.key});

  @override
  _AddLectureScreenState createState() => _AddLectureScreenState();
}

class _AddLectureScreenState extends State<AddLectureScreen> {
  final TextEditingController indexController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? selectedFaculty = "Computing"; // Default value
  String? selectedDepartment; // Will be set based on faculty
  final TextEditingController _postController = TextEditingController();
  String role = "lecture";
  String? uid;

  // Faculty list
  final List<String> faculties = [
    'Computing',
    'Science',
    'Engineering',
    'Business',
  ];

  // Department lists organized by faculty
  final Map<String, List<String>> departmentsByFaculty = {
    'Computing': [
      'Software Engineering',
      'Network Engineering',
      'Data Science',
      'Cybersecurity',
    ],
    'Science': ['Physics', 'Chemistry', 'Biology', 'Mathematics'],
    'Engineering': [
      'Civil Engineering',
      'Electrical Engineering',
      'Mechanical Engineering',
      'Chemical Engineering',
    ],
    'Business': ['Marketing', 'Finance', 'Management', 'Accounting'],
  };

  // Current departments based on selected faculty
  List<String> get currentDepartments =>
      departmentsByFaculty[selectedFaculty] ?? [];

  @override
  void initState() {
    super.initState();
    // Set initial department based on default faculty
    selectedDepartment = currentDepartments.isNotEmpty
        ? currentDepartments[0]
        : null;
  }

  Future<void> _sendData() async {
    if (indexController.text.isEmpty ||
        nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        selectedFaculty == null ||
        selectedDepartment == null ||
        _postController.text.isEmpty ||
        _imageUrlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All fields are required!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Create authentication user
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      // Prepare common data structure
      Map<String, dynamic> userData = {
        'lectureIndex': indexController.text,
        'lectureName': nameController.text,
        'lectureEmail': emailController.text,
        'lecturePassword': _passwordController.text,
        'lectureFaculty': selectedFaculty,
        'lectureDepartment': selectedDepartment,
        'lecturePost': _postController.text,
        'lectureImage': _imageUrlController.text,
        'role': role,
      };

      // Store in users collection with auth UID
      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userData);

      // Store in addLecture collection
      DocumentReference addLectureDocRef = await _firestore
          .collection('addLecture')
          .add(userData);

      // Store in lecturers collection
      await _firestore.collection('lecturers').add({
        'email': emailController.text,
        'name': nameController.text,
        'imageUrl': _imageUrlController.text,
        'faculty': selectedFaculty,
        'department': selectedDepartment,
      });

      // Create slots subcollection
      await addLectureDocRef.collection('slots').add({});

      Navigator.pop(context); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lecture added successfully! 🎉'),
          backgroundColor: Colors.green,
        ),
      );

      await Future.delayed(const Duration(seconds: 2));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add lecture: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive design
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 600;
    final double horizontalPadding = isSmallScreen
        ? 16.0
        : screenSize.width * 0.1;
    final double fieldSpacing = isSmallScreen ? 16.0 : 24.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Lecture"),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
            );
          },
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(height: 1, thickness: 1),
                    SizedBox(height: fieldSpacing),

                    // ID Field
                    _buildTextField(
                      controller: indexController,
                      hintText: 'Index',
                    ),
                    SizedBox(height: fieldSpacing),

                    // Name Field
                    _buildTextField(
                      controller: nameController,
                      hintText: 'name',
                    ),
                    SizedBox(height: fieldSpacing),

                    // Email Field
                    _buildTextField(
                      controller: emailController,
                      hintText: 'Email',
                    ),
                    SizedBox(height: fieldSpacing),

                    // Password Field
                    _buildTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      isPassword: true,
                    ),
                    SizedBox(height: fieldSpacing),

                    // Faculty dropdown
                    _buildDropdown(
                      value: selectedFaculty,
                      hint: 'Faculty drop down',
                      items: faculties,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedFaculty = newValue;
                          // Reset department when faculty changes
                          selectedDepartment = currentDepartments.isNotEmpty
                              ? currentDepartments[0]
                              : null;
                        });
                      },
                    ),
                    SizedBox(height: fieldSpacing),

                    // Department dropdown - changes based on faculty
                    _buildDropdown(
                      value: selectedDepartment,
                      hint: 'DEPARTMENT drop down',
                      items: currentDepartments,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedDepartment = newValue;
                        });
                      },
                    ),
                    SizedBox(height: fieldSpacing),

                    // Post Field
                    _buildTextField(
                      controller: _postController,
                      hintText: 'post of Lecturers',
                    ),
                    SizedBox(height: fieldSpacing),

                    // Attachment section
                    _buildAttachmentSection(context),
                    SizedBox(height: fieldSpacing * 1.5),

                    // Action Buttons
                    _buildActionButtons(isSmallScreen),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromARGB(255, 107, 104, 104)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              hint,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          value: value,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          icon: const Icon(
            Icons.arrow_drop_down,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(value),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAttachmentSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.image, size: 20),
              SizedBox(width: 8),
              Text('Image URL', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _imageUrlController,
            decoration: InputDecoration(
              hintText: 'Enter image URL',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isSmallScreen) {
    if (isSmallScreen) {
      // Stack buttons vertically on small screens
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: double.infinity, child: _buildConfirmButton()),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: _buildRejectButton()),
        ],
      );
    } else {
      // Place buttons side by side on larger screens
      return Row(
        children: [
          Expanded(child: _buildConfirmButton()),
          const SizedBox(width: 16),
          Expanded(child: _buildRejectButton()),
        ],
      );
    }
  }

  Widget _buildConfirmButton() {
    return ElevatedButton(
      onPressed: _sendData,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: const Text('Confirm'),
    );
  }

  Widget _buildRejectButton() {
    return ElevatedButton(
      onPressed: () {
        // Clear all fields
        indexController.clear();
        nameController.clear();
        emailController.clear();
        _passwordController.clear();
        _postController.clear();
        _imageUrlController.clear();
        setState(() {
          selectedFaculty = "Computing"; // Reset to default
          selectedDepartment = departmentsByFaculty['Computing']
              ?.first; // Reset to first department of Computing
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Colors.red),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: const Text('Reset'),
    );
  }

  @override
  void dispose() {
    indexController.dispose();
    nameController.dispose();
    emailController.dispose();
    _passwordController.dispose();
    _postController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
}
