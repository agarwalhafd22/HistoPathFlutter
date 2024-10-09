import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_histo_path/large_path.dart';
import 'package:flutter_histo_path/uterus_path.dart';

class LargeIntestine extends StatefulWidget {
  @override
  _LargeIntestineState createState() => _LargeIntestineState();
}

class _LargeIntestineState extends State<LargeIntestine> {
  final List<Map<String, dynamic>> points = [
    {
      'left': 150.0,
      'top': 300.0,
      'color': Colors.red,
      'description': 'Submucosa containing connective tissue',
    },
    {
      'left': 150.0,
      'top': 210.0,
      'color': Colors.green,
      'description': 'Crypts of Lieberkuhn: They are also intestinal glands contains abundant goblet cells',
    },
    {
      'left': 200.0,
      'top': 265.0,
      'color': Colors.purple,
      'description': 'Muscularis mucosa containing smooth muscles',
    },
  ];

  int _currentPointIndex = 0;
  bool _isStarted = false;
  final TransformationController _transformationController = TransformationController();
  String _imageUrl = "";

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _loadImageFromFirebase();
  }

  Future<void> _loadImageFromFirebase() async {
    try {
      final Reference storageRef = FirebaseStorage.instance.ref().child('gastro/largeintestine/histo/GIT_Large intestine_High magnification.png');
      String downloadUrl = await storageRef.getDownloadURL();
      setState(() {
        _imageUrl = downloadUrl;
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
    final double scaleFactor = 2.0;
    final double imageWidth = MediaQuery.of(context).size.width * 0.9;
    final double imageHeight = MediaQuery.of(context).size.width * 0.9;
    final double xTranslation = -points[index]['left']! * scaleFactor + (imageWidth / 2);
    final double yTranslation = -points[index]['top']! * scaleFactor + (imageHeight / 2);

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
      _isStarted = true;
      _currentPointIndex = 0;
    });
    _zoomToPoint(_currentPointIndex);
  }

  void _finishProcess() {
    setState(() {
      _isStarted = false;
      _currentPointIndex = 0;
      _transformationController.value = Matrix4.identity();
    });
  }

  void _toggleSection() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => LargePath()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '',
          style: TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.red,
        centerTitle: false,
        actions: [
          Text(
            'Switch to Pathology',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward, color: Colors.white),
            onPressed: _toggleSection,
          ),
        ],
      ),
      body: _imageUrl.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
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
          Expanded(
            flex: 1,
            child: DraggableScrollableSheet(
              initialChildSize: 0.46,
              minChildSize: 0.3,
              maxChildSize: 1.0,
              builder: (context, scrollController) {
                return Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 8,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        Text(
                          'Large Intestine',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'High Magnification',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        Text(
                          _isStarted
                              ? points[_currentPointIndex]['description']
                              : 'Under higher magnification, the mucosa of the large intestine shows the crypts of Leiberkuhn with their lining cells, those are the columnar cells and goblet cells. The goblet cells appear empty to basophillic due to the mucin content which washes off during staining process. The connective tissue in the submucosa appear to contain nerve plexus, lymphoid follicles and connective tissue.',
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
                              onPressed: _isStarted && _currentPointIndex < points.length - 1 ? _nextPoint : _startProcess,
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
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
