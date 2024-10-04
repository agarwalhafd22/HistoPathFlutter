import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb

class UpdateProfile extends StatefulWidget {
  final Function(String) onProfileUpdate;

  UpdateProfile({required this.onProfileUpdate});

  @override
  _UpdateProfileState createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String userType = 'Student'; // Default user type

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch user data on init
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userEmail = user.email!;
      _emailController.text = userEmail;

      DatabaseReference studentRef = FirebaseDatabase.instance.ref('StudentDB');
      DatabaseReference teacherRef = FirebaseDatabase.instance.ref('TeacherDB');

      DatabaseEvent studentEvent = await studentRef.child(userEmail.replaceAll('.', ',')).once();
      if (studentEvent.snapshot.value != null) {
        final data = studentEvent.snapshot.value as Map<dynamic, dynamic>;
        _nameController.text = data['name'];
        userType = 'Student';
      } else {
        DatabaseEvent teacherEvent = await teacherRef.child(userEmail.replaceAll('.', ',')).once();
        if (teacherEvent.snapshot.value != null) {
          final data = teacherEvent.snapshot.value as Map<dynamic, dynamic>;
          _nameController.text = data['name'];
          userType = 'Teacher';
        }
      }
    }
  }

  Future<void> _updateProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userEmail = user.email!;
      DatabaseReference ref = userType == 'Student'
          ? FirebaseDatabase.instance.ref('StudentDB').child(userEmail.replaceAll('.', ','))
          : FirebaseDatabase.instance.ref('TeacherDB').child(userEmail.replaceAll('.', ','));

      Map<String, String> updates = {'name': _nameController.text};

      if (_passwordController.text.isNotEmpty) {
        updates['password'] = _passwordController.text;
        await user.updatePassword(_passwordController.text);
      }

      await ref.update(updates);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated successfully!')));
      widget.onProfileUpdate(_nameController.text);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine orientation and platform (web or not)
    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    bool isWeb = kIsWeb;
    double screenWidth = MediaQuery.of(context).size.width;

    // Calculate text field width based on orientation and platform
    double fieldWidth;
    if (isWeb) {
      fieldWidth = screenWidth * 0.30; // 30% for web
    } else if (isLandscape) {
      fieldWidth = screenWidth * 0.40; // 20% for landscape on mobile/tablet
    } else {
      fieldWidth = screenWidth * 0.90; // 90% for portrait on mobile/tablet
    }

    return Scaffold(
      appBar: AppBar(title: Text('Update Profile')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              Container(
                width: fieldWidth, // Dynamic width for the text field
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: fieldWidth, // Dynamic width for the text field
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  readOnly: true, // Email is non-editable
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: fieldWidth, // Dynamic width for the text field
                child: TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'New Password'),
                  obscureText: true,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateProfile,
                child: Text('Update Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
