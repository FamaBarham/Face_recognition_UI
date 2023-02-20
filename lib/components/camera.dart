import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import '../utils/face_overlay.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../main.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CameraView extends StatefulWidget {
  const CameraView(
      {Key? key,
      required this.source,
      this.studentName,
      this.customPaint,
      this.onImage,
      this.onCapture,
      this.initialDirection,
      this.imageResolution = ResolutionPreset.high})
      : super(key: key);

  final CustomPaint? customPaint;
  final Function(InputImage inputImage)? onImage;
  final CameraLensDirection? initialDirection;
  final ResolutionPreset imageResolution;
  final Function(File? file)? onCapture;
  final String? source;
  final String? studentName;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  CameraController? _controller;
  int _cameraIndex = 0;
  List<CameraDescription>? _cameras;
  List<String>? _images;

  @override
  void initState() {
    super.initState();
    _cameras = Camera.cameras;
    if (_cameras!.any((element) =>
        element.lensDirection == widget.initialDirection &&
        element.sensorOrientation == 90)) {
      _cameraIndex = _cameras!.indexOf(
        _cameras!.firstWhere((element) =>
            element.lensDirection == widget.initialDirection &&
            element.sensorOrientation == 90),
      );
    } else {
      _cameraIndex = _cameras!.indexOf(_cameras!.firstWhere(
          (element) => element.lensDirection == widget.initialDirection));
    }
    _startLive();
  }

  @override
  void dispose() {
    _stopLive();
    super.dispose();
  }

  Future _startLive() async {
    final camera = _cameras![_cameraIndex];
    _controller = CameraController(
      camera,
      widget.imageResolution,
      enableAudio: false,
    );
    _controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _controller?.startImageStream(_processCameraImage);
      setState(() {});
    });
  }

  Future _processCameraImage(final CameraImage image) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();
    final Size imageSize =
        Size(image.width.toDouble(), image.height.toDouble());

    final camera = _cameras![_cameraIndex];

    final imageRotation =
        InputImageRotationValue.fromRawValue(camera.sensorOrientation) ??
            InputImageRotation.rotation0deg;
    final inputImageFormat =
        InputImageFormatValue.fromRawValue(image.format.raw) ??
            InputImageFormat.nv21;

    final planeData = image.planes.map((final Plane plane) {
      return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width);
    }).toList();

    final inputImageData = InputImageData(
        size: imageSize,
        imageRotation: imageRotation,
        inputImageFormat: inputImageFormat,
        planeData: planeData);

    final inputImage =
        InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);
    widget.onImage!(inputImage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title:
            const Text("Take a picture", style: TextStyle(color: Colors.white)),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: _body(),
      floatingActionButton: _floatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _floatingActionButton() {
    return widget.customPaint != null
        ? SizedBox(
            height: 70,
            width: 70,
            child: FloatingActionButton(
                backgroundColor: Colors.white,
                onPressed: _onTakePictureButtonPressed,
                child:
                    const Icon(Icons.camera_alt, size: 40, color: Colors.grey)))
        : const Text("No face detected",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w400));
  }

  void _onTakePictureButtonPressed() async {
    if (widget.source == 'recognize') {
      _controller!.stopImageStream().whenComplete(() async {
        await Future.delayed(const Duration(milliseconds: 500));
        _controller!.takePicture().then((XFile? file) {
          widget.onCapture!(File(file!.path));
          
          List<int> imageBytes = file.readAsBytesSync();
          print(imageBytes);
          String base64Image = base64Encode(imageBytes);

          SearchImage(base64Image);

             
          Future.delayed(const Duration(seconds: 2)).whenComplete(() {
            if (mounted) {
              _startLive();
            }
          });
        });
      });
    } else {
      const count = 1;
      while (count < 300) {
        _controller!.stopImageStream().whenComplete(() async {
          await Future.delayed(const Duration(milliseconds: 500));
          _controller!.takePicture().then((XFile? file) {

              List<int> imageBytes = file.readAsBytesSync();
              print(imageBytes);
              String base64Image = base64Encode(imageBytes);
              _images.add(base64Image);
              setState((){

              });
              

            Future.delayed(const Duration(seconds: 2)).whenComplete(() {
              if (mounted) {
                _startLive();
              }
            });
          });
        });
      }

      UploadImage();
    }
  }

  Widget _body() {
    Widget body;
    body = _liveBody();
    return body;
  }

  Widget _liveBody() {
    if (_controller?.value.isInitialized == false) {
      return Container(
          color: Colors.black,
          child: const Center(child: CircularProgressIndicator()));
    }
    final size = MediaQuery.of(context).size;
    var scale = size.aspectRatio * _controller!.value.aspectRatio;
    if (scale < 1) scale = 1 / scale;
    return Container(
        color: Colors.black,
        child: Stack(fit: StackFit.expand, children: [
          Transform.scale(
            scale: scale,
            child: Center(
                child: CameraPreview(_controller!,
                    child: IgnorePointer(
                      child: ClipPath(
                        clipper: FaceOverlay(),
                        child: Container(
                            color: const Color.fromRGBO(0, 0, 0, 0.8),
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 55, vertical: 45),
                                child: Text(
                                    widget.customPaint == null
                                        ? "Face needs to be in the detected zone"
                                        : "Take the picture when the mask is green",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        height: 1.5,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w400)))),
                      ),
                    ))),
          ),
          if (widget.customPaint != null) widget.customPaint!,
        ]));
  }

  Future _stopLive() async {
    await _controller?.stopImageStream();
    await _controller?.dispose();
  }

   _displayDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Succeed'),
            /*content: TextField(
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Enter Name"),
            ),*/
            actions: [
              TextButton(
                child: const Text('OK'),
                /*onPressed: () {
                  setState(() {
                    _studentName = _textFieldController.text;
                  });*/
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  SearchImage(image_base64) async {
    
    final url = Uri.parse("http://127.0.0.1:5000/searchUser");
    final headers = {'Content-Type': 'application/json'};
    final body = {'nameUser': widget.studentName, 'photoInconnu': image_base64};

    http.post(url, headers: headers, body: json.encode(body)).then((response) {
      if (response.statusCode == 200) {
        // Request successful, handle response
        _displayDialog(context);

      } else {
        // Request failed, handle error
        print('Error');
      }
    });
  }
  UploadImage() async {
    /*String api_url = "http://127.0.0.1:5000/saveUser";
    var url = Uri.parse(api_url);
    var request = http.MultipartRequest("POST", url);

    request.fields["nameUser"] = widget.studentName;
    request.fields["photoUser"] = _images;
    
    var response = await request.send*/

    final url = Uri.parse("http://127.0.0.1:5000/saveUser");
    final headers = {'Content-Type': 'application/json'};
    final body = {'nameUser': widget.studentName, 'photoUser': _images};

    http.post(url, headers: headers, body: json.encode(body)).then((response) {
      if (response.statusCode == 200) {
        // Request successful, handle response
        _displayDialog(context);

      } else {
        // Request failed, handle error
        print('Error');
      }
    });
  }
}

