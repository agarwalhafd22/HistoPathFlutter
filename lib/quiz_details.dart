import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class QuizDetails extends StatefulWidget {
  final String quizId;

  QuizDetails({required this.quizId});

  @override
  _QuizDetailsState createState() => _QuizDetailsState();
}

class _QuizDetailsState extends State<QuizDetails> {
  TextEditingController _titleController = TextEditingController();
  List<Map<String, dynamic>> _questions = [];
  List<TextEditingController> _questionControllers = [];
  List<List<TextEditingController>> _optionControllers = [];
  List<TextEditingController> _correctAnswerControllers = [];

  @override
  void initState() {
    super.initState();
    _fetchQuizDetails();
  }

  Future<void> _fetchQuizDetails() async {
    try {
      DocumentSnapshot quizSnapshot = await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(widget.quizId)
          .get();

      if (quizSnapshot.exists) {
        Map<String, dynamic> quizData = quizSnapshot.data() as Map<String, dynamic>;

        setState(() {
          _titleController.text = quizData['title'];
          _questions = List<Map<String, dynamic>>.from(quizData['questions']);

          // Initialize controllers for questions, options, and correct answers
          _questionControllers = _questions.map((q) => TextEditingController(text: q['question'])).toList();
          _optionControllers = _questions.map((q) {
            return List<TextEditingController>.generate(
              q['options'].length,
                  (index) => TextEditingController(text: q['options'][index]),
            );
          }).toList();
          _correctAnswerControllers = _questions.map((q) => TextEditingController(text: q['correctAnswer'])).toList();
        });
      }
    } catch (e) {
      print('Error fetching quiz details: $e');
    }
  }

  Future<void> _saveChanges() async {
    try {
      // Prepare updated questions list with edited values
      List<Map<String, dynamic>> updatedQuestions = [];
      for (int i = 0; i < _questions.length; i++) {
        updatedQuestions.add({
          'question': _questionControllers[i].text,
          'options': _optionControllers[i].map((controller) => controller.text).toList(),
          'correctAnswer': _correctAnswerControllers[i].text,
          // Add the imagePath to the updated question
          'imagePath': _questions[i]['imagePath'],
        });
      }

      // Update the quiz data in Firestore
      await FirebaseFirestore.instance.collection('quizzes').doc(widget.quizId).update({
        'title': _titleController.text,
        'questions': updatedQuestions,
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Quiz updated successfully!')),
      );
    } catch (e) {
      print('Error updating quiz: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update quiz.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Quiz',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        automaticallyImplyLeading: false, // Removes the back arrow
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Quiz Title'),
              ),
              SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _questionControllers[index],
                            decoration: InputDecoration(
                              labelText: 'Question ${index + 1}',
                            ),
                          ),
                          SizedBox(height: 10),
                          ...List.generate(4, (optionIndex) {
                            return TextField(
                              controller: _optionControllers[index][optionIndex],
                              decoration: InputDecoration(
                                labelText: 'Option ${optionIndex + 1}',
                              ),
                            );
                          }),
                          SizedBox(height: 10),
                          TextField(
                            controller: _correctAnswerControllers[index],
                            decoration: InputDecoration(
                              labelText: 'Correct Answer',
                            ),
                          ),
                          SizedBox(height: 10),
                          // Display image for the question
                          if (_questions[index]['imagePath'] != null)
                            Column(
                              children: [
                                Image.network(
                                  _questions[index]['imagePath'], // Fetch image from Firestore
                                  height: 100, // Set a height for the image preview
                                  width: 100, // Set a width for the image preview
                                  fit: BoxFit.cover, // Cover the space appropriately
                                ),
                                SizedBox(height: 5),
                                // Text('Image URL: ${_questions[index]['imagePath']}'), // Show uploaded image URL
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveChanges,
                child: Text(
                  'Save Changes',
                  style: TextStyle(color: Colors.white), // Sets font color to white
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  backgroundColor: Colors.red,
                ),
              ),
              SizedBox(height: 10), // Space between buttons
              ElevatedButton(
                onPressed: () {
                  // No functionality yet
                },
                child: Text(
                  'Deploy',
                  style: TextStyle(color: Colors.white), // White font color
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  backgroundColor: Colors.red, // Red background color
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
