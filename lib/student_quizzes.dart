import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class StudentQuizzes extends StatefulWidget {
  @override
  _StudentQuizzesState createState() => _StudentQuizzesState();
}

class _StudentQuizzesState extends State<StudentQuizzes> {
  Future<List<Map<String, dynamic>>> _fetchQuizzes() async {
    QuerySnapshot quizSnapshot = await FirebaseFirestore.instance.collection('quizzes').get();
    return quizSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

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
              List<Map<String, dynamic>> onGoingQuizzes = [];
              List<Map<String, dynamic>> upcomingQuizzes = [];
              List<Map<String, dynamic>> pastQuizzes = [];

              for (var quiz in quizzes) {
                DateTime availabilityDate = DateTime.parse(quiz['availability']['date']);
                String time = quiz['availability']['time'];
                List<String> timeParts = time.split(':');
                int availabilityHour = int.parse(timeParts[0]);
                int availabilityMinute = int.parse(timeParts[1]);
                DateTime quizStartDateTime = DateTime(
                  availabilityDate.year,
                  availabilityDate.month,
                  availabilityDate.day,
                  availabilityHour,
                  availabilityMinute,
                );
                DateTime quizEndDateTime = quizStartDateTime.add(Duration(minutes: 5));

                if (currentDateTime.isAfter(quizStartDateTime) && currentDateTime.isBefore(quizEndDateTime)) {
                  onGoingQuizzes.add(quiz);
                } else if (currentDateTime.isBefore(quizStartDateTime)) {
                  upcomingQuizzes.add(quiz);
                } else {
                  pastQuizzes.add(quiz);
                }
              }

              return ListView(
                children: [
                  if (onGoingQuizzes.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Ongoing Quizzes',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 32.0),
                      child: Column(
                        children: onGoingQuizzes.map((quiz) {
                          return Column(
                            children: [
                              ListTile(
                                title: Text(
                                  quiz['title'],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  'Started on: ${DateFormat('dd, MMMM yyyy').format(DateTime.parse(quiz['availability']['date']))} ${quiz['availability']['time']}',
                                ),
                                onTap: () => _navigateToQuizDetails(quiz, currentDateTime),
                              ),
                              Divider(),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                  if (upcomingQuizzes.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Upcoming Quizzes',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 32.0),
                      child: Column(
                        children: upcomingQuizzes.map((quiz) {
                          return Column(
                            children: [
                              ListTile(
                                title: Text(
                                  quiz['title'],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  'Starts on: ${DateFormat('dd, MMMM yyyy').format(DateTime.parse(quiz['availability']['date']))} ${quiz['availability']['time']}',
                                ),
                                onTap: () => _navigateToQuizDetails(quiz, currentDateTime),
                              ),
                              Divider(),
                            ],
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
                      padding: const EdgeInsets.only(left: 32.0),
                      child: Column(
                        children: pastQuizzes.map((quiz) {
                          return Column(
                            children: [
                              ListTile(
                                title: Text(
                                  quiz['title'],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  'Started on: ${DateFormat('dd, MMMM yyyy').format(DateTime.parse(quiz['availability']['date']))} ${quiz['availability']['time']}',
                                ),
                                onTap: () => _navigateToQuizDetails(quiz, currentDateTime),
                              ),
                              Divider(),
                            ],
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

class QuizDetails extends StatefulWidget {
  final Map<String, dynamic> quiz;

  QuizDetails({required this.quiz});

  @override
  _QuizDetailsState createState() => _QuizDetailsState();
}

class _QuizDetailsState extends State<QuizDetails> {
  int _currentQuestionIndex = 0;
  List<String?> _selectedAnswers = [];
  late int _timeRemaining;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _selectedAnswers = List.filled(widget.quiz['questions'].length, null);
    _timeRemaining = widget.quiz['timeAllotted'] * 60;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeRemaining > 0) {
          _timeRemaining--;
        } else {
          _timer.cancel();
          _submitQuiz();
        }
      });
    });
  }

  void _submitQuiz() {
    _timer.cancel();
    String report = 'Quiz Report\n\n';
    for (int i = 0; i < widget.quiz['questions'].length; i++) {
      report += 'Q${i + 1}: ${widget.quiz['questions'][i]['question']}\n';
      report += 'Your Answer: ${_selectedAnswers[i]}\n';
      report += 'Correct Answer: ${widget.quiz['questions'][i]['correctAnswer']}\n\n';
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Quiz Submitted'),
          content: Text(report),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz['title']),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Time Remaining: ${(_timeRemaining ~/ 60).toString().padLeft(2, '0')}:${(_timeRemaining % 60).toString().padLeft(2, '0')}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(widget.quiz['questions'][_currentQuestionIndex]['question']),
                for (var option in widget.quiz['questions'][_currentQuestionIndex]['options'])
                  RadioListTile<String>(
                    title: Text(option),
                    value: option,
                    groupValue: _selectedAnswers[_currentQuestionIndex],
                    onChanged: (value) {
                      setState(() {
                        _selectedAnswers[_currentQuestionIndex] = value;
                      });
                    },
                  ),
                ElevatedButton(
                  onPressed: () {
                    if (_currentQuestionIndex < widget.quiz['questions'].length - 1) {
                      setState(() {
                        _currentQuestionIndex++;
                      });
                    } else {
                      _submitQuiz();
                    }
                  },
                  child: Text(_currentQuestionIndex < widget.quiz['questions'].length - 1 ? 'Next' : 'Submit'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
