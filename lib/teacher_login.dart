import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart'; // For displaying toast messages
import 'main_activity_teacher.dart'; // Import the MainActivity screen
import 'student_login.dart'; // Import the StudentLogin screen
import 'teacher_sign_up.dart'; // Import the TeacherSignUp screen

class TeacherLogin extends StatefulWidget {
  @override
  _TeacherLoginState createState() => _TeacherLoginState();
}

class _TeacherLoginState extends State<TeacherLogin> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoggingIn = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: null, // No title in the AppBar
        backgroundColor: Color(0xFFbe252d),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 20), // Space below the AppBar
              Text(
                'Teachers\' Portal',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30), // Space between title and image
              Image.asset('assets/images/teacherlogin.png', height: 150),
              SizedBox(height: 30),
              Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 400), // Max width for Card
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Email',
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 400), // Max width for Card
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Password',
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                        ),
                        obscureText: true,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              isLoggingIn
                  ? CircularProgressIndicator() // Show loading indicator if logging in
                  : ElevatedButton(
                onPressed: _login,
                child: Text('Login'),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => StudentLogin()),
                        (route) => false,
                  );
                },
                child: Text('Are you a Student?'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TeacherSignUp()),
                  );
                },
                child: Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    setState(() {
      isLoggingIn = true;
    });

    try {
      String email = _emailController.text;
      String password = _passwordController.text;

      // Sign in with Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // On successful login, navigate to MainActivity
      showToast(message: "Login successful", backgroundColor: Colors.green);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainActivityTeacher()),
      );
    } catch (e) {
      // If login fails, show an error message
      showToast(message: "Login failed: ${e.toString()}", backgroundColor: Colors.red);
    } finally {
      setState(() {
        isLoggingIn = false;
      });
    }
  }

  // Toast helper method using fluttertoast
  void showToast({required String message, Color? backgroundColor}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: backgroundColor ?? Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
