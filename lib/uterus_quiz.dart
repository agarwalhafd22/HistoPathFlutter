import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart'; // Import this package for setting orientation

class UterusQuiz extends StatefulWidget {
  @override
  _UterusQuizState createState() => _UterusQuizState();
}

class _UterusQuizState extends State<UterusQuiz> {
  int currentQuestionIndex = 0;
  bool quizStarted = false;
  int timerSeconds = 0;
  String? selectedOption; // Store selected option for the current question
  List<String> userAnswers = []; // Store user answers for all questions

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
    // Add more questions here as needed
  ];

  // Predefined answer key (correct answers)
  List<String> answerKey = ['Myometrium', 'Endometrium', 'Lining epithelium']; // Add correct answers corresponding to each question

  void startQuiz() {
    // Lock the orientation to portrait
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    setState(() {
      quizStarted = true;
      timerSeconds = 0;
      userAnswers = List.filled(questions.length, ''); // Initialize user answers
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
        selectedOption = userAnswers[currentQuestionIndex]; // Set the selected option for the next question
      });
    }
  }

  void clearSelection() {
    setState(() {
      selectedOption = null; // Clear the selected option
    });
  }

  void previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        userAnswers[currentQuestionIndex] = selectedOption ?? '';
        currentQuestionIndex--;
        selectedOption = userAnswers[currentQuestionIndex]; // Set the selected option for the previous question
      });
    }
  }

  void submitQuiz() {
    userAnswers[currentQuestionIndex] = selectedOption ?? '';
    int score = 0;

    // Calculate the score
    for (int i = 0; i < questions.length; i++) {
      if (userAnswers[i] == answerKey[i]) {
        score++;
      }
    }

    // Show results
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
                resetQuiz(); // Reset the quiz after showing results
              },
            ),
          ],
        );
      },
    );
  }

  void resetQuiz() {
    // Allow all orientations again
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
    // Calculate minutes and seconds
    int minutes = timerSeconds ~/ 60;
    int seconds = timerSeconds % 60;

    // Get screen dimensions
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth;

    // Set card width based on orientation and platform
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      cardWidth = screenWidth * 0.20; // 30% for landscape
    } else if (kIsWeb) {
      cardWidth = screenWidth * 0.15; // 20% for web
    } else {
      cardWidth = screenWidth * 0.90; // 90% for portrait
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove the back button from the app bar
      ),
      body: SingleChildScrollView( // Wrap the body with SingleChildScrollView
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Center the "Uterus" text and make it invisible when the quiz starts
            Visibility(
              visible: !quizStarted, // Make it invisible when the quiz starts
              child: Center(
                child: Text(
                  'Uterus',
                  style: TextStyle(
                    fontFamily: 'serif-monospace', // Set font to serif-monospace
                    fontSize: 40, // Set font size as needed
                    fontWeight: FontWeight.bold, // Bold text
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
                width: cardWidth, // Set the width of the card
                child: Card(
                  elevation: 5,
                  child: Column(
                    children: [
                      Text(
                        questions[currentQuestionIndex]['heading'], // Display the heading
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
                                      selectedOption = value as String; // Update selected option
                                    });
                                  },
                                ),
                                Text(option),
                              ],
                            ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: clearSelection, // Clear button to reset selection
                        child: Text('Clear Selection'),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Navigation buttons right under the card
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
                  // Show "Next" button only if an option is selected
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
