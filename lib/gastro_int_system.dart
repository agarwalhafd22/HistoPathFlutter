import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:slide_scholar/appendix.dart';
import 'package:group_button/group_button.dart';
// import 'package:flutter_prevent_screenshot/disablescreenshot.dart';
import 'large_intestine.dart';
import 'liver.dart';

class GastroIntSystem extends StatefulWidget {
  @override
  _GastroIntSystemState createState() => _GastroIntSystemState();
}

class _GastroIntSystemState extends State<GastroIntSystem> {
  bool isQuizVisible = false;
  bool isNextVisible = false;
  String selectedTopic = "";
  String selectedAction = ""; // Track which action was selected

  @override
  void initState(){
    super.initState();
    // FlutterPreventScreenshot.instance.screenshotOff();
  }

  void _showQuizOptions(String action) {
    setState(() {
      isQuizVisible = true;
      selectedAction = action; // Set the action based on the button pressed
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
    if (selectedAction == "Quiz") {
      _navigateToQuiz();
    } else if (selectedAction == "HandDrawnImages") {
      _navigateToHandDrawnImages();
    }
  }

  void _navigateToQuiz() {
    if (selectedTopic == "Large Intestine") {
      // Navigate to Large Intestine quiz screen
    } else if (selectedTopic == "Appendix") {
      // Navigate to Appendix quiz screen
    } else if (selectedTopic == "Liver") {
      // Navigate to Liver quiz screen
    }
  }

  void _navigateToHandDrawnImages() {
    if (selectedTopic == "Large Intestine") {
      List<Map<String, String>> images = [
        {'path': 'assets/images/largeintestinehanddrawn.jpg', 'caption': 'Histology View'},
        {'path': 'assets/images/largeintestinehanddrawn2.jpg', 'caption': 'Pathology View'},
        // Add more images and captions as needed
      ];
      int currentIndex = 0;

      void _showImageDialog(int index) {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Blurs the background
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: SingleChildScrollView( // Make dialog scrollable
                      child: Container(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: InteractiveViewer(
                                boundaryMargin: EdgeInsets.all(8.0),
                                minScale: 1.0,
                                maxScale: 4.0, // Adjust max scale as needed
                                child: Image.asset(
                                  images[currentIndex]['path']!, // Display the current image
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              images[currentIndex]['caption']!, // Display the caption
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (currentIndex > 0)
                                  IconButton(
                                    icon: Icon(Icons.arrow_back),
                                    onPressed: () {
                                      setState(() {
                                        currentIndex--;
                                      });
                                    },
                                  ),
                                Spacer(),
                                if (currentIndex < images.length - 1)
                                  IconButton(
                                    icon: Icon(Icons.arrow_forward),
                                    onPressed: () {
                                      setState(() {
                                        currentIndex++;
                                      });
                                    },
                                  ),
                              ],
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(), // Close the dialog
                              child: Text("Close", style: TextStyle(color: Color(0xFF052e62))),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      }

      _showImageDialog(currentIndex);
    } else if (selectedTopic == "Appendix") {
      List<Map<String, String>> images = [
        {'path': 'assets/images/appendixhanddrawn.jpg', 'caption': 'Histology View'},
        {'path': 'assets/images/appendixhanddrawn2.jpg', 'caption': 'Pathology View'},
        // Add more images and captions as needed
      ];
      int currentIndex = 0;

      void _showImageDialog(int index) {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Blurs the background
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: SingleChildScrollView( // Make dialog scrollable
                      child: Container(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: InteractiveViewer(
                                boundaryMargin: EdgeInsets.all(8.0),
                                minScale: 1.0,
                                maxScale: 4.0, // Adjust max scale as needed
                                child: Image.asset(
                                  images[currentIndex]['path']!, // Display the current image
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              images[currentIndex]['caption']!, // Display the caption
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (currentIndex > 0)
                                  IconButton(
                                    icon: Icon(Icons.arrow_back),
                                    onPressed: () {
                                      setState(() {
                                        currentIndex--;
                                      });
                                    },
                                  ),
                                Spacer(),
                                if (currentIndex < images.length - 1)
                                  IconButton(
                                    icon: Icon(Icons.arrow_forward),
                                    onPressed: () {
                                      setState(() {
                                        currentIndex++;
                                      });
                                    },
                                  ),
                              ],
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(), // Close the dialog
                              child: Text("Close", style: TextStyle(color: Color(0xFF052e62))),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      }

      _showImageDialog(currentIndex);
    } else if (selectedTopic == "Liver") {
      List<Map<String, String>> images = [
        {'path': 'assets/images/liverhanddrawn.jpg', 'caption': 'Histology View'},
        {'path': 'assets/images/liverhanddrawn2.jpg', 'caption': 'Pathology View'},
        // Add more images and captions as needed
      ];
      int currentIndex = 0;

      void _showImageDialog(int index) {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Blurs the background
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: SingleChildScrollView( // Make dialog scrollable
                      child: Container(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: InteractiveViewer(
                                boundaryMargin: EdgeInsets.all(8.0),
                                minScale: 1.0,
                                maxScale: 4.0, // Adjust max scale as needed
                                child: Image.asset(
                                  images[currentIndex]['path']!, // Display the current image
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              images[currentIndex]['caption']!, // Display the caption
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (currentIndex > 0)
                                  IconButton(
                                    icon: Icon(Icons.arrow_back),
                                    onPressed: () {
                                      setState(() {
                                        currentIndex--;
                                      });
                                    },
                                  ),
                                Spacer(),
                                if (currentIndex < images.length - 1)
                                  IconButton(
                                    icon: Icon(Icons.arrow_forward),
                                    onPressed: () {
                                      setState(() {
                                        currentIndex++;
                                      });
                                    },
                                  ),
                              ],
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(), // Close the dialog
                              child: Text("Close", style: TextStyle(color: Color(0xFF052e62))),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );

      }

      _showImageDialog(currentIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF052e62),
        title: Text(
          "Gastrointestinal System",
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
                          _buildCard("Large Intestine", () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => LargeIntestine()),
                            );
                          }, 'assets/images/largeintestine.jpg'),
                          _buildCard("Appendix", () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Appendix()),
                            );
                          }, "assets/images/appendix.jpeg"),
                          _buildCard("Liver", () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Liver()),
                            );
                          }, "assets/images/liver.jpg"),
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
                              buttons: ["Large Intestine", "Appendix", "Liver"],
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton.extended(
              onPressed: () => _showQuizOptions("Quiz"),
              backgroundColor: Color(0xFF052e62),
              label: Text(
                "Quiz",
                style: TextStyle(color: Colors.white),
              ),
            ),
            FloatingActionButton.extended(
              onPressed: () => _showQuizOptions("HandDrawnImages"),
              backgroundColor: Color(0xFF052e62),
              label: Text(
                "Hand drawn Images",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
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
