import 'package:flutter/material.dart';
import 'dart:io';
import '../utils/face_detector_painter.dart';
import '../components/camera.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceRecognition extends StatefulWidget {
  const FaceRecognition({Key? key, required this.studentName})
      : super(key: key);

  final String? studentName;

  @override
  State<FaceRecognition> createState() => _FaceRecognitionState();
}

class _FaceRecognitionState extends State<FaceRecognition> {
  File? _capturedImageFile;

  final FaceDetector _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
          enableTracking: true,
          enableClassification: true,
          enableContours: true));

  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;

  @override
  void dispose() {
    _canProcess = false;
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _capturedImageFile != null
        ? Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor:
                  _capturedImageFile != null ? Colors.white : Colors.black87,
              title: const Text("Verify Student Identity"),
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back,
                    color: (_capturedImageFile != null)
                        ? Colors.black
                        : Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            body: Stack(children: [
              Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Text(
                          "Take Pictures",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: _capturedImageFile != null
                            ? const Text("Make sure the picture is clear",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xff369E89),
                                  fontSize: 17,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Color(0xff369E89),
                                ))
                            : const Text(
                                'Image',
                                style: TextStyle(
                                  color: Color(0xff369E89),
                                  fontSize: 15,
                                ),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: InkWell(
                          splashColor: const Color(0xff369E89),
                          onTap: () =>
                              setState(() => _capturedImageFile = null),
                          child: Ink.image(
                            width: 300,
                            height: 250,
                            fit: BoxFit.contain,
                            image: FileImage(_capturedImageFile!),
                          ),
                        ),
                      ),
                      // Note pour Fama: ajouter un boutton pour soumettre l'image a l'api
                    ],
                  ),
                ),
              ),
            ]))
        : CameraView(
            source: 'recognize',
            customPaint: _customPaint,
            onImage: (inputImage) {
              processImage(inputImage);
            },
            onCapture: (file) {
              setState(() {
                _capturedImageFile = file;
              });
            },
            initialDirection: CameraLensDirection.back,
          );
  }

  Future<dynamic> processImage(final InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    final faces = await _faceDetector.processImage(inputImage);
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null &&
        faces.isNotEmpty) {
      final painter = FaceDetectorPainter(
          faces[0],
          inputImage.inputImageData!.size,
          inputImage.inputImageData!.imageRotation);
      _customPaint = CustomPaint(painter: painter);
    } else {
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
