import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_histo_path/uterus.dart';

class UterusPath extends StatefulWidget {
  @override
  _UterusPathState createState() => _UterusPathState();
}

class _UterusPathState extends State<UterusPath> {
  final List<Map<String, dynamic>> points = [
    {
      'left': 300.0,
      'top': 143.0,
      'color': Colors.red,
      'description': 'Tall columnar lining',
    },
    {
      'left': 270.0,
      'top': 170.0,
      'color': Colors.blue,
      'description': 'stroma',
    },
    {
      'left': 310.0,
      'top': 215.0,
      'color': Colors.green,
      'description': 'The cells filled with mucin with basally pushed nucleus',
    },
    // {
    //   'left': 130.0,
    //   'top': 265.0,
    //   'color': Colors.purple,
    //   'description': 'Uterine glands: Tubular glands which become more coiled in the secretory phase of the menstrual cycle',
    // },
  ];

  int _currentPointIndex = 0;
  bool _isStarted = false; // Track if the process has started
  final TransformationController _transformationController = TransformationController();
  String _imageUrl = ""; // State variable to store the image URL

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _loadImageFromFirebase(); // Load the image URL once
  }

  Future<void> _loadImageFromFirebase() async {
    try {
      // Get the download URL from Firebase Storage
      final Reference storageRef = FirebaseStorage.instance.ref().child('uterus/patho/mucinous cystadenoma 1.jpg');
      String downloadUrl = await storageRef.getDownloadURL();
      setState(() {
        _imageUrl = downloadUrl; // Store the image URL in state
      });
    } catch (e) {
      print("Error loading image: $e");
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _transformationController.dispose();
    super.dispose();
  }

  void _zoomToPoint(int index) {
    final double scaleFactor = 2.0; // Scale factor for zoom
    final double imageWidth = MediaQuery.of(context).size.width * 0.9;
    final double imageHeight = MediaQuery.of(context).size.width * 0.9;

    // Calculate translation for zooming into the current point
    final double xTranslation = -points[index]['left']! * scaleFactor + (imageWidth / 2);
    final double yTranslation = -points[index]['top']! * scaleFactor + (imageHeight / 2);

    // Set the transformation matrix with a delay for smooth transition
    Future.delayed(Duration(milliseconds: 300), () {
      setState(() {
        _transformationController.value = Matrix4.identity()
          ..translate(xTranslation, yTranslation)
          ..scale(scaleFactor);
      });
    });
  }

  void _nextPoint() {
    if (_currentPointIndex < points.length - 1) {
      setState(() {
        _currentPointIndex++;
      });
      _zoomToPoint(_currentPointIndex);
    }
  }

  void _previousPoint() {
    if (_currentPointIndex > 0) {
      setState(() {
        _currentPointIndex--;
      });
      _zoomToPoint(_currentPointIndex);
    }
  }

  void _startProcess() {
    setState(() {
      _isStarted = true; // Set started state to true
      _currentPointIndex = 0; // Reset to the first point
    });
    _zoomToPoint(_currentPointIndex); // Zoom to the first point
  }

  void _finishProcess() {
    setState(() {
      _isStarted = false; // Reset started state
      _currentPointIndex = 0; // Reset to the first point
      _transformationController.value = Matrix4.identity(); // Reset zoom
    });
  }

  void _toggleSection() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => UterusPath()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Switch to Histology',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.left,
        ),
        automaticallyImplyLeading: false, // Set to false to prevent the default back button
        backgroundColor: Colors.red,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white, // Set the back arrow color to white
          ),
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back when the button is pressed
          },
        ),
      ),

      body: _imageUrl.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Top half for the image
          Expanded(
            flex: 2,
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: InteractiveViewer(
                transformationController: _transformationController,
                panEnabled: true,
                boundaryMargin: EdgeInsets.all(20),
                minScale: 1.0,
                maxScale: 5.0,
                child: Stack(
                  children: [
                    Center(
                      child: Image.network(
                        _imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Display all points
                    ...points.map((point) {
                      final index = points.indexOf(point);
                      return Positioned(
                        left: point['left']!,
                        top: point['top']!,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              if (_isStarted) {
                                setState(() {
                                  _currentPointIndex = index;
                                });
                                _zoomToPoint(_currentPointIndex);
                              }
                            },
                            borderRadius: BorderRadius.circular(50),
                            splashColor: Colors.white.withOpacity(0.5),
                            child: TweenAnimationBuilder<double>(
                              duration: Duration(milliseconds: 300),
                              tween: Tween<double>(
                                  begin: 1.0,
                                  end: index == _currentPointIndex ? 1.5 : 1.0),
                              builder: (context, scale, child) {
                                return Transform.scale(
                                  scale: scale,
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.location_on,
                                      color: point['color'],
                                      size: 30,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
          // Bottom half for the description dialog
          _buildBottomDialog(),
        ],
      ),
    );
  }

  // Helper method to build the bottom dialog
  Widget _buildBottomDialog() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.30, // Set height to 40% of the screen
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Mucinous cystadenoma',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          // SizedBox(height: 8),
          // Text(
          //   'High Magnification',
          //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
          //   textAlign: TextAlign.center,
          // ),
          SizedBox(height: 16),
          Text(
            _isStarted
                ? points[_currentPointIndex]['description']
                : 'The cyst is lined by a single layer of cells having basal nuclei and apical mucinous vacuoles. There is no invasion or papillae formation. There is no atypia or necrosis',
            style: TextStyle(fontSize: 16, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: _isStarted ? _previousPoint : null,
                child: Text('Previous'),
              ),
              ElevatedButton(
                onPressed: _isStarted ? _nextPoint : _startProcess,
                child: Text(_isStarted ? 'Next' : 'Start'),
              ),
              ElevatedButton(
                onPressed: _isStarted ? _finishProcess : null,
                child: Text('Finish'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
