import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StudentQuizzes extends StatefulWidget {
  @override
  _StudentQuizzesState createState() => _StudentQuizzesState();
}

class _StudentQuizzesState extends State<StudentQuizzes> {
  // Function to fetch all quizzes
  Future<List<Map<String, dynamic>>> _fetchQuizzes() async {
    QuerySnapshot quizSnapshot = await FirebaseFirestore.instance.collection('quizzes').get();
    return quizSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  // Function to fetch current date and time from the internet
  Future<DateTime> _fetchCurrentDateTime() async {
    final response = await http.get(Uri.parse('http://worldtimeapi.org/api/timezone/Etc/UTC'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      String dateTimeString = data['datetime'];
      return DateTime.parse(dateTimeString);
    } else {
      throw Exception('Failed to load current date and time');
    }
  }

  // Function to navigate to quiz details page
  void _navigateToQuizDetails(Map<String, dynamic> quiz, DateTime currentDateTime) {
    DateTime availabilityDate = DateTime.parse(quiz['availability']['date']);
    String time = quiz['availability']['time'];

    DateTime quizStartDateTime = DateTime.parse('${availabilityDate.toIso8601String().split('T')[0]} $time');

    if (currentDateTime.isBefore(quizStartDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Quiz has not yet started')),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizDetails(quiz: quiz),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All Quizzes',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red,
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchQuizzes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading quizzes'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No quizzes available'));
          }

          List<Map<String, dynamic>> quizzes = snapshot.data!;

          // Sort quizzes based on the availability date
          quizzes.sort((a, b) {
            DateTime dateA = DateTime.parse(a['availability']['date']);
            DateTime dateB = DateTime.parse(b['availability']['date']);
            return dateA.compareTo(dateB);
          });

          return FutureBuilder<DateTime>(
            future: _fetchCurrentDateTime(),
            builder: (context, currentDateTimeSnapshot) {
              if (currentDateTimeSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (currentDateTimeSnapshot.hasError) {
                return Center(child: Text('Error fetching current date and time'));
              }

              DateTime currentDateTime = currentDateTimeSnapshot.data!;

              // Group quizzes into Upcoming and Past
              List<Map<String, dynamic>> upcomingQuizzes = [];
              List<Map<String, dynamic>> pastQuizzes = [];

              for (var quiz in quizzes) {
                DateTime availabilityDate = DateTime.parse(quiz['availability']['date']);
                String time = quiz['availability']['time'];
                DateTime quizStartDateTime = DateTime.parse('${availabilityDate.toIso8601String().split('T')[0]} $time');

                if (currentDateTime.isBefore(quizStartDateTime)) {
                  upcomingQuizzes.add(quiz);
                } else {
                  pastQuizzes.add(quiz);
                }
              }

              return ListView(
                children: [
                  if (upcomingQuizzes.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Upcoming Quizzes',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 32.0), // Indentation for upcoming quizzes
                      child: Column(
                        children: upcomingQuizzes.map((quiz) {
                          return ListTile(
                            title: Text(
                              quiz['title'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Starts on: ${DateFormat('dd, MMMM yyyy').format(DateTime.parse(quiz['availability']['date']))} ${quiz['availability']['time']}',
                            ),
                            onTap: () => _navigateToQuizDetails(quiz, currentDateTime),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                  if (pastQuizzes.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Past Quizzes',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 32.0), // Indentation for past quizzes
                      child: Column(
                        children: pastQuizzes.map((quiz) {
                          return ListTile(
                            title: Text(
                              quiz['title'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Started on: ${DateFormat('dd, MMMM yyyy').format(DateTime.parse(quiz['availability']['date']))} ${quiz['availability']['time']}',
                            ),
                            onTap: () => _navigateToQuizDetails(quiz, currentDateTime),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }
}

// Widget to display quiz details
class QuizDetails extends StatelessWidget {
  final Map<String, dynamic> quiz;

  QuizDetails({required this.quiz});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          quiz['title'],
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Teacher: ${quiz['teacherName']}', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Time Allotted: ${quiz['timeAllotted']} minutes'),
            SizedBox(height: 10),
            Text('Questions:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: quiz['questions'].length,
                itemBuilder: (context, index) {
                  final question = quiz['questions'][index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Q${index + 1}: ${question['question']}'),
                          SizedBox(height: 10),
                          ...List.generate(question['options'].length, (optionIndex) {
                            return Text('Option ${optionIndex + 1}: ${question['options'][optionIndex]}');
                          }),
                          SizedBox(height: 5),
                          Text('Correct Answer: ${question['correctAnswer']}', style: TextStyle(fontWeight: FontWeight.bold)),
                          if (question['imagePath'] != null) ...[
                            SizedBox(height: 10),
                            Image.network(question['imagePath']), // Display the question image if available
                          ]
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
