import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart'; // For Firebase Realtime Database
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart'; // For displaying toast messages
import 'package:flutter/scheduler.dart'; // Import for SchedulerBinding
import 'teacher_login.dart'; // Import the TeacherLogin screen
import 'student_sign_up.dart';
import 'main_activity.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {}
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyA7OcMSCbEjeAvAAYb0DKUPQvYgDnmWUT4",
      appId: "1:913172188739:web:886b1ea8d50de88579cef6",
      messagingSenderId: "913172188739",
      projectId: "histopathflutter-ba362",
      databaseURL: "https://histopathflutter-ba362-default-rtdb.firebaseio.com",
      storageBucket: "gs://histopathflutter-ba362.appspot.com",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Portal',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      debugShowCheckedModeBanner: false,
      home: StudentLogin(), // Set the initial screen here
    );
  }
}

class StudentLogin extends StatefulWidget {
  @override
  _StudentLoginState createState() => _StudentLoginState();
}

class _StudentLoginState extends State<StudentLogin> {
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
        title: null,
        backgroundColor: Color(0xFFbe252d),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text(
                'Students\' Portal',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30),
              Image.asset('assets/images/studentlogin.png', height: 150),
              SizedBox(height: 30),
              Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 400),
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
                  constraints: BoxConstraints(maxWidth: 400),
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
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _login,
                child: Text('Login'),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // Navigate to TeacherLogin screen
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => TeacherLogin()),
                        (route) => false,
                  );
                },
                child: Text('Are you a Teacher?'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StudentSignUp()),
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

      // Sanitize email by replacing '.' with ',' to match the database structure
      String sanitizedEmail = email.replaceAll('.', ',');

      // Sign in with Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if the user exists in StudentDB in the Realtime Database
      DatabaseReference studentRef = FirebaseDatabase.instance.ref().child('StudentDB').child(sanitizedEmail);
      DatabaseEvent event = await studentRef.once(); // Fetch student data once

      if (event.snapshot.exists) {
        // User exists in StudentDB, login is successful
        showToast(message: "Login successful", backgroundColor: Colors.green);
        // Use SchedulerBinding to navigate after the current frame
        SchedulerBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainActivity()),
          );
        });
      } else {
        // User does not exist in StudentDB, logout the user
        await _auth.signOut();
        showToast(message: "Login failed: No student record found", backgroundColor: Colors.red);
      }
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
