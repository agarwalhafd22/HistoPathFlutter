import 'package:flutter/material.dart';
import 'package:group_button/group_button.dart';
import 'uterus_quiz.dart'; // Import the UterusQuiz class
import 'uterus.dart';

class FemaleReproductiveSystem extends StatefulWidget {
  @override
  _FemaleReproductiveSystemState createState() => _FemaleReproductiveSystemState();
}

class _FemaleReproductiveSystemState extends State<FemaleReproductiveSystem> {
  bool isQuizVisible = false;
  bool isNextVisible = false;
  String selectedTopic = "";

  void _showQuizOptions() {
    setState(() {
      isQuizVisible = true;
    });
  }

  void _hideQuizOptions() {
    setState(() {
      isQuizVisible = false;
      isNextVisible = false;
      selectedTopic = "";
    });
  }

  void _selectTopic(String topic) {
    setState(() {
      selectedTopic = topic;
      isNextVisible = true;
    });
  }

  void _goToQuiz(BuildContext context) {
    if (selectedTopic == "Uterus") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UterusQuiz()), // Navigate to UterusQuiz
      );
    } else if (selectedTopic == "Breast") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BreastQuiz()), // Replace with your BreastQuiz page
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              // Check if the device is in landscape mode or web view
              bool isLandscapeOrWebView = constraints.maxWidth > constraints.maxHeight;

              return Padding(
                padding: const EdgeInsets.all(16.0), // Add padding to the body
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center, // Center align items
                  children: [
                    SizedBox(height: 40), // Add space from the top
                    Wrap( // Use Wrap widget to allow cards to flow
                      alignment: WrapAlignment.center, // Center align items in wrap
                      spacing: 16.0, // Space between cards
                      children: [
                        _buildCard("Uterus", () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Uterus()), // Directly navigate to UterusQuiz
                          );
                        }, 'assets/images/uterus.jpg'),
                        _buildCard("Breast", () => _selectTopic("Breast"), 'assets/images/breast.jpg'),
                      ],
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
          if (isQuizVisible) // Show overlay if quiz options are visible
            Container(
              color: Colors.white.withOpacity(0.7), // White background with 70% opacity
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Determine the width based on orientation
                    double cardWidth;
                    bool isLandscapeOrWebView = constraints.maxWidth > constraints.maxHeight;

                    if (isLandscapeOrWebView) {
                      cardWidth = constraints.maxWidth * 0.35; // 35% width for landscape/web
                    } else {
                      cardWidth = constraints.maxWidth * 0.90; // 90% width for portrait
                    }

                    return Card(
                      elevation: 8,
                      child: Container(
                        width: cardWidth,
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Choose a Topic",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            GroupButton(
                              buttons: ["Uterus", "Breast"], // Define the options
                              onSelected: (String label, int index, bool isSelected) {
                                if (isSelected) {
                                  _selectTopic(label); // Update the selected topic
                                }
                              },
                              isRadio: true, // Toggle buttons will act as radio buttons
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: _hideQuizOptions,
                                  child: Text("Back"),
                                ),
                                if (isNextVisible)
                                  TextButton(
                                    onPressed: () => _goToQuiz(context),
                                    child: Text("Next"),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showQuizOptions,
        backgroundColor: Colors.red, // Set background color to red
        child: Text(
          "Quiz",
          style: TextStyle(color: Colors.white), // Set text color to white
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // Position at the bottom right corner
    );
  }

  Widget _buildCard(String title, VoidCallback onTap, String imagePath) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.all(8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 8,
        child: Container(
          width: 120, // Card width
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Image.asset(
                imagePath, // Use the provided image path
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Placeholder classes for quizzes
class BreastQuiz extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Breast Quiz")),
      body: Center(child: Text("Breast Quiz Content")),
    );
  }
}
