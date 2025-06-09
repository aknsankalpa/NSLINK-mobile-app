import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nslink_new/admin/homeScreen.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedFaculty;
  String? selectedIntake;
  String? selectedDegree;

  final indexController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String role = "student";

  final List<String> intakes = [
    '22.2',
    '23.1',
    '23.2',
    '24.1',
    '24.2',
    '25.1',
    '25.2',
  ];

  final List<String> faculties = [
    'Business',
    'Computing',
    'Engineering',
    'Science',
  ];

  final Map<String, List<String>> facultyDegrees = {
    'Business': [
      'Business Analytics',
      'Applied Economics',
      'Tourism, Hospitality & Events',
      'Multimedia',
      'Business Communication',
      'Accounting and Finance',
      'International Business',
      'Business Management (Industrial Management)',
      'Business Management (Project Management)',
      'Business Management (Logistic Management)',
      'Business Management (Human Resource Management)',
    ],
    'Computing': [
      'Data Science',
      'Computer Science',
      'Computer Networks',
      'Software Engineering',
      'Management Information Systems',
      'Technology Management',
      'Computer Security',
      'Artificial Intelligence',
    ],
    'Engineering': [
      'Mechatronic Engineering',
      'Electrical and Electronic Engineering',
      'Computer Engineering',
      'Interior Design',
    ],
    'Science': [
      'Biomedical Science',
      'Pharmaceutical Science',
      'Nutrition and Health',
      'Psychology',
      'Nursing',
    ],
  };

  Future<void> _sendData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text,
          );

      // Get the user ID (UID)
      String uid = userCredential.user!.uid;

      await _firestore.collection('users').doc(uid).set({
        "role": role,
        "studentIndex": indexController.text,
        'studentName': nameController.text,
        "studentEmail": emailController.text,
        'studentPassword': passwordController.text,
        "studentIntake": selectedIntake,
        "studentFaculty": selectedFaculty,
        "studentDegree": selectedDegree,
      });

      // Show success message before navigating
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Student added successfully! 🎉'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2), // SnackBar duration
        ),
      );

      // Wait for SnackBar to show before navigating
      await Future.delayed(Duration(seconds: 2));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminHomeScreen()),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add Student: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    indexController.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminHomeScreen(),
                ),
              );
            },
          ),
        ),
        backgroundColor: const Color.fromARGB(0, 255, 255, 255),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Center(
                child: Container(
                  width: constraints.maxWidth < 400
                      ? constraints.maxWidth * 1
                      : 350,
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Add Student',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF2B2F32),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Divider(),
                        const SizedBox(height: 15),
                        _buildTextFormField(
                          indexController,
                          'Index Number',
                          TextInputType.number,
                          (value) {
                            if (value == null || value.isEmpty) {
                              return 'Index number is required';
                            }
                            if (!RegExp(r'^\d+$').hasMatch(value)) {
                              return 'Only numbers are allowed';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildTextFormField(
                          nameController,
                          'Name',
                          TextInputType.text,
                          (value) {
                            if (value == null || value.isEmpty) {
                              return 'Name is required';
                            }
                            if (value.length < 3) {
                              return 'Name must be at least 3 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildTextFormField(
                          emailController,
                          'Email',
                          TextInputType.emailAddress,
                          (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email is required';
                            }
                            if (!RegExp(
                              r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$',
                            ).hasMatch(value)) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildTextFormField(
                          passwordController,
                          'Password',
                          TextInputType.text,
                          (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                          obscureText: true,
                        ),
                        const SizedBox(height: 20),
                        // Intake Dropdown
                        DropdownButtonFormField<String>(
                          decoration: _inputDecoration('Select Intake'),
                          value: selectedIntake,
                          isExpanded: true,
                          items: intakes.map((String intake) {
                            return DropdownMenuItem<String>(
                              value: intake,
                              child: Text(intake),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              selectedIntake = value;
                            });
                          },
                          validator: (value) =>
                              value == null ? 'Select an intake' : null,
                        ),
                        const SizedBox(height: 20),
                        // Faculty Dropdown
                        DropdownButtonFormField<String>(
                          decoration: _inputDecoration('Select Faculty'),
                          value: selectedFaculty,
                          isExpanded: true,
                          items: faculties.map((String faculty) {
                            return DropdownMenuItem<String>(
                              value: faculty,
                              child: Text(faculty),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              selectedFaculty = value;
                              selectedDegree =
                                  null; // Reset degree when faculty changes
                            });
                          },
                          validator: (value) =>
                              value == null ? 'Select a faculty' : null,
                        ),
                        const SizedBox(height: 20),
                        // Degree Dropdown (conditionally shown)
                        if (selectedFaculty != null)
                          DropdownButtonFormField<String>(
                            decoration: _inputDecoration('Select Degree'),
                            value: selectedDegree,
                            isExpanded: true,
                            items: facultyDegrees[selectedFaculty]!.map((
                              String degree,
                            ) {
                              return DropdownMenuItem<String>(
                                value: degree,
                                child: Text(
                                  degree,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              setState(() {
                                selectedDegree = value;
                              });
                            },
                            validator: (value) =>
                                value == null ? 'Select a degree' : null,
                          ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              _sendData();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF26B99A),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Submit',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Reusable TextFormField Widget
  Widget _buildTextFormField(
    TextEditingController controller,
    String hintText,
    TextInputType keyboardType,
    String? Function(String?) validator, {
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: _inputDecoration(hintText),
      validator: validator,
    );
  }

  // Reusable Input Decoration
  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
