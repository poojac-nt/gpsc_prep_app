import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/data/models/payloads/user_payload.dart';
import 'package:gpsc_prep_app/presentation/screens/auth/auth_bloc.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

import '../../widgets/action_button.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/custom_text_field.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final SnackBarHelper snackBarHelper = getIt<SnackBarHelper>();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController name = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController number = TextEditingController();
  List<String> items = ["GPSC", "UPSC", "GSSSB"];

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
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthCreated) {
            context.pushReplacement(AppRoutes.home);
          } else if (state is AuthCreateFailure) {
            print(state.message);
            snackBarHelper.showError(state.message);
          } else if (state is ImageUploadError) {
            print(state.message);
            snackBarHelper.showError(state.message);
          }
        },
        builder: (context, state) {
          if (state is AuthCreating ||
              state is ImagePicking ||
              state is ImageUploading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          }
          return SingleChildScrollView(
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
                            onTap: () {
                              context.read<AuthBloc>().add(PickImage());
                            },
                            child: Container(
                              height: 65.h,
                              width: 65.h,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(100),
                              ),

                              child:
                                  state is ImageUploaded
                                      ? ClipOval(
                                        child: Image.network(
                                          state.imageUrl,
                                          fit: BoxFit.cover,
                                        ),
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
                      name,
                    ),
                    _buildInputText(
                      "Phone Number",
                      "Enter your phone number",
                      Icons.phone,
                      20.hGap,
                      number,
                      keyboardType: TextInputType.number,
                    ),
                    _buildInputText(
                      "Address",
                      "Enter your address",
                      Icons.place_rounded,
                      20.hGap,
                      address,
                    ),
                    _buildInputText(
                      "Email",
                      "Enter your email",
                      Icons.email,
                      20.hGap,
                      email,
                    ),
                    _buildInputText(
                      "Password",
                      "Enter your password",
                      Icons.password,
                      20.hGap,
                      password,
                    ),
                    10.hGap,
                    ActionButton(
                      text: "Sign Up",
                      onTap: () {
                        context.read<AuthBloc>().add(
                          CreateUserRequested(
                            UserPayload(
                              name: name.text.trim(),
                              email: email.text.trim(),
                              password: password.text.trim(),
                              role: "Student",
                              number: int.parse(number.text.trim()),
                              address: address.text.trim(),
                              profilePicture:
                                  state is ImageUploaded ? state.imageUrl : '',
                            ),
                          ),
                        );
                      },
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
          );
        },
      ),
    );
  }

  Widget _buildInputText(
    String title,
    String hint,
    IconData? icon,
    Widget bottomGap,
    TextEditingController controller, {
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTexts.labelTextStyle),
        5.hGap,
        CustomTextField(
          hintText: hint,
          controller: controller,
          prefixIcon: icon,
          keyboardType: keyboardType,
        ),
        bottomGap,
      ],
    );
  }
}
