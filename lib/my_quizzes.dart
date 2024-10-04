import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'quiz_details.dart'; // Import the QuizDetailsScreen

class MyQuizzes extends StatefulWidget {
  @override
  _MyQuizzesState createState() => _MyQuizzesState();
}

class _MyQuizzesState extends State<MyQuizzes> {
  late User _user;
  late Future<List<Map<String, dynamic>>> _quizzesFuture;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
    _quizzesFuture = _fetchQuizzes();
  }

  Future<List<Map<String, dynamic>>> _fetchQuizzes() async {
    final List<Map<String, dynamic>> quizzes = [];

    try {
      // Fetch quizzes from Firestore where teacherEmail matches the current user's email
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('quizzes')
          .where('teacherEmail', isEqualTo: _user.email)
          .get();

      for (var doc in snapshot.docs) {
        final quizData = doc.data() as Map<String, dynamic>;

        // Check if the 'createdDate' field exists and is a Timestamp
        String? createdDate;
        if (quizData['createdDate'] != null && quizData['createdDate'] is Timestamp) {
          createdDate = (quizData['createdDate'] as Timestamp).toDate().toString();
        } else {
          createdDate = 'Unknown date';  // Fallback if date is missing or not a Timestamp
        }

        quizzes.add({
          'id': doc.id, // Store the document ID
          'title': quizData['title'] ?? 'Untitled Quiz', // Handle missing title
          'createdDate': createdDate, // Add the formatted createdDate
          ...quizData
        });
      }
    } catch (e) {
      print('Error fetching quizzes: $e');
    }

    return quizzes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Quizzes',
          style: TextStyle(color: Colors.white), // Set font color to white
        ),
        backgroundColor: Colors.red, // Set the app bar color to red
        automaticallyImplyLeading: false, // Remove the back arrow
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _quizzesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading quizzes'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No quizzes found'));
          }

          final quizzes = snapshot.data!;

          return ListView.builder(
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              return Column(
                children: [
                  ListTile(
                    title: Text(
                      quiz['title'],
                      style: TextStyle(
                        fontSize: 18, // Increase font size
                        fontWeight: FontWeight.bold, // Make it bold
                      ),
                    ),
                    subtitle: Text('Created on: ${quiz['createdDate']}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizDetails(quizId: quiz['id']), // Pass the quiz ID
                        ),
                      );
                    },
                  ),
                  Divider(), // Add a horizontal line division
                ],
              );
            },
          );
        },
      ),
    );
  }
}
