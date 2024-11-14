import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:slide_scholar/renal_system.dart';
import 'package:slide_scholar/skeletal_system.dart';
import 'package:slide_scholar/vascular_system.dart';
import 'endocrine_system.dart';
import 'integumentary_system.dart';
import 'lymphatic_system.dart';
import 'male_reproductive_system.dart';
import 'teacher_login.dart';
import 'package:flutter/foundation.dart';
import 'gastro_int_system.dart';
import 'female_reproductive_system.dart';
import 'create_quiz.dart';
import 'my_quizzes.dart';
import 'all_quizzes.dart';

class MainActivityTeacher extends StatefulWidget {
  @override
  _MainActivityTeacherState createState() => _MainActivityTeacherState();
}

class _MainActivityTeacherState extends State<MainActivityTeacher> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String accountName = 'Teacher Name';
  String accountEmail = 'teacher@example.com';
  late DatabaseReference _userRef;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userEmail = user.email!;
      DatabaseReference teacherRef = FirebaseDatabase.instance.ref('TeacherDB');
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
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Color(0xFF052e62),
        leading: IconButton(
          icon: Icon(
              Icons.menu,
            color: Colors.white,
          ),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: Icon(
                Icons.notifications,
              color: Colors.white,
            ),
            onPressed: () {},
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
                      accountName.isNotEmpty ? accountName[0] : 'T',
                      style: TextStyle(fontSize: 40.0),
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFF052e62), // Set color for the profile area
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.question_answer_rounded),
                  title: Text('All Quizes'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AllQuizzes()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.question_answer_outlined),
                  title: Text('My Quizes'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyQuizzes()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.quiz),
                  title: Text('Create Quiz'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreateQuiz()),
                    );
                  },
                ),
                // ListTile(
                //   leading: Icon(Icons.inbox),
                //   title: Text('Inbox'),
                //   onTap: () {},
                // ),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Update Profile'),
                  onTap: () {},
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
                cardWidth = screenWidth * 0.2;
              } else if (isLandscape) {
                cardWidth = screenWidth * 0.3;
              } else {
                cardWidth = screenWidth > 600
                    ? screenWidth * 0.45
                    : screenWidth * 0.85;
              }

              return Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
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
    ];
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

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => TeacherLogin()),
    );
  }
}
