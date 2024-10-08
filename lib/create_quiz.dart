import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CreateQuiz extends StatefulWidget {
  @override
  _CreateQuizState createState() => _CreateQuizState();
}

class _CreateQuizState extends State<CreateQuiz> {
  final TextEditingController _quizTitleController = TextEditingController();
  final TextEditingController _timeAllottedController = TextEditingController();
  final List<Map<String, dynamic>> _questions = [];
  final ImagePicker _picker = ImagePicker();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _pickImage(int questionIndex) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _questions[questionIndex]['imagePath'] = image.path;
      });
    }
  }

  Future<String> _uploadImage(File imageFile) async {
    try {
      final ref = FirebaseStorage.instance.ref().child('uploads/${DateTime.now().toIso8601String()}.png');
      await ref.putFile(imageFile);
      String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      return '';
    }
  }

  void _addQuestion() {
    setState(() {
      _questions.add({
        'question': '',
        'options': ['', '', '', ''],
        'correctAnswer': '',
        'imagePath': null,
      });
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay initialTime = TimeOfDay.now();
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? initialTime,
    );
    if (picked != null && picked != _selectedTime) {
      final bool isToday = _selectedDate?.isAtSameMomentAs(DateTime.now()) ?? false;
      if (isToday && (picked.hour < initialTime.hour || (picked.hour == initialTime.hour && picked.minute < initialTime.minute))) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please choose a time after the current time for today.')),
        );
        return;
      }
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveQuiz() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No user logged in.')),
      );
      return;
    }

    DatabaseReference teacherRef = FirebaseDatabase.instance.ref('TeacherDB/${user.email!.replaceAll('.', ',')}');
    DatabaseEvent event = await teacherRef.once();
    DataSnapshot snapshot = event.snapshot;
    String? nameValue = snapshot.child('name').value as String?;
    String teacherName = nameValue ?? '';

    CollectionReference quizzes = FirebaseFirestore.instance.collection('quizzes');
    Map<String, dynamic> quizData = {
      'title': _quizTitleController.text,
      'timeAllotted': _timeAllottedController.text,
      'availability': {
        'date': _selectedDate?.toIso8601String(),
        'time': _selectedTime?.format(context),
      },
      'questions': [],
      'teacherName': teacherName,
      'teacherEmail': user.email,
      'createdAt': DateTime.now(),
    };

    try {
      for (var question in _questions) {
        if (question['imagePath'] != null) {
          String imageUrl = await _uploadImage(File(question['imagePath']));
          question['imagePath'] = imageUrl;
        }
        quizData['questions'].add(question);
      }

      await quizzes.add(quizData);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Quiz saved successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save quiz.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Quiz',
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
                controller: _quizTitleController,
                decoration: InputDecoration(labelText: 'Quiz Title'),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _timeAllottedController,
                decoration: InputDecoration(labelText: 'Time Allotted (in minutes)'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedDate != null ? 'Date: ${_formatDate(_selectedDate!)}' : 'No date chosen!',
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: Text('Choose Date'),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedTime != null ? 'Time: ${_selectedTime!.format(context)}' : 'No time chosen!',
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectTime(context),
                    child: Text('Choose Time'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            decoration: InputDecoration(labelText: 'Question ${index + 1}'),
                            onChanged: (value) {
                              _questions[index]['question'] = value;
                            },
                          ),
                          TextField(
                            decoration: InputDecoration(labelText: 'Option A'),
                            onChanged: (value) {
                              _questions[index]['options'][0] = value;
                            },
                          ),
                          TextField(
                            decoration: InputDecoration(labelText: 'Option B'),
                            onChanged: (value) {
                              _questions[index]['options'][1] = value;
                            },
                          ),
                          TextField(
                            decoration: InputDecoration(labelText: 'Option C'),
                            onChanged: (value) {
                              _questions[index]['options'][2] = value;
                            },
                          ),
                          TextField(
                            decoration: InputDecoration(labelText: 'Option D'),
                            onChanged: (value) {
                              _questions[index]['options'][3] = value;
                            },
                          ),
                          TextField(
                            decoration: InputDecoration(labelText: 'Correct Answer'),
                            onChanged: (value) {
                              _questions[index]['correctAnswer'] = value;
                            },
                          ),
                          ElevatedButton(
                            onPressed: () => _pickImage(index),
                            child: Text('Pick Image'),
                          ),
                          SizedBox(height: 8.0),
                          _questions[index]['imagePath'] != null
                              ? Image.file(
                            File(_questions[index]['imagePath']),
                            height: 400,
                            width: 400,
                            fit: BoxFit.cover,
                          )
                              : Container(),
                          SizedBox(height: 10),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeQuestion(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addQuestion,
                child: Text(
                  'Add Question',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveQuiz,
                child: Text(
                  'Save Quiz',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
