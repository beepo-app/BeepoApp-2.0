import 'package:Beepo/constants/constants.dart';
import 'package:Beepo/screens/moments/blank_screen.dart';
import 'package:Beepo/utils/functions.dart';
import 'package:Beepo/utils/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:camera/camera.dart';
import '../../widgets/app_text.dart';
import 'package:image/image.dart' as img;

class AddStory extends StatefulWidget {
  final CameraController controller;
  const AddStory({super.key, required this.controller});

  @override
  State<AddStory> createState() => _AddStoryState();
}

class _AddStoryState extends State<AddStory> {
  @override
  void initState() {
    super.initState();
  }

  void _capturePhoto() async {
    if (widget.controller.value.isInitialized) {
      try {
        final snappedImage = await widget.controller.takePicture();
        if (kDebugMode) {
          beepoPrint('Image captured: ${snappedImage.path}');
          beepoPrint('Image captured: ${await snappedImage.length() / 1024}');
        }

        img.Image image = img.decodeImage(await snappedImage.readAsBytes())!;

        int width;
        int height;

        if (image.width > image.height) {
          width = 800;
          height = (image.height / image.width * 800).round();
        } else {
          height = 800;
          width = (image.width / image.height * 800).round();
        }

        img.Image resizedImage =
            img.copyResize(image, width: width, height: height);
        List<int> compressedBytes = img.encodeJpg(resizedImage, quality: 65);
        beepoPrint(compressedBytes.length / 1024);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlankScreen(
              cam: widget.controller,
              compressedBytes: compressedBytes,
            ),
          ),
        );
      } catch (e) {
        if (kDebugMode) {
          beepoPrint('Error capturing photo: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // beepoPrint(widget.controller.description.lensDirection);
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Container(
          // height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: AppColors.black,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Transform.scale(
                scale: 1,
                alignment: Alignment.topCenter,
                child: CameraPreview(
                  widget.controller,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    color: Colors.transparent,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.w),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () {
                                ImageUtil()
                                    .pickImageFromGallery()
                                    .then((value) async {
                                  try {
                                    if (value == null) return;
                                    if (kDebugMode) {
                                      beepoPrint(
                                          'Image captured: ${value.length / 1024}');
                                    }

                                    img.Image image = img.decodeImage(value)!;

                                    int width;
                                    int height;

                                    if (image.width > image.height) {
                                      width = 800;
                                      height =
                                          (image.height / image.width * 800)
                                              .round();
                                    } else {
                                      height = 800;
                                      width = (image.width / image.height * 800)
                                          .round();
                                    }

                                    img.Image resizedImage = img.copyResize(
                                        image,
                                        width: width,
                                        height: height);
                                    List<int> compressedBytes = img
                                        .encodeJpg(resizedImage, quality: 75);
                                    beepoPrint(compressedBytes.length / 1024);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BlankScreen(
                                          cam: widget.controller,
                                          compressedBytes: compressedBytes,
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    if (kDebugMode) {
                                      beepoPrint('Error capturing photo: $e');
                                    }
                                  }
                                });
                              },
                              icon: Container(
                                height: 30.h,
                                width: 40.w,
                                decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(255, 230, 208, 175),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                // child:MemoryImage(bytes),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _capturePhoto();
                              },
                              child: Container(
                                height: 70.h,
                                width: 70.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFE6E9EE),
                                  border: Border.all(
                                      color: Colors.orange, width: 2),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(
                                  context,
                                  widget.controller.description.lensDirection ==
                                          CameraLensDirection.front
                                      ? true
                                      : false,
                                );
                              },
                              child: SvgPicture.asset('assets/Rotate.svg'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      onTap: () {},
                      onLongPress: () {},
                      child: const AppText(
                        text: "Tap for photos, hold for videos",
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  // SizedBox(height: 10.h),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
