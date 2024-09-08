import 'package:Beepo/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class Camera extends StatefulWidget {
  final CameraController controller;

  const Camera({super.key, required this.controller});

  @override
  CameraState createState() => CameraState();
}

class CameraState extends State<Camera> {
  bool isCaptured = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      await widget.controller.initialize();
      _capturePhotoAfterDelay();
    } catch (e) {
      beepoPrint('Error initializing camera: $e');
    }
  }

  void _capturePhotoAfterDelay() async {
    await Future.delayed(const Duration(seconds: 3));
    if (widget.controller.value.isInitialized) {
      try {
        final image = await widget.controller.takePicture();
        // Do something with the captured image
        beepoPrint('Image captured: ${image.path}');

        Future.delayed(const Duration(seconds: 2), () {
          _handleBackPressed();
        });

        setState(() {
          isCaptured = true;
        });
      } catch (e) {
        beepoPrint('Error capturing photo: $e');
      }
    }
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  void _handleBackPressed() {
    widget.controller.stopImageStream();
    // Navigator.of(context)
    //     .popAndPushNamed('create-passcode', arguments: 'create');
  }

  @override
  Widget build(BuildContext context) {
    final scale = 1 /
        (widget.controller.value.aspectRatio *
            MediaQuery.of(context).size.aspectRatio);
    if (!widget.controller.value.isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      body: Transform.scale(
        scale: scale,
        alignment: Alignment.topCenter,
        child: CameraPreview(
          widget.controller,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 65, top: 20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 10,
                      ),
                      onPressed: _handleBackPressed,
                    ),
                    const SizedBox(width: 50),
                    const Text(
                      'Take a selfie',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontFamily: 'HelveticaNeueCyr',
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.10,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 67),
              Center(
                child: Image.asset(
                  "assets/images/oval_camera2.png",
                  width: 154,
                ),
              ),
              if (isCaptured)
                Container(
                  height: 119,
                  margin: const EdgeInsets.only(left: 79, right: 79),
                  width: double.infinity,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/preloader.png',
                          width: 31,
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Done!',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontFamily: 'HelveticaNeueCyr',
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.50,
                          ),
                        ),
                      ],
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
