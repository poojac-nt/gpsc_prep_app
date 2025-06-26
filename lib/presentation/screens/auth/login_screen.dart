import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/presentation/screens/auth/auth_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/home/home_screen.dart';
import 'package:gpsc_prep_app/utils/extensions/sizedbox.dart';

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
              Text(
                "Email",
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
              5.hGap,
              CustomTextField(
                text: "Enter your email",
                prefixIcon: Icons.email,
              ),
              20.hGap,
              Text(
                "Password",
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
              5.hGap,
              CustomTextField(
                text: "Enter your password",
                prefixIcon: Icons.password,
              ),
              30.hGap,
              ActionButton(
                text: "Sign in",
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    ),
              ),
              20.hGap,
              Padding(
                padding: EdgeInsets.only(left: 68.sp),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "Don't have an account ? ",
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontSize: 13.sp,
                        ),
                      ),
                      TextSpan(
                        text: "Sign Up",
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontSize: 13.sp,
                        ),
                        recognizer:
                            TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AuthScreen(),
                                  ),
                                );
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
