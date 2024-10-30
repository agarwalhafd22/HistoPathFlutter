import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:slide_scholar/endocrine_system.dart';
import 'package:slide_scholar/integumentary_system.dart';
import 'package:slide_scholar/lymphatic_system.dart';
import 'package:slide_scholar/male_reproductive_system.dart';
import 'package:slide_scholar/renal_system.dart';
import 'package:slide_scholar/skeletal_system.dart';
import 'package:slide_scholar/student_quizzes.dart';
import 'package:slide_scholar/vascular_system.dart';
import 'student_login.dart';
import 'update_profile.dart';
import 'package:flutter/foundation.dart';
import 'gastro_int_system.dart';
import 'female_reproductive_system.dart';
// import 'package:flutter_windowmanager/flutter_windowmanager.dart';

class MainActivity extends StatefulWidget {
  @override
  _MainActivityState createState() => _MainActivityState();
}

class _MainActivityState extends State<MainActivity> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String accountName = 'User Name';
  String accountEmail = 'user@example.com';
  late DatabaseReference _userRef;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    // FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }


  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userEmail = user.email!;
      DatabaseReference studentRef = FirebaseDatabase.instance.ref('StudentDB');
      DatabaseReference teacherRef = FirebaseDatabase.instance.ref('TeacherDB');


      DatabaseEvent studentEvent = await studentRef.child(userEmail.replaceAll('.', ',')).once();
      if (studentEvent.snapshot.value != null) {
        final data = studentEvent.snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          accountName = data['name'];
          accountEmail = data['email'];
        });
        _userRef = studentRef.child(userEmail.replaceAll('.', ','));
        _listenForUserUpdates();
      } else {

        DatabaseEvent teacherEvent = await teacherRef.child(userEmail.replaceAll('.', ',')).once();
        if (teacherEvent.snapshot.value != null) {
          final data = teacherEvent.snapshot.value as Map<dynamic, dynamic>;
          setState(() {
            accountName = data['name'];
            accountEmail = data['email'];
          });
          _userRef = teacherRef.child(userEmail.replaceAll('.', ','));
          _listenForUserUpdates();
        }
      }
    }
  }

  Future<void> _listenForUserUpdates() async {

    _userRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          accountName = data['name'];
          accountEmail = data['email'];
        });
      }
    });
  }


  void _updateAccountName(String newName) {
    setState(() {
      accountName = newName;
    });
  }

  @override
  Widget build(BuildContext context) {

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

            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                UserAccountsDrawerHeader(
                  accountEmail: Text(accountEmail),
                  accountName: Text(accountName),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      accountName.isNotEmpty ? accountName[0] : 'U',
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
                // ListTile(
                //   leading: Icon(Icons.inbox),
                //   title: Text('Inbox'),
                //   onTap: () {
                //
                //   },
                // ),
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
              onTap: () => _logout(context),
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


              if (isWeb) {
                cardWidth = constraints.maxWidth * 0.2;
              } else if (isLandscape) {
                cardWidth = constraints.maxWidth * 0.35;
              } else {
                cardWidth = constraints.maxWidth * 0.9;
              }

              return Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildCard('assets/images/gastroint.png', cardWidth, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GastroIntSystem()),
                      );
                    }),
                    _buildCard('assets/images/renalbg.png', cardWidth, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RenalSystem()),
                      );
                    }),
                    _buildCard('assets/images/femalers.png', cardWidth, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FemaleReproductiveSystem()),
                      );
                    }),
                    _buildCard('assets/images/endocrine.png', cardWidth, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EndocrineSystem()),
                      );
                    }),
                    _buildCard('assets/images/integumentary.png', cardWidth, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => IntegumentarySystem()),
                      );
                    }),
                    _buildCard('assets/images/vascular.png', cardWidth, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => VascularSystem()),
                      );
                    }),
                    _buildCard('assets/images/malers.png', cardWidth, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MaleReproductiveSystem()),
                      );
                    }),
                    _buildCard('assets/images/skeletal.png', cardWidth, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SkeletalSystem()),
                      );
                    }),
                    _buildCard('assets/images/lymphatic.png', cardWidth, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LymphaticSystem()),
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
      onTap: onTap,
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 10.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 10,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.asset(
            imagePath,
            fit: BoxFit.fill,
            height: 150,
            width: cardWidth,
          ),
        ),
      ),
    );
  }

  // Logout method
  void _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();


      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => StudentLogin()),
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      print('Logout failed: $e');
    }
  }
}
