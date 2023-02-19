import 'package:flutter/material.dart';
import 'dart:io';
import '../utils/face_detector_painter.dart';
import '../components/camera.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceRegistration extends StatefulWidget {
  const FaceRegistration({Key? key, required this.studentName})
      : super(key: key);

  final String studentName;

  @override
  State<FaceRegistration> createState() => _FaceRegistrationState();
}

class _FaceRegistrationState extends State<FaceRegistration> {
  final FaceDetector _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
          enableTracking: true,
          enableClassification: true,
          enableContours: true));

  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;

  @override
  void initState() {}

  @override
  void dispose() {
    _canProcess = false;
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CameraView(
      source: 'register',
      customPaint: _customPaint,
      onImage: (inputImage) {
        processImage(inputImage);
      },
      initialDirection: CameraLensDirection.back,
      studentName: widget.studentName,
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
