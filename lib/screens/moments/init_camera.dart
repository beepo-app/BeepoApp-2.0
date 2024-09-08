import 'dart:async';
import 'package:Beepo/screens/moments/add_story.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:get/get.dart';

class InitCamera extends StatefulWidget {
  final bool backDirection;
  const InitCamera({super.key, required this.backDirection});

  @override
  InitCameraState createState() => InitCameraState();
}

class InitCameraState extends State<InitCamera> {
  late CameraController _controller;
  late Future<void> initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initializeCamera(widget.backDirection);
  }

  Future<void> _initializeCamera(bool backDirection) async {
    final cameras = await availableCameras();

    final backCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == (backDirection ? CameraLensDirection.back : CameraLensDirection.front),
      orElse: () => cameras.first,
    );
    _controller = CameraController(backCamera, ResolutionPreset.ultraHigh, enableAudio: true);
    initializeControllerFuture = _controller.initialize();

    // if (!_controller.value.isInitialized) return;
    // _controller.value.

    Timer(
      const Duration(milliseconds: 700),
      () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddStory(controller: _controller),
        ),
      ).then((value) {
        if (value == null) {
          Get.back();
          return;
        }
        _initializeCamera(value);
      }),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
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
