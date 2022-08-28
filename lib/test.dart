import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:camera/camera.dart';
//import 'package:google_ml_vision/google_ml_vision.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  cameras = await availableCameras();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Face Mask Detection',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Face Mask Detection Page'),
    );
  }
}

//
//
//
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _frame_counter = 0;
  List<Face> faces = [];
  int _number_of_faces = 0;
  String _boundbox_of_faces = '';
  List<Position> position = [];
  Map<String, double> _position = {
    'x': 50,
    'y': 50,
    'w': 200,
    'h': 300,
  };

  CameraController controller =
      CameraController(cameras[0], ResolutionPreset.medium);
  CameraImage? cameraImage;
  String result = "";
  FaceDetector faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
    ),
  );

  initCamera() {
    controller.initialize().then((value) {
      if (!mounted) return;
      setState(() {
        controller.startImageStream((imageStream) {
          //cameraImage = imageStream;
          runCamera(imageStream);
        });
      });
    });
  }

  void runModel(int number_of_faces, String boundbox_of_faces) {
    setState(() {
      _number_of_faces = number_of_faces;
      _boundbox_of_faces = boundbox_of_faces;
    });
  }

  void runCamera(CameraImage cameraImage) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in cameraImage.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
        Size(cameraImage.width.toDouble(), cameraImage.height.toDouble());

    final camera = cameras[0];
    final inputImageRotation =
        InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    if (inputImageRotation == null) return;

    final inputImageFormat =
        InputImageFormatValue.fromRawValue(cameraImage.format.raw);
    if (inputImageFormat == null) return;

    final planeData = cameraImage.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: inputImageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );
    final inputImage =
        InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

    faces = await faceDetector.processImage(inputImage);
    String boundbox_of_faces = '';
    for (final face in faces) {
      boundbox_of_faces += 'face: ${face.boundingBox}';
    }
    if (_frame_counter % 5 == 0) {
      runModel(faces.length, boundbox_of_faces);
    }
    _frame_counter += 1;
  }

  @override
  void initState() {
    initCamera();
    super.initState();
  }

  void _cameraPressed() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                height: MediaQuery.of(context).size.height - 170,
                width: MediaQuery.of(context).size.width,
                child: !controller.value.isInitialized
                    ? Container()
                    : AspectRatio(
                        aspectRatio: controller.value.aspectRatio,
                        child: CameraPreview(controller),
                      ),
              ),
            ),
            Positioned(
              left: _position['x'],
              top: _position['y'],
              child: InkWell(
                child: Container(
                  width: _position['w'],
                  height: _position['h'],
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 2,
                      color: Colors.blue,
                    ),
                  ),
                  /*
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      color: Colors.blue,
                      child: Text(
                        'hourse -71%',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  */
                ),
              ),
            ),
            Text(
              '$_boundbox_of_faces',
            ),
            Text(
              '$_frame_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
    );
  }
}
