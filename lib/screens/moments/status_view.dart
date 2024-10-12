import 'dart:convert';
import 'dart:typed_data';

import 'package:Beepo/components/bottom_nav.dart';
import 'package:Beepo/constants/constants.dart';
import 'package:Beepo/providers/account_provider.dart';
import 'package:Beepo/providers/chat_provider.dart';
import 'package:Beepo/widgets/toast.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class StatusView extends StatefulWidget {
  final Uint8List img;
  final CameraController cam;
  const StatusView({super.key, required this.img, required this.cam});

  @override
  State<StatusView> createState() => _StatusViewState();
}

class _StatusViewState extends State<StatusView> {
  final input = TextEditingController();
  final List<String> items = ['Public', 'Private'];
  String selectedItem = 'Public';

  void uploadStatus() async {
    final accountProvider =
        Provider.of<AccountProvider>(context, listen: false);

    ChatProvider().uploadStatus(base64Encode(widget.img), accountProvider.db,
        input.text, selectedItem, accountProvider.ethAddress);
    input.clear();
    // widget.cam.dispose();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BottomNavHome(),
      ),
    );

    showToast('Uploading Status!');
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(25),
      borderSide: const BorderSide(color: AppColors.white),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        textDirection: TextDirection.rtl,
        clipBehavior: Clip.hardEdge,
        children: <Widget>[
          Positioned(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.contain,
                  image: MemoryImage(widget.img),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 26,
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                      ),
                      child: TextField(
                        onSubmitted: (value) {
                          // uploadStatus;
                        },
                        controller: input,
                        style: const TextStyle(
                          color: AppColors.secondaryColor,
                        ),

                        decoration: InputDecoration(
                          fillColor: AppColors.white,
                          filled: true,
                          border: border,
                          focusedBorder: border,
                          enabledBorder: border,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          hintText: "Type message...",
                          hintStyle: const TextStyle(
                            color: AppColors.secondaryColor,
                          ),
                        ),
                        // expands: true,

                        keyboardType: TextInputType.multiline,
                        minLines: 1,
                        maxLines: 5,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      uploadStatus();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      height: 25.h,
                      width: 40.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: AppColors.secondaryColor,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.send,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            // height: 50,
            top: 30,
            right: 10,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.all(Radius.circular(14)),
              ),
              alignment: Alignment.topLeft,
              child: PopupMenuButton<String>(
                position: PopupMenuPosition.under,
                initialValue: selectedItem,
                onSelected: (String item) {
                  setState(() {
                    selectedItem = item;
                  });
                },
                itemBuilder: (BuildContext context) {
                  return items.map((String item) {
                    return PopupMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: const TextStyle(
                          color: AppColors.black, // Change text color
                        ),
                      ),
                    );
                  }).toList();
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          selectedItem,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.white,
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          size: 25,
                          color: AppColors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
