import 'package:flutter/material.dart';
import 'home.dart';
import 'package:camera/camera.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
  await Camera.initialize();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Face Recogntion App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class Camera {
  static List<CameraDescription> _cameras = [];

  static Future<void> initialize() async {
    try {
      _cameras = await availableCameras();
    } on CameraException {
      rethrow;
    }
  }

  static List<CameraDescription> get cameras {
    return _cameras;
  }
}
