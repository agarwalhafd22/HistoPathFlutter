import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'quiz_details.dart';

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
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('quizzes')
          .where('teacherEmail', isEqualTo: _user.email)
          .get();

      for (var doc in snapshot.docs) {
        final quizData = doc.data() as Map<String, dynamic>;
        String? createdDate;
        if (quizData['createdAt'] != null && quizData['createdAt'] is Timestamp) {
          final timestamp = (quizData['createdAt'] as Timestamp).toDate();
          createdDate = _formatDate(timestamp);
        } else {
          createdDate = 'Unknown date';
        }

        quizzes.add({
          'id': doc.id,
          'title': quizData['title'] ?? 'Untitled Quiz',
          'createdDate': createdDate,
          ...quizData
        });
      }
    } catch (e) {
      print('Error fetching quizzes: $e');
    }
    return quizzes;
  }

  String _formatDate(DateTime date) {
    final day = date.day;
    final daySuffix = _getDaySuffix(day);
    final formattedDateWithoutDay = DateFormat('MMMM, yyyy h:mm a').format(date);
    return '$day$daySuffix ${DateFormat('MMMM, yyyy h:mm a').format(date)}';
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
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
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        automaticallyImplyLeading: false,
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text('Created on: ${quiz['createdDate']}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizDetails(quizId: quiz['id']),
                        ),
                      );
                    },
                  ),
                  Divider(),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
