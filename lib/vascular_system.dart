import 'package:flutter/material.dart';
import 'package:group_button/group_button.dart';

class VascularSystem extends StatefulWidget {
  @override
  _VascularSystemState createState() => _VascularSystemState();
}

class _VascularSystemState extends State<VascularSystem> {
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

  void _goToQuiz() {
    if (selectedTopic == "Colon") {
      // Navigate to colonQuiz
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => ColonQuiz()), // Replace with your ColonQuiz page
      // );
    } else if (selectedTopic == "Appendix") {
      // Navigate to appendixQuiz
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => AppendixQuiz()), // Replace with your AppendixQuiz page
      // );
    } else if (selectedTopic == "Liver") {
      // Navigate to liverQuiz
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => LiverQuiz()), // Replace with your LiverQuiz page
      // );
    }
    else if (selectedTopic == "Large Intestine") {
      // Navigate to liverQuiz
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => LargeIntestineQuiz()), // Replace with your LiverQuiz page
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red, // Set the AppBar background color to red
        title: Text(
          "Vascular System", // Set the AppBar title
          style: TextStyle(color: Colors.white), // Set the title color to white
        ),
        automaticallyImplyLeading: false, // Remove the back arrow
      ),
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return Padding(
                padding: const EdgeInsets.all(16.0), // Add padding to the body
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center, // Center align items
                  children: [
                    SizedBox(height: 0), // Add space from the top
                    Wrap(
                      alignment: WrapAlignment.center, // Align all items to the center
                      spacing: 16.0, // Horizontal space between cards
                      runSpacing: 16.0, // Vertical space between rows
                      children: [
                        _buildCard("Colon", () => _selectTopic("Colon"), "assets/images/colon.jpg"),
                        _buildCard("Appendix", () => _selectTopic("Appendix"), "assets/images/appendix.jpeg"),
                        _buildCard("Liver", () => _selectTopic("Liver"), "assets/images/liver.jpg"),
                        _buildCard("Large Intestine", () => _selectTopic("Large Intestine"), "assets/images/largeintestine.jpg"),
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
                              buttons: ["Colon", "Appendix", "Liver", "Large Intestine"], // Define the options
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
                                    onPressed: _goToQuiz,
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
