import 'dart:convert';
import 'dart:typed_data';
import 'package:Beepo/components/Beepo_filled_button.dart';
import 'package:Beepo/constants/constants.dart';
import 'package:Beepo/screens/Auth/pin_code.dart';
import 'package:Beepo/utils/functions.dart';
import 'package:Beepo/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Import Hive

class CreateAccountScreen extends StatefulWidget {
  final String? mnemonic;
  const CreateAccountScreen({super.key, this.mnemonic});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  TextEditingController displayName = TextEditingController();
  Uint8List? selectedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Navigator.pop(context),
        ),
        foregroundColor: Colors.black,
        title: const Text(
          "Create your account",
          style: TextStyle(
            color: Color(0xb20e014c),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                  margin: const EdgeInsets.all(5),
                  width: 131,
                  height: 131,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xffc4c4c4),
                  ),
                  child: selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.memory(
                            selectedImage!,
                            height: 120,
                            width: 120,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(
                          Icons.person_outlined,
                          size: 117,
                          color: Color(0x66000000),
                        ),
                ),
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: GestureDetector(
                    onTap: () {
                      ImageUtil()
                          .pickProfileImage(context: context)
                          .then((value) {
                        if (value != null) {
                          setState(() {
                            selectedImage = value;
                          });
                        }
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.secondaryColor,
                      ),
                      child: const Icon(
                        Icons.photo_camera_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 35),
            const Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                "Display name",
                style: TextStyle(
                  color: Color(0x4c0e014c),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextField(
              controller: displayName,
            ),
            const Spacer(),
            BeepoFilledButtons(
              text: 'Next',
              color: const Color(0xffFF9C34),
              onPressed: () async {
                if (displayName.text.trim().isEmpty ||
                    displayName.text.trim().length < 3) {
                  showToast(
                      'Please enter a display name with a minimum length of 4 characters');
                  return;
                }
                if (selectedImage == null) {
                  showToast('Please select a display image');
                  return;
                } else {
                  // Save the profile image to Hive
                  await _saveProfileImageToHive(selectedImage!);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PinCode(
                        mnemonic: widget.mnemonic,
                        image: selectedImage,
                        name: displayName.text.trim(),
                        isSignedUp: false,
                      ),
                    ),
                  );
                }
              },
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfileImageToHive(Uint8List imageBytes) async {
    try {
      final box = Hive.box('Beepo2.0');
      final base64Image = base64Encode(imageBytes);
      await box.put('imageUrl', base64Image);
      debugPrint("Profile image saved to Hive successfully");
    } catch (e) {
      debugPrint("Error saving profile image to Hive: $e");
      showToast("Failed to save profile image");
    }
  }
}
