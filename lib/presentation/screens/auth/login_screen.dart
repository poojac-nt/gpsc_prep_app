import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

import '../../widgets/action_button.dart';
import '../../widgets/custom_text_field.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
      body: Form(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Email", style: AppTexts.labelTextStyle),
              5.hGap,
              CustomTextField(
                text: "Enter your email",
                prefixIcon: Icons.email,
              ),
              20.hGap,
              Text("Password", style: AppTexts.labelTextStyle),
              5.hGap,
              CustomTextField(
                text: "Enter your password",
                prefixIcon: Icons.password,
              ),
              30.hGap,
              ActionButton(
                text: "Sign In",
                onTap: () => context.go(AppRoutes.home),
              ),
              20.hGap,
              Padding(
                padding: EdgeInsets.only(left: 68.sp),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "Don't have an account ? Sign up",
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontSize: 13.sp,
                        ),
                        recognizer:
                            TapGestureRecognizer()
                              ..onTap = () {
                                context.go(AppRoutes.auth);
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
    );
  }
}
