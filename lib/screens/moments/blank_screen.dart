import 'dart:async';
import 'dart:typed_data';

import 'package:Beepo/screens/moments/status_view.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:get/get.dart';

class BlankScreen extends StatefulWidget {
  final List<int> compressedBytes;
  final CameraController cam;
  const BlankScreen(
      {super.key, required this.compressedBytes, required this.cam});

  @override
  BlankScreenState createState() => BlankScreenState();
}

class BlankScreenState extends State<BlankScreen> {
  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    Timer(
      const Duration(milliseconds: 100),
      () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StatusView(
            cam: widget.cam,
            img: Uint8List.fromList(widget.compressedBytes),
          ),
        ),
      ).then((value) {
        Navigator.pop(context);

        return;
      }),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xff000000),
      body: SizedBox(),
    );
  }
}
