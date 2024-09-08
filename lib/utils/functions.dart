//Generate key pair
import 'dart:io';
import 'dart:math';
import 'package:Beepo/utils/logger.dart';
import 'package:Beepo/widgets/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

List createKeywords(String userName) {
  List arrayName = [];
  String nameJoin = '';
  // String userNameJoin = '';

  userName.toLowerCase().split('').forEach((letter) {
    nameJoin += letter;
    arrayName.add(nameJoin);
  });
  // username.toLowerCase().split('').forEach((letter) {
  //   userNameJoin += letter;
  //   arrayName.add(userNameJoin);
  // });
  return arrayName;
}

String generateRandomString(int len) {
  var r = Random();
  return String.fromCharCodes(
      List.generate(len, (index) => r.nextInt(33) + 89));
}

String formatCurrency(num num) {
  return NumberFormat.currency(symbol: '\$').format(num);
}

//format date
String formatDate(DateTime date) {
  return DateFormat('dd/MM/yyyy').add_jm().format(date);
}

class ImageUtil {
  Future<Uint8List?> cropProfileImage(File? file) async {
    if (file != null) {
      if (kDebugMode) {
        beepoPrint(file.path);
      }

      Uint8List imageBytes = await file.readAsBytes();
      return imageBytes;
    }
    return null;
  }

  Future<Uint8List?> pickProfileImage({BuildContext? context}) async {
    try {
      return await showCupertinoModalPopup(
        context: context!,
        builder: (BuildContext context) => CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              onPressed: () async {
                XFile? result = await ImagePicker().pickImage(
                  source: ImageSource.camera,
                  preferredCameraDevice: CameraDevice.front,
                );

                if (result != null) {
                  if ((await result.length()) > 5000000) {
                    showToast('File too large');
                    return;
                  } else {
                    Uint8List res = await result.readAsBytes();
                    Get.back(result: res);
                  }
                } else {
                  return;
                }
              },
              child: const Text('Select from Camera'),
            ),
            CupertinoActionSheetAction(
              onPressed: () async {
                XFile? result =
                    await ImagePicker().pickImage(source: ImageSource.gallery);

                if (result != null) {
                  //File size limit - 5mb
                  if ((await result.length()) > 5000000) {
                    showToast('File too large');
                    return;
                  } else {
                    Uint8List res = await result.readAsBytes();
                    Get.back(result: res);
                  }
                } else {
                  return;
                }
              },
              child: const Text('Select from Gallery'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Get.back();
            },
            child: const Text('Cancel'),
          ),
        ),
      );
    } catch (e) {
      beepoPrint(e);
      rethrow;
    }
  }

  Future<Uint8List?> pickImageFromGallery() async {
    try {
      XFile? result =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (result != null) {
        //File size limit - 5mb
        if ((await result.length()) > 5000000) {
          showToast('File too large');
          return null;
        } else {
          Uint8List res = await result.readAsBytes();
          return res;
        }
      } else {
        return null;
      }
    } catch (e) {
      beepoPrint(e);
      rethrow;
    }
  }

  Future<Uint8List?> pickImageFromCamera() async {
    try {
      XFile? result = await ImagePicker().pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
      );

      if (result != null) {
        //File size limit - 5mb
        if ((await result.length()) > 5000000) {
          showToast('File too large');
          return null;
        } else {
          Uint8List res = await result.readAsBytes();
          return res;
        }
      } else {
        return null;
      }
    } catch (e) {
      beepoPrint(e);
      rethrow;
    }
  }
}

extension IsSameDate on DateTime {
  /// Return `true` if the dates are equal.
  /// Only comparing [day], [month] and [year].
  bool isSameDate(DateTime other) {
    return day == other.day && month == other.month && year == other.year;
  }
}
