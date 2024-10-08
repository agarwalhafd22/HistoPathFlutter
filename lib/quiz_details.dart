import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class QuizDetails extends StatefulWidget {
  final String quizId;

  QuizDetails({required this.quizId});

  @override
  _QuizDetailsState createState() => _QuizDetailsState();
}

class _QuizDetailsState extends State<QuizDetails> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _timeAllottedController = TextEditingController();
  TextEditingController _availabilityDateController = TextEditingController();
  TextEditingController _availabilityTimeController = TextEditingController();

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
          _timeAllottedController.text = quizData['timeAllotted'].toString();
          _availabilityDateController.text = quizData['availability']['date'];
          _availabilityTimeController.text = quizData['availability']['time'];

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
      List<Map<String, dynamic>> updatedQuestions = [];
      for (int i = 0; i < _questions.length; i++) {
        updatedQuestions.add({
          'question': _questionControllers[i].text,
          'options': _optionControllers[i].map((controller) => controller.text).toList(),
          'correctAnswer': _correctAnswerControllers[i].text,
          'imagePath': _questions[i]['imagePath'],
        });
      }

      await FirebaseFirestore.instance.collection('quizzes').doc(widget.quizId).update({
        'title': _titleController.text,
        'questions': updatedQuestions,
        'timeAllotted': int.tryParse(_timeAllottedController.text) ?? 0,
        'availability': {
          'date': _availabilityDateController.text,
          'time': _availabilityTimeController.text,
        },
      });

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

  Future<void> _deleteQuiz() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Quiz'),
        content: Text('This action is not reversible. Are you sure you want to delete this quiz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('OK'),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      try {
        DocumentSnapshot quizSnapshot = await FirebaseFirestore.instance
            .collection('quizzes')
            .doc(widget.quizId)
            .get();

        if (quizSnapshot.exists) {
          Map<String, dynamic> quizData = quizSnapshot.data() as Map<String, dynamic>;
          String imagePath = quizData['questions'][0]['imagePath'];

          if (imagePath.isNotEmpty) {
            await FirebaseStorage.instance.refFromURL(imagePath).delete();
          }

          await FirebaseFirestore.instance.collection('quizzes').doc(widget.quizId).delete();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Quiz deleted successfully!')),
          );

          Navigator.of(context).pop();
        }
      } catch (e) {
        print('Error deleting quiz: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete quiz.')),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _availabilityDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _availabilityTimeController.text = pickedTime.format(context);
      });
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
        automaticallyImplyLeading: false,
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
              TextField(
                controller: _timeAllottedController,
                decoration: InputDecoration(labelText: 'Time Allotted (in minutes)'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              TextField(
                controller: _availabilityDateController,
                decoration: InputDecoration(
                  labelText: 'Availability Date',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                readOnly: true,
              ),
              SizedBox(height: 20),
              TextField(
                controller: _availabilityTimeController,
                decoration: InputDecoration(
                  labelText: 'Availability Time',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.access_time),
                    onPressed: () => _selectTime(context),
                  ),
                ),
                readOnly: true,
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
                          if (_questions[index]['imagePath'] != null)
                            Image.network(_questions[index]['imagePath']),
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
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _deleteQuiz,
                child: Text(
                  'Delete Quiz',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
