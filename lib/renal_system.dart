import 'package:flutter/material.dart';
import 'package:group_button/group_button.dart';

class RenalSystem extends StatefulWidget {
  @override
  _RenalSystemState createState() => _RenalSystemState();
}

class _RenalSystemState extends State<RenalSystem> {
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
    if (selectedTopic == "Kidney") {
      // Navigate to colonQuiz
    } else if (selectedTopic == "Ureter") {
      // Navigate to appendixQuiz
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          "Renal System",
          style: TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 16.0,
                        runSpacing: 16.0,
                        children: [
                          _buildCard("Kidney", () => _selectTopic("Kidney"), "assets/images/kidney.jpg"),
                          _buildCard("Ureter", () => _selectTopic("Ureter"), "assets/images/ureter.jpg"),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (isQuizVisible)
            Container(
              color: Colors.white.withOpacity(0.7),
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double cardWidth;
                    bool isLandscapeOrWebView = constraints.maxWidth > constraints.maxHeight;

                    if (isLandscapeOrWebView) {
                      cardWidth = constraints.maxWidth * 0.35;
                    } else {
                      cardWidth = constraints.maxWidth * 0.90;
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
                              buttons: ["Kidney", "Ureter"],
                              onSelected: (String label, int index, bool isSelected) {
                                if (isSelected) {
                                  _selectTopic(label);
                                }
                              },
                              isRadio: true,
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
        backgroundColor: Colors.red,
        child: Text(
          "Quiz",
          style: TextStyle(color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
          width: 140,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.asset(
                  imagePath,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
