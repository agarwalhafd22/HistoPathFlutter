import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:firebase_database/firebase_database.dart'; // Import FirebaseDatabase
import 'package:flutter/material.dart';
import 'package:flutter_histo_path/endocrine_system.dart';
import 'package:flutter_histo_path/integumentary_system.dart';
import 'package:flutter_histo_path/lymphatic_system.dart';
import 'package:flutter_histo_path/male_reproductive_system.dart';
import 'package:flutter_histo_path/renal_system.dart';
import 'package:flutter_histo_path/skeletal_system.dart';
import 'package:flutter_histo_path/student_quizzes.dart';
import 'package:flutter_histo_path/vascular_system.dart';
import 'student_login.dart'; // Import StudentLogin page to redirect after logout
import 'update_profile.dart'; // Import UpdateProfile page
import 'package:flutter/foundation.dart'; // Import kIsWeb
import 'gastro_int_system.dart'; // Import the screen for Gastrointestinal
import 'female_reproductive_system.dart'; // Import the screen for Female Reproductive
import 'package:flutter_windowmanager/flutter_windowmanager.dart';

class MainActivity extends StatefulWidget {
  @override
  _MainActivityState createState() => _MainActivityState();
}

class _MainActivityState extends State<MainActivity> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String accountName = 'User Name'; // Default name
  String accountEmail = 'user@example.com'; // Default email
  late DatabaseReference _userRef;

  @override
  void initState() {
    super.initState();
    _fetchUserData();// Fetch user data when the widget is initialized
    FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }


  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser; // Get the current user
    if (user != null) {
      String userEmail = user.email!; // Get the user's email
      DatabaseReference studentRef = FirebaseDatabase.instance.ref('StudentDB');
      DatabaseReference teacherRef = FirebaseDatabase.instance.ref('TeacherDB');

      // Check StudentDB
      DatabaseEvent studentEvent = await studentRef.child(userEmail.replaceAll('.', ',')).once();
      if (studentEvent.snapshot.value != null) {
        final data = studentEvent.snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          accountName = data['name']; // Replace with actual field name for name
          accountEmail = data['email']; // Replace with actual field name for email
        });
        _userRef = studentRef.child(userEmail.replaceAll('.', ',')); // Reference for real-time updates
        _listenForUserUpdates(); // Start listening for updates
      } else {
        // If not found in StudentDB, check TeacherDB
        DatabaseEvent teacherEvent = await teacherRef.child(userEmail.replaceAll('.', ',')).once();
        if (teacherEvent.snapshot.value != null) {
          final data = teacherEvent.snapshot.value as Map<dynamic, dynamic>;
          setState(() {
            accountName = data['name']; // Replace with actual field name for name
            accountEmail = data['email']; // Replace with actual field name for email
          });
          _userRef = teacherRef.child(userEmail.replaceAll('.', ',')); // Reference for real-time updates
          _listenForUserUpdates(); // Start listening for updates
        }
      }
    }
  }

  Future<void> _listenForUserUpdates() async {
    // Listen for changes to user profile data
    _userRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          accountName = data['name']; // Update account name
          accountEmail = data['email']; // Update account email if necessary
        });
      }
    });
  }

  // Callback function to update account name
  void _updateAccountName(String newName) {
    setState(() {
      accountName = newName;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to get the screen width and orientation
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final isWeb = kIsWeb; // Checks if it's a web platform

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.red,
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Add functionality for notifications here, like navigating to a notifications screen
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Pushes content to top and bottom
          children: [
            Column( // This Column contains all the options except Logout
              children: [
                UserAccountsDrawerHeader(
                  accountEmail: Text(accountEmail), // Use fetched email
                  accountName: Text(accountName), // Use fetched name
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      accountName.isNotEmpty ? accountName[0] : 'U', // Display first letter of name
                      style: TextStyle(fontSize: 40.0),
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.query_builder),
                  title: Text('Quizzes'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => StudentQuizzes()), // Navigate to Gastrointestinal screen
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.inbox), // Add Inbox icon
                  title: Text('Inbox'), // Title for the Inbox
                  onTap: () {
                    // Navigate to InboxScreen
                  },
                ),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Update Profile'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdateProfile(onProfileUpdate: _updateAccountName), // Pass callback
                      ),
                    );
                  },
                ),
              ],
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () => _logout(context), // Call the _logout method when tapped
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              double cardWidth;

              // Adjust card width based on the screen size and orientation
              if (isWeb) {
                cardWidth = constraints.maxWidth * 0.2; // For web, narrow cards
              } else if (isLandscape) {
                cardWidth = constraints.maxWidth * 0.35; // For landscape
              } else {
                cardWidth = constraints.maxWidth * 0.9; // For portrait
              }

              return Center( // Center the Wrap
                child: Wrap(
                  alignment: WrapAlignment.center, // Center cards horizontally
                  spacing: 10, // Space between cards
                  runSpacing: 10, // Space between rows of cards
                  children: [
                    _buildCard('assets/images/gastroint.png', cardWidth, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GastroIntSystem()), // Navigate to Gastrointestinal screen
                      );
                    }),
                    _buildCard('assets/images/renalbg.png', cardWidth, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RenalSystem()), // Navigate to Gastrointestinal screen
                      );
                    }),
                    _buildCard('assets/images/femalers.png', cardWidth, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FemaleReproductiveSystem()), // Navigate to Female Reproductive screen
                      );
                    }),
                    _buildCard('assets/images/endocrine.png', cardWidth, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EndocrineSystem()), // Navigate to Female Reproductive screen
                      );
                    }),
                    _buildCard('assets/images/integumentary.png', cardWidth, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => IntegumentarySystem()), // Navigate to Female Reproductive screen
                      );
                    }),
                    _buildCard('assets/images/vascular.png', cardWidth, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => VascularSystem()), // Navigate to Female Reproductive screen
                      );
                    }),
                    _buildCard('assets/images/malers.png', cardWidth, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MaleReproductiveSystem()), // Navigate to Female Reproductive screen
                      );
                    }),
                    _buildCard('assets/images/skeletal.png', cardWidth, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SkeletalSystem()), // Navigate to Female Reproductive screen
                      );
                    }),
                    _buildCard('assets/images/lymphatic.png', cardWidth, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LymphaticSystem()), // Navigate to Female Reproductive screen
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCard(String imagePath, double cardWidth, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap, // Call the onTap function passed as a parameter
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 10.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 10,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.asset(
            imagePath,
            fit: BoxFit.fill, // Fill the card completely with the image without white spaces
            height: 150,
            width: cardWidth, // Use calculated card width
          ),
        ),
      ),
    );
  }

  // Logout method
  void _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut(); // Sign out from FirebaseAuth

      // After logout, navigate to StudentLogin page and clear the navigation stack
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => StudentLogin()),
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      // Handle any errors during logout (optional)
      print('Logout failed: $e');
    }
  }
}
