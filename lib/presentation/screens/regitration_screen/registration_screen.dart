import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/sizedbox.dart';

import '../../widgets/action_button.dart';
import '../../widgets/custom_text_field.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController name = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController number = TextEditingController();

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
                Text("Exam", style: AppTexts.labelTextStyle),
                5.hGap,
                DropdownMenu(
                  width: double.infinity,
                  inputDecorationTheme: InputDecorationTheme(
                    border: OutlineInputBorder(
                      borderRadius: AppBorders.borderRadius,
                    ),
                    isDense: true,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10.w),
                  ),
                  hintText: "Select exam",
                  dropdownMenuEntries: [
                    DropdownMenuEntry(value: "GPSC", label: "GPSC"),
                    DropdownMenuEntry(value: "UPSC", label: "UPSC"),
                    DropdownMenuEntry(value: "GSSSB", label: "GSSSB"),
                  ],
                  menuStyle: MenuStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.white),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                ),
                20.hGap,
                Text("Full Name", style: AppTexts.labelTextStyle),
                5.hGap,
                CustomTextField(
                  text: "Enter your name",
                  prefixIcon: Icons.person_2,
                  controller: name,
                ),
                20.hGap,
                Text("Mobile Number", style: AppTexts.labelTextStyle),
                5.hGap,
                CustomTextField(
                  text: "Enter your mobile number",
                  prefixIcon: Icons.phone,
                  controller: number,
                ),
                20.hGap,
                Text("Address", style: AppTexts.labelTextStyle),
                5.hGap,
                CustomTextField(
                  text: "Enter your address",
                  prefixIcon: Icons.place_rounded,
                  controller: address,
                ),
                20.hGap,
                Text("Email", style: AppTexts.labelTextStyle),
                5.hGap,
                CustomTextField(
                  text: "Enter your email",
                  prefixIcon: Icons.email,
                  controller: email,
                ),
                20.hGap,
                Text("Password", style: AppTexts.labelTextStyle),
                5.hGap,
                CustomTextField(
                  text: "Enter your password",
                  prefixIcon: Icons.password,
                  controller: password,
                ),
                30.hGap,
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
                          text: "Already have an account ? ",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontSize: 13.sp,
                          ),
                        ),
                        TextSpan(
                          text: "Sign in",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontSize: 13.sp,
                          ),
                          recognizer:
                              TapGestureRecognizer()
                                ..onTap = () {
                                  context.go(AppRoutes.login);
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
}
