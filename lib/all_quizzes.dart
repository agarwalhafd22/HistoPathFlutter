import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllQuizzes extends StatefulWidget {
  @override
  _AllQuizzesState createState() => _AllQuizzesState();
}

class _AllQuizzesState extends State<AllQuizzes> {

  Future<Map<String, List<Map<String, dynamic>>>> _fetchQuizzesByTeachers() async {
    Map<String, List<Map<String, dynamic>>> quizzesByTeachers = {};


    QuerySnapshot quizSnapshot = await FirebaseFirestore.instance.collection('quizzes').get();

    for (var doc in quizSnapshot.docs) {
      Map<String, dynamic> quizData = doc.data() as Map<String, dynamic>;

      String teacherName = quizData['teacherName'];


      if (!quizzesByTeachers.containsKey(teacherName)) {
        quizzesByTeachers[teacherName] = [];
      }


      quizzesByTeachers[teacherName]!.add(quizData);
    }

    return quizzesByTeachers;
  }


  void _navigateToQuizDetails(Map<String, dynamic> quiz) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizDetails(quiz: quiz),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All Quizzes',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // Bold font and white color
        ),
        backgroundColor: Colors.red,
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
        future: _fetchQuizzesByTeachers(),
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

          Map<String, List<Map<String, dynamic>>> quizzesByTeachers = snapshot.data!;

          return ListView(
            children: quizzesByTeachers.entries.map((entry) {
              String teacherName = entry.key;
              List<Map<String, dynamic>> quizzes = entry.value;

              return ExpansionTile(
                title: Text(teacherName),
                children: quizzes.map((quiz) {
                  return ListTile(
                    title: Text(quiz['title']),
                    subtitle: Text('Created on: ${quiz['createdAt'].toDate().toLocal()}'),
                    onTap: () => _navigateToQuizDetails(quiz),
                  );
                }).toList(),
              );
            }).toList(),
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
                            Image.network(question['imagePath']),
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