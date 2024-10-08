import 'dart:io';
import 'package:flutter/foundation.dart'; // Import for kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import for Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Import for Firebase Auth
import 'package:firebase_database/firebase_database.dart'; // Import for Firebase Database
import 'package:firebase_storage/firebase_storage.dart'; // Import for Firebase Storage

class CreateQuiz extends StatefulWidget {
  @override
  _CreateQuizState createState() => _CreateQuizState();
}

class _CreateQuizState extends State<CreateQuiz> {
  final TextEditingController _quizTitleController = TextEditingController();
  final TextEditingController _timeAllottedController = TextEditingController(); // Controller for time allotted
  final List<Map<String, dynamic>> _questions = [];
  final ImagePicker _picker = ImagePicker();

  DateTime? _selectedDate; // Variable to hold the selected date
  TimeOfDay? _selectedTime; // Variable to hold the selected time

  // Function to format the date
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}'; // Format to DD/MM/YYYY
  }

  Future<void> _pickImage(int questionIndex) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // Save the image path instead of uploading it immediately
      setState(() {
        _questions[questionIndex]['imagePath'] = image.path; // Store the local file path
      });
    }
  }

  Future<String> _uploadImage(File imageFile) async {
    try {
      // Create a reference to the storage bucket
      final ref = FirebaseStorage.instance.ref().child('uploads/${DateTime.now().toIso8601String()}.png');

      // Upload the file to Firebase Storage
      await ref.putFile(imageFile);

      // Get the download URL
      String downloadUrl = await ref.getDownloadURL();
      print('File uploaded successfully: $downloadUrl');
      return downloadUrl; // Return the download URL
    } catch (e) {
      print('Error uploading image: $e');
      return ''; // Return an empty string on error
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
    final DateTime now = DateTime.now(); // Current date and time
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now, // Prevent picking a past date
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    // Set initial time to current time
    final TimeOfDay initialTime = TimeOfDay.now();
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? initialTime,
    );
    if (picked != null && picked != _selectedTime) {
      final bool isToday = _selectedDate?.isAtSameMomentAs(DateTime.now()) ?? false;

      // Only allow picking times based on the selected date
      if (isToday && (picked.hour < initialTime.hour || (picked.hour == initialTime.hour && picked.minute < initialTime.minute))) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please choose a time after the current time for today.')),
        );
        return;
      } else if (!isToday && (picked.hour < initialTime.hour || (picked.hour == initialTime.hour && picked.minute < initialTime.minute))) {
        // If the date is in the future, allow any time selection
        setState(() {
          _selectedTime = picked;
        });
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

    // Get the teacher's name from the Realtime Database
    DatabaseReference teacherRef = FirebaseDatabase.instance.ref('TeacherDB/${user.email!.replaceAll('.', ',')}');

    // Fetch data from the reference
    DatabaseEvent event = await teacherRef.once();
    DataSnapshot snapshot = event.snapshot;

    // Safely retrieve the teacher's name
    String? nameValue = snapshot.child('name').value as String?;
    String teacherName = nameValue ?? ''; // Handle the case where 'name' is null

    // The rest of your save logic...

    // Get a reference to the Firestore collection
    CollectionReference quizzes = FirebaseFirestore.instance.collection('quizzes');

    // Create a map to hold the quiz data
    Map<String, dynamic> quizData = {
      'title': _quizTitleController.text,
      'timeAllotted': _timeAllottedController.text,
      'availability': {
        'date': _selectedDate?.toIso8601String(),
        'time': _selectedTime?.format(context),
      },
      'questions': [], // Initialize an empty list for questions
      'teacherName': teacherName, // Use the retrieved teacher's name
      'teacherEmail': user.email,
      'createdAt': DateTime.now(), // Store the current date and time
    };

    try {
      // Log quiz data before saving
      print('Quiz Data: $quizData');

      // Loop through questions and upload images if they exist
      for (var question in _questions) {
        if (question['imagePath'] != null) {
          String imageUrl = await _uploadImage(File(question['imagePath'])); // Upload image
          question['imagePath'] = imageUrl; // Save the URL
        }
        quizData['questions'].add(question); // Add question to quiz data
      }

      // Add the quiz data to Firestore
      await quizzes.add(quizData);
      // Show a success message
      print('Quiz saved successfully!'); // Log success
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Quiz saved successfully!')));
    } catch (e) {
      // Handle any errors
      print('Error saving quiz: $e'); // More detailed error logging
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save quiz.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Quiz',
          style: TextStyle(color: Colors.white), // Set the font color to white
        ),
        backgroundColor: Colors.red, // Set the app bar color to red
        automaticallyImplyLeading: false, // Remove the back arrow
      ),
      body: SingleChildScrollView( // Make the entire content scrollable
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
                controller: _timeAllottedController, // Input for time allotted
                decoration: InputDecoration(labelText: 'Time Allotted (in minutes)'),
                keyboardType: TextInputType.number, // Numeric input for time
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedDate != null
                          ? 'Date: ${_formatDate(_selectedDate!)}' // Use the new format method
                          : 'No date chosen!',
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
                      _selectedTime != null
                          ? 'Time: ${_selectedTime!.format(context)}' // Format the time
                          : 'No time chosen!',
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
                physics: NeverScrollableScrollPhysics(), // Disable scrolling for the ListView
                shrinkWrap: true, // Allow ListView to take up only necessary space
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
                            onPressed: () => _pickImage(index), // Modify to pass index
                            child: Text('Pick Image'),
                          ),
                          SizedBox(height: 8.0),
                          // Display image preview if available
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
                  style: TextStyle(color: Colors.white), // Change text color to white
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Button background color
                  foregroundColor: Colors.white, // Button text color
                ),
              ),

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveQuiz,
                child: Text(
                  'Save Quiz',
                  style: TextStyle(color: Colors.white), // Change text color to white
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Button background color
                  foregroundColor: Colors.white, // Button text color
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
