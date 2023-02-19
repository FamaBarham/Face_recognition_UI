import "package:flutter/material.dart";
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import './face_recognition/face_recognition.dart';
import './face_registration/face_registration.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _studentName = "";
  final TextEditingController _textFieldController = TextEditingController();

  _displayDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Register a student '),
            content: TextField(
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Enter Name"),
            ),
            actions: [
              TextButton(
                child: const Text('SUBMIT'),
                onPressed: () {
                  setState(() {
                    _studentName = _textFieldController.text;
                  });
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Image(
                image: AssetImage('ept.jpg'),
                width: 300,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: SizedBox(
                  height: 60,
                  width: 300,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await _displayDialog(context);
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              FaceRegistration(studentName: _studentName)));
                    },
                    icon: const Icon(
                      FontAwesomeIcons.upload,
                      size: 40,
                    ),
                    label: const Padding(
                        padding: EdgeInsets.symmetric(),
                        child: Text(
                          "Register a new student",
                          style: const TextStyle(),
                        )),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      side: const BorderSide(width: 1, color: Colors.brown),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SizedBox(
                  height: 60,
                  width: 300,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await _displayDialog(context);
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              FaceRecognition(studentName: _studentName)));
                    },
                    icon: const Icon(
                      FontAwesomeIcons.check,
                      size: 40,
                    ),
                    label: const Padding(
                        padding: EdgeInsets.symmetric(),
                        child: Text(
                          "Verify student identity",
                          style: const TextStyle(),
                        )),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      side: const BorderSide(width: 1, color: Colors.brown),
                    ),
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
