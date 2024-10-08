import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class UterusQuiz extends StatefulWidget {
  @override
  _UterusQuizState createState() => _UterusQuizState();
}

class _UterusQuizState extends State<UterusQuiz> {
  int currentQuestionIndex = 0;
  bool quizStarted = false;
  int timerSeconds = 0;
  String? selectedOption;
  List<String> userAnswers = [];

  List<Map<String, dynamic>> questions = [
    {
      'image': 'assets/images/uterus_quiz_1.png',
      'options': ['Endometrium', 'Myometrium', 'Perimetrium', 'Serosa'],
      'heading': 'Identify the layer',
    },
    {
      'image': 'assets/images/uterus_quiz_2.png',
      'options': ['Endometrium', 'Myometrium', 'Perimetrium', 'Serosa'],
      'heading': 'Identify the layer',
    },
    {
      'image': 'assets/images/uterus_quiz_3.png',
      'options': ['Uterine blood vessels', 'Uterine glands', 'Lining epithelium', 'Stroma'],
      'heading': 'Identify the structure',
    },
  ];

  List<String> answerKey = ['Myometrium', 'Endometrium', 'Lining epithelium'];

  void startQuiz() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    setState(() {
      quizStarted = true;
      timerSeconds = 0;
      userAnswers = List.filled(questions.length, '');
    });
    startTimer();
  }

  void startTimer() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (quizStarted) {
        setState(() {
          timerSeconds++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        userAnswers[currentQuestionIndex] = selectedOption ?? '';
        currentQuestionIndex++;
        selectedOption = userAnswers[currentQuestionIndex];
      });
    }
  }

  void clearSelection() {
    setState(() {
      selectedOption = null;
    });
  }

  void previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        userAnswers[currentQuestionIndex] = selectedOption ?? '';
        currentQuestionIndex--;
        selectedOption = userAnswers[currentQuestionIndex];
      });
    }
  }

  void submitQuiz() {
    userAnswers[currentQuestionIndex] = selectedOption ?? '';
    int score = 0;

    for (int i = 0; i < questions.length; i++) {
      if (userAnswers[i] == answerKey[i]) {
        score++;
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Quiz Results'),
          content: Text('You scored $score out of ${questions.length}'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                resetQuiz();
              },
            ),
          ],
        );
      },
    );
  }

  void resetQuiz() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    setState(() {
      quizStarted = false;
      currentQuestionIndex = 0;
      timerSeconds = 0;
      selectedOption = null;
      userAnswers = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    int minutes = timerSeconds ~/ 60;
    int seconds = timerSeconds % 60;
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth;

    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      cardWidth = screenWidth * 0.20;
    } else if (kIsWeb) {
      cardWidth = screenWidth * 0.15;
    } else {
      cardWidth = screenWidth * 0.90;
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Visibility(
              visible: !quizStarted,
              child: Center(
                child: Text(
                  'Uterus',
                  style: TextStyle(
                    fontFamily: 'serif-monospace',
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (!quizStarted)
              Center(
                child: ElevatedButton(
                  onPressed: startQuiz,
                  child: Text('Start Quiz'),
                ),
              ),
            if (quizStarted) ...[
              Text(
                'Time Used: ${minutes > 0 ? '$minutes min ' : ''}${seconds}s',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 20),
              Container(
                width: cardWidth,
                child: Card(
                  elevation: 5,
                  child: Column(
                    children: [
                      Text(
                        questions[currentQuestionIndex]['heading'],
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Image.asset(questions[currentQuestionIndex]['image']),
                      Column(
                        children: [
                          for (String option in questions[currentQuestionIndex]['options'])
                            Row(
                              children: [
                                Radio(
                                  value: option,
                                  groupValue: selectedOption,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedOption = value as String;
                                    });
                                  },
                                ),
                                Text(option),
                              ],
                            ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: clearSelection,
                        child: Text('Clear Selection'),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: previousQuestion,
                    child: Text('Back'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currentQuestionIndex > 0 ? Colors.blue : Colors.grey,
                    ),
                  ),
                  if (selectedOption != null)
                    ElevatedButton(
                      onPressed: (currentQuestionIndex < questions.length - 1)
                          ? nextQuestion
                          : submitQuiz,
                      child: Text(currentQuestionIndex < questions.length - 1 ? 'Next' : 'Submit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
