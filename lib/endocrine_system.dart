import 'package:flutter/material.dart';
import 'package:group_button/group_button.dart';

class EndocrineSystem extends StatefulWidget {
  @override
  _EndocrineSystemState createState() => _EndocrineSystemState();
}

class _EndocrineSystemState extends State<EndocrineSystem> {
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
    if (selectedTopic == "Thyroid") {
      // Navigate to colonQuiz
    }
    // else if (selectedTopic == "Appendix") {
    //   // Navigate to appendixQuiz
    // } else if (selectedTopic == "Liver") {
    //   // Navigate to liverQuiz
    // } else if (selectedTopic == "Large Intestine") {
    //   // Navigate to largeIntestineQuiz
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          "Endocrine System",
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
                    crossAxisAlignment: CrossAxisAlignment.center, // Center content horizontally
                    mainAxisAlignment: MainAxisAlignment.start, // Start content below the AppBar
                    children: [
                      SizedBox(height: 20),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 16.0,
                        runSpacing: 16.0,
                        children: [
                          _buildCard("Thyroid", () => _selectTopic("Thyroid"), "assets/images/thyroid.png"),
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
          width: 140, // Slightly reduced size
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.asset(
                  imagePath,
                  height: 100, // Slightly reduced size
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
