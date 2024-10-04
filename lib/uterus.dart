import 'package:flutter/material.dart';
import 'package:zoom_hover_pinch_image/zoom_hover_pinch_image.dart';

class Uterus extends StatefulWidget {
  @override
  _UterusState createState() => _UterusState();
}

class _UterusState extends State<Uterus> {
  final List<Map<String, String>> images = [
    {
      'url': 'assets/images/uterus_quiz_1.png',
      'description': 'Description of Uterus Image 1',
    },
    // Additional images can be added here.
  ];

  int _currentIndex = 0;

  void _nextImage() {
    if (_currentIndex < images.length - 1) {
      setState(() {
        _currentIndex++;
      });
    }
  }

  void _previousImage() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Uterus')),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center items vertically
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9, // Set width to 90% of the screen width
                height: MediaQuery.of(context).size.width * 0.9, // Maintain aspect ratio with height
                child: Zoom(
                  // Using the Zoom widget to display the image
                  child: Image.asset(images[_currentIndex]['url']!),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                images[_currentIndex]['description']!,
                textAlign: TextAlign.center,
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Pinch to zoom', // Caption text
                textAlign: TextAlign.center,
                style: TextStyle(fontStyle: FontStyle.italic), // Optional: italic style for emphasis
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentIndex > 0) // Show back button only if not on first image
                  TextButton(
                    onPressed: _previousImage,
                    child: Text('Back'),
                  ),
                if (_currentIndex < images.length - 1) // Show next button only if not on last image
                  TextButton(
                    onPressed: _nextImage,
                    child: Text('Next'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
