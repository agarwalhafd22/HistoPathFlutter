import 'dart:async';

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
    DateTime quizEndDateTime = quizStartDateTime.add(Duration(minutes: int.parse(quiz['timeAllotted'])));

    if (currentDateTime.isBefore(quizStartDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Quiz has not yet started')),
      );
    } else if (currentDateTime.isAfter(quizStartDateTime) && currentDateTime.isBefore(quizEndDateTime)) {
      // Quiz is ongoing, allow student to take the quiz
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OngoingQuiz(quiz: quiz, currentDateTime: currentDateTime),
        ),
      );
    } else {
      // Quiz is in the past, show quiz content
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

              DateTime istDateTime = currentDateTime.add(Duration(hours: 5, minutes: 30));



              // Group quizzes into Upcoming and Past
              List<Map<String, dynamic>> onGoingQuizzes = [];
              List<Map<String, dynamic>> upcomingQuizzes = [];
              List<Map<String, dynamic>> pastQuizzes = [];

              for (var quiz in quizzes) {
                DateTime availabilityDate = DateTime.parse(quiz['availability']['date']);
                String time = quiz['availability']['time'];
                List<String> timeParts = time.split(':');

                // Extract availability hour and minute
                int availabilityHour = int.parse(timeParts[0]);
                int availabilityMinute = int.parse(timeParts[1]);

                // Create a DateTime object for quiz start time
                DateTime quizStartDateTime = DateTime(availabilityDate.year, availabilityDate.month, availabilityDate.day, availabilityHour, availabilityMinute);

                // Calculate the end of the 5-minute window for ongoing quiz
                DateTime quizEndDateTime = quizStartDateTime.add(Duration(minutes: 5));

                // Ongoing Quizzes: Check if current time is within the 5-minute window
                if (currentDateTime.isAfter(quizStartDateTime) && currentDateTime.isBefore(quizEndDateTime)) {
                  onGoingQuizzes.add(quiz);
                }
                // Upcoming Quizzes: If quiz hasn't started yet
                else if (currentDateTime.isBefore(quizStartDateTime)) {
                  upcomingQuizzes.add(quiz);
                }
                // Past Quizzes: If the quiz has already ended
                else {
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
                      padding: const EdgeInsets.only(left: 32.0), // Indentation for upcoming quizzes
                      child: Column(
                        children: onGoingQuizzes.map((quiz) {
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

class OngoingQuiz extends StatefulWidget {
  final Map<String, dynamic> quiz;
  final DateTime currentDateTime;

  OngoingQuiz({required this.quiz, required this.currentDateTime});

  @override
  _OngoingQuizState createState() => _OngoingQuizState();
}

class _OngoingQuizState extends State<OngoingQuiz> {
  int _currentQuestionIndex = 0;
  List<String?> _selectedAnswers = [];
  late int _timeRemaining;
  late Timer _timer;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _selectedAnswers = List.filled(widget.quiz['questions'].length, null);
    _timeRemaining = int.parse(widget.quiz['timeAllotted']) * 60; // Timer based on time allotted

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
    _calculateScore();

    String report = 'Quiz Report\n\n';
    for (int i = 0; i < widget.quiz['questions'].length; i++) {
      report += 'Q${i + 1}: ${widget.quiz['questions'][i]['question']}\n';
      report += 'Your Answer: ${_selectedAnswers[i] ?? "Not answered"}\n';
      report += 'Correct Answer: ${widget.quiz['questions'][i]['correctAnswer']}\n\n';
    }
    report += 'Your Score: $_score / ${widget.quiz['questions'].length}\n';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Quiz Submitted'),
          content: Text(report),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Go back to the quiz list
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _calculateScore() {
    _score = 0;
    for (int i = 0; i < widget.quiz['questions'].length; i++) {
      if (_selectedAnswers[i] == widget.quiz['questions'][i]['correctAnswer']) {
        _score++;
      }
    }
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
        backgroundColor: Colors.red, // Set app bar background to red
        automaticallyImplyLeading: false,
        title: Text(widget.quiz['title'], style: TextStyle(color: Colors.white),),
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
          // Make the content scrollable
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display the image for the current question if available
                  if (widget.quiz['questions'][_currentQuestionIndex]['imagePath'] != null &&
                      widget.quiz['questions'][_currentQuestionIndex]['imagePath'].isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.network(widget.quiz['questions'][_currentQuestionIndex]['imagePath']),
                    ),
                  // Display the question text
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      widget.quiz['questions'][_currentQuestionIndex]['question'],
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  // Display the options as Radio buttons
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
                  // Navigation buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_currentQuestionIndex > 0)
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _currentQuestionIndex--;
                              });
                            },
                            child: Text('Previous'),
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
                          child: Text(
                            _currentQuestionIndex < widget.quiz['questions'].length - 1
                                ? 'Next'
                                : 'Submit',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


}
