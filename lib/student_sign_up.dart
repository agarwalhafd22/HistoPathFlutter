import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'student_login.dart';

class StudentSignUp extends StatefulWidget {
  @override
  State<StudentSignUp> createState() => _StudentSignUpState();
}

class _StudentSignUpState extends State<StudentSignUp> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref(); // Firebase Realtime Database reference

  TextEditingController _nameController = TextEditingController();
  TextEditingController _collegeController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  bool isSigningUp = false;

  @override
  void dispose() {
    _nameController.dispose();
    _collegeController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: null,
        backgroundColor: Color(0xFFbe252d),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Text(
                    'Student Sign Up',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 30),
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildTextField('Name', _nameController),
                          _buildTextField('College', _collegeController),
                          _buildTextField('Phone', _phoneController, TextInputType.phone),
                          _buildTextField('Email', _emailController, TextInputType.emailAddress),
                          _buildTextField('Password', _passwordController, TextInputType.visiblePassword, true),
                          _buildTextField('Confirm Password', _confirmPasswordController, TextInputType.visiblePassword, true),
                          SizedBox(height: 20),
                          isSigningUp
                              ? CircularProgressIndicator()
                              : ElevatedButton(
                            onPressed: _signUp,
                            child: Text('Sign Up'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, [TextInputType keyboardType = TextInputType.text, bool obscureText = false]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  void _signUp() async {
    setState(() {
      isSigningUp = true;
    });

    String name = _nameController.text;
    String college = _collegeController.text;
    String phone = _phoneController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    // Validate password and confirm password
    if (password != confirmPassword) {
      showToast(message: "Passwords do not match", backgroundColor: Colors.red);
      setState(() {
        isSigningUp = false;
      });
      return;
    }

    try {
      // Create user using Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      if (user != null) {
        // Replace '.' with ',' in email to make it Firebase-friendly
        String sanitizedEmail = email.replaceAll('.', ',');

        // Save user data to Firebase Realtime Database under 'StudentDB'
        await databaseRef.child('StudentDB').child(sanitizedEmail).set({
          'name': name,
          'college': college,
          'phone': phone,
          'email': email,
          'password': password, // Not recommended to store password in plain text
        });

        showToast(message: "Account created, sign in", backgroundColor: Colors.green);

        // Navigate to StudentLoginPage after successful sign-up
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => StudentLogin()),
              (route) => false,
        );
      }
    } catch (e) {
      showToast(message: "Sign up failed: ${e.toString()}", backgroundColor: Colors.red);
    } finally {
      setState(() {
        isSigningUp = false;
      });
    }
  }

  // Toast helper method using fluttertoast
  void showToast({required String message, Color? backgroundColor}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: backgroundColor ?? Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
