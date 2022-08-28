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
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'dart:developer';

List<CameraDescription> cameras = [];
tfl.Interpreter? interpreter;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  cameras = await availableCameras();
  //interpreter = await tfl.Interpreter.fromAsset('assets/model.tflite');
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
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _frame_counter = 0;
  int _number_of_faces = 0;
  double _imageWidth = 0.0;
  double _imageHeight = 0.0;
  double _screenWidth = 0.0;
  double _screenHeight = 0.0;
  String _boundbox_of_faces = '';
  Map<String, double> _position = {
    'x': 0,
    'y': 0,
    'w': 0,
    'h': 0,
  };
  List<Face> faces = [];

  // Whether or not the rectangle is displayed
  bool _isRectangleVisible = true;
  bool _isCameraInitialized = false;
  bool _isCameraDetectioning = false;

  CameraController controller =
      CameraController(cameras[0], ResolutionPreset.high);
  CameraImage? cameraImage;
  String result = "";
  FaceDetector faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
    ),
  );

  void runCamera(CameraImage cameraImage) async {
    //if (_isCameraDetectioning) return;

    _frame_counter += 1;
    if ((_frame_counter % 10) != 0) return;

    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in cameraImage.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
        Size(cameraImage.width.toDouble(), cameraImage.height.toDouble());
    _imageWidth = cameraImage.width.toDouble();
    _imageHeight = cameraImage.height.toDouble();

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

    _isCameraDetectioning = true;
    faces = await faceDetector.processImage(inputImage);
    _isCameraDetectioning = false;

    String boundbox_of_faces = '';
    for (final face in faces) {
      boundbox_of_faces +=
          '[${face.boundingBox.left.toInt()} ${face.boundingBox.top.toInt()} ${face.boundingBox.width.toInt()} ${face.boundingBox.height.toInt()}]';
      log(boundbox_of_faces);
      runModel(faces.length, face, boundbox_of_faces);
      return;
    }
  }

  void runModel(int number_of_faces, Face face, String boundbox_of_faces) {
    setState(() {
      _number_of_faces = number_of_faces;
      _boundbox_of_faces = boundbox_of_faces;
      double ratioWidth = (_screenWidth / _imageWidth);
      double ratioHeight = (_screenHeight / _imageHeight);

      _position['x'] = face.boundingBox.left * ratioWidth;
      _position['y'] = face.boundingBox.top * ratioHeight;
      _position['w'] = face.boundingBox.width * ratioWidth;
      _position['h'] = face.boundingBox.height * ratioHeight;
      _isRectangleVisible = true;
    });
  }

  initCamera() {
    controller.initialize().then((value) {
      if (!mounted) return;
      controller.startImageStream((imageStream) {
        //cameraImage = imageStream;
        runCamera(imageStream);
        setState(() {
          _isCameraInitialized = true;
        });
      });
    });
  }

  stopCamera() {
    setState(() {
      _isCameraInitialized = true;
    });
    controller.stopImageStream();
  }

  void _cameraPressed() {
    setState(() {
      _isRectangleVisible = !_isRectangleVisible;
    });
  }

  @override
  void initState() {
    initCamera();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    setState(() {
      _isCameraInitialized = true;
    });
    controller.stopImageStream();
    //Tflite.close();
  }

  @override
  Widget build(BuildContext context) {
    _screenHeight = MediaQuery.of(context).size.height;
    _screenWidth = MediaQuery.of(context).size.width;
    if (!controller.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: !controller.value.isInitialized
                ? Container()
                : AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: CameraPreview(controller),
                  ),
          ),
        ),
        /*
        Text(
          '$_boundbox_of_faces',
        ),
        Text(
          '$_frame_counter',
          style: Theme.of(context).textTheme.headline4,
        ),
        */
        if (_isRectangleVisible)
          Positioned(
              left: _position['y'],
              top: _position['x'],
              child: InkWell(
                onTap: () {
                  setState(() {
                    _isRectangleVisible = false;
                  });
                },
                child: Container(
                  width: _position['w'],
                  height: _position['h'],
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 2,
                      color: Colors.blue,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      color: Colors.blue,
                      child: Text(
                        //'hourse -71%',
                        '$_boundbox_of_faces',
                        style: TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              )),
      ]),
      floatingActionButton: FloatingActionButton.large(
        onPressed: _cameraPressed,
        child: const Icon(Icons.camera),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
