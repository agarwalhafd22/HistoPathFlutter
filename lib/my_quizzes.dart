import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package for date formatting
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

        // Check if the 'createdAt' field exists and is a Timestamp
        String? createdDate;
        if (quizData['createdAt'] != null && quizData['createdAt'] is Timestamp) {
          final timestamp = (quizData['createdAt'] as Timestamp).toDate();
          createdDate = _formatDate(timestamp);
        } else {
          createdDate = 'Unknown date';  // Fallback if date is missing or not a Timestamp
        }

        quizzes.add({
          'id': doc.id, // Store the document ID
          'title': quizData['title'] ?? 'Untitled Quiz', // Handle missing title
          'createdDate': createdDate, // Add the formatted createdAt
          ...quizData
        });
      }
    } catch (e) {
      print('Error fetching quizzes: $e');
    }

    return quizzes;
  }

  // Method to format date as '4th October, 2024 1:53 PM'
  String _formatDate(DateTime date) {
    // Extract day and add suffix
    final day = date.day;
    final daySuffix = _getDaySuffix(day);

    // Format without day suffix
    final formattedDateWithoutDay = DateFormat('MMMM, yyyy h:mm a').format(date);

    // Combine day with suffix and the rest of the formatted date
    return '$day$daySuffix ${DateFormat('MMMM, yyyy h:mm a').format(date)}';
  }

  // Method to get the suffix for day (e.g., 'st', 'nd', 'rd', 'th')
  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th'; // Special case for 11, 12, 13
    }
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
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
