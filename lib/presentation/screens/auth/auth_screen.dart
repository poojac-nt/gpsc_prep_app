import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/sizedbox.dart';
import 'package:image_picker/image_picker.dart';

import '../../widgets/action_button.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/custom_text_field.dart';

class AuthScreen extends StatefulWidget {
  AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  List<String> items = ["GPSC", "UPSC", "GSSSB"];

  final picker = ImagePicker();

  File? file;

  XFile? pickedFile;

  void uploadImage() async {
    pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        file = File(pickedFile!.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "GPSC Exam Prep",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Form(
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () => uploadImage(),
                        child: Container(
                          height: 50.h,
                          width: 50.h,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(100),
                          ),

                          child:
                              pickedFile != null
                                  ? ClipOval(
                                    child: Image.file(file!, fit: BoxFit.cover),
                                  )
                                  : const Icon(
                                    Icons.person,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                        ),
                      ),
                      Positioned(
                        bottom: -5,
                        right: 1,
                        child: Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.black,
                          size: 23,
                        ),
                      ),
                    ],
                  ),
                ),
                Text("Exam", style: AppTexts.labelTextStyle),
                5.hGap,
                CustomDropdown(items: items, hintText: "Select Exam"),
                20.hGap,
                _buildInputText(
                  "Full Name",
                  "Enter your name",
                  Icons.person_2,
                  20.hGap,
                ),
                _buildInputText(
                  "Phone Number",
                  "Enter your phone number",
                  Icons.phone,
                  20.hGap,
                ),
                _buildInputText(
                  "Address",
                  "Enter your address",
                  Icons.place_rounded,
                  20.hGap,
                ),
                _buildInputText(
                  "Email",
                  "Enter your email",
                  Icons.email,
                  20.hGap,
                ),
                _buildInputText(
                  "Password",
                  "Enter your password",
                  Icons.password,
                  20.hGap,
                ),
                10.hGap,
                ActionButton(
                  text: "Sign Up",
                  onTap: () => context.go(AppRoutes.home),
                ),
                20.hGap,
                Padding(
                  padding: EdgeInsets.only(left: 68.w),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "Already have an account ? Sign in",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontSize: 13.sp,
                          ),
                          recognizer:
                              TapGestureRecognizer()
                                ..onTap = () {
                                  context.push(AppRoutes.login);
                                },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputText(
    String title,
    String hint,
    IconData? icon,
    Widget bottomGap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTexts.labelTextStyle),
        5.hGap,
        CustomTextField(text: hint, prefixIcon: icon),
        bottomGap,
      ],
    );
  }
}
