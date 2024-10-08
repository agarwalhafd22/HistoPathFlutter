import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:firebase_database/firebase_database.dart'; // Import FirebaseDatabase
import 'package:flutter/material.dart';
import 'package:flutter_histo_path/renal_system.dart';
import 'package:flutter_histo_path/skeletal_system.dart';
import 'package:flutter_histo_path/vascular_system.dart';
import 'endocrine_system.dart';
import 'integumentary_system.dart';
import 'lymphatic_system.dart';
import 'male_reproductive_system.dart';
import 'teacher_login.dart'; // Import TeacherLogin page to redirect after logout
import 'package:flutter/foundation.dart'; // Import kIsWeb
import 'gastro_int_system.dart'; // Import the screen for Gastrointestinal
import 'female_reproductive_system.dart'; // Import the screen for Female Reproductive
import 'create_quiz.dart';
import 'my_quizzes.dart';
import 'all_quizzes.dart';

class MainActivityTeacher extends StatefulWidget {
  @override
  _MainActivityTeacherState createState() => _MainActivityTeacherState();
}

class _MainActivityTeacherState extends State<MainActivityTeacher> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String accountName = 'Teacher Name'; // Default name
  String accountEmail = 'teacher@example.com'; // Default email
  late DatabaseReference _userRef;

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch user data when the widget is initialized
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser; // Get the current user
    if (user != null) {
      String userEmail = user.email!; // Get the user's email
      DatabaseReference teacherRef = FirebaseDatabase.instance.ref('TeacherDB');

      // Check TeacherDB
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Color(0xFFbe252d),
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
                      accountName.isNotEmpty ? accountName[0] : 'T', // Display first letter of name
                      style: TextStyle(fontSize: 40.0),
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.question_answer_rounded), // Add Inbox icon
                  title: Text('All Quizes'), // Title for the Inbox
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AllQuizzes()), // Navigate to All Quizzes Screen
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.question_answer_outlined), // Add Inbox icon
                  title: Text('My Quizes'), // Title for the Inbox
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyQuizzes()), // Navigate to My Quizzes Screen
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.quiz), // Add Inbox icon
                  title: Text('Create Quiz'), // Title for the Create Quiz
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreateQuiz()), // Navigate to Create Quiz Screen
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
                    // Navigate to Update Profile screen
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

              // Adjust card width based on screen size and orientation
              if (isWeb) {
                cardWidth = screenWidth * 0.2; // Narrow cards for web view
              } else if (isLandscape) {
                cardWidth = screenWidth * 0.3; // For landscape on mobile/tablet
              } else {
                // For portrait, set card width based on mobile or tablet screen width
                cardWidth = screenWidth > 600
                    ? screenWidth * 0.45 // Use 45% for larger tablet portrait
                    : screenWidth * 0.85; // Use 85% for smaller mobile portrait
              }

              // Layout for cards in a row based on screen orientation or platform
              return Center(
                child: Wrap(
                  alignment: WrapAlignment.center, // Center cards horizontally
                  spacing: 10, // Space between cards
                  runSpacing: 10, // Space between rows of cards
                  children: _buildCardList(cardWidth),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCardList(double cardWidth) {
    return [
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
    ];
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
  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut(); // Sign out from Firebase
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => TeacherLogin()), // Navigate to Login screen
    );
  }
}
