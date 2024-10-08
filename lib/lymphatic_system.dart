import 'package:flutter/material.dart';
import 'package:group_button/group_button.dart';

class LymphaticSystem extends StatefulWidget {
  @override
  _LymphaticSystemState createState() => _LymphaticSystemState();
}

class _LymphaticSystemState extends State<LymphaticSystem> {
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

  void _goToQuiz() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          "Lymphatic System",
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 0),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 16.0,
                      runSpacing: 16.0,
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
                              buttons: ["Colon", "Appendix", "Liver", "Large Intestine"],
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
          width: 120,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Image.asset(
                imagePath,
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
