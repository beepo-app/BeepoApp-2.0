import 'dart:async';
import 'package:Beepo/screens/moments/moments_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BlankStatusScreen extends StatefulWidget {
  final Map data;
  const BlankStatusScreen({super.key, required this.data});

  @override
  BlankStatusScreenState createState() => BlankStatusScreenState();
}

class BlankStatusScreenState extends State<BlankStatusScreen> {
  @override
  void initState() {
    super.initState();
    _initializeCamera(
      {
        'data': widget.data['data'],
        "curIndex": widget.data['curIndex'],
        'userData': widget.data['userData'],
      },
    );
  }

  Future<void> _initializeCamera(data) async {
    Timer(
      const Duration(milliseconds: 100),
      () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MomentsScreens(
            data: data,
          ),
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
