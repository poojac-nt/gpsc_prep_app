import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/blocs/connectivity_bloc/connectivity_bloc.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/data/models/payloads/user_payload.dart';
import 'package:gpsc_prep_app/presentation/screens/auth/auth_bloc.dart';
import 'package:gpsc_prep_app/presentation/widgets/elevated_container.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:gpsc_prep_app/utils/services/validator.dart';

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
  List<String> items = ["GPSC", "UPSC", "GSSSB"];
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    email.dispose();
    name.dispose();
    password.dispose();
    address.dispose();
    number.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAccountCreated) {
            context.pushReplacement(AppRoutes.dashboard);
          }
        },
        builder: (context, state) {
          if (state is AuthCreatingAccount ||
              state is ImagePicking ||
              state is ImageUploading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          }
          return SafeArea(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    10.hGap,

                    /// Profile Image Selector
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              context.read<AuthBloc>().add(PickImage());
                            },
                            child: Container(
                              height: 75.h,
                              width: 75.h,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                gradient:
                                    state is! ImageUploaded
                                        ? LinearGradient(
                                          colors: [
                                            Colors.grey.shade400,
                                            Colors.grey.shade600,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                        : null,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child:
                                    state is ImageUploaded
                                        ? Image.network(
                                          state.imageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Icon(
                                                    Icons.person,
                                                    size: 30.sp,
                                                    color: Colors.white,
                                                  ),
                                        )
                                        : Icon(
                                          Icons.person,
                                          size: 30.sp,
                                          color: Colors.white,
                                        ),
                              ),
                            ),
                          ),

                          /// Camera Icon
                          Positioned(
                            bottom: 0,
                            right: 6,
                            child: Container(
                              height: 24.h,
                              width: 24.h,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 12.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    20.hGap,
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Create Account',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          5.hGap,
                          Text(
                            'Join the learning platform',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    10.hGap,

                    /// Form Fields
                    ElevatedContainer(
                      padding: EdgeInsets.symmetric(
                        vertical: 24.h,
                        horizontal: 16.w,
                      ),
                      borderRadius: 10,
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text("Exam", style: AppTexts.labelTextStyle),
                          // 5.hGap,
                          // CustomDropdown(items: items, hintText: "Select Exam"),
                          // 20.hGap,
                          _buildInputText(
                            "Full Name",
                            "Enter your name",
                            10.hGap,
                            name,
                            validator: Validator.validateName,
                          ),

                          _buildInputText(
                            "Phone Number",
                            "Enter your phone number",
                            10.hGap,
                            number,
                            keyboardType: TextInputType.number,
                            validator: Validator.validatePhone,
                          ),

                          _buildInputText(
                            "Address",
                            "Enter your address",
                            10.hGap,
                            address,
                            validator: Validator.validateAddress,
                          ),

                          _buildInputText(
                            "Email",
                            "Enter your email",
                            10.hGap,
                            email,
                            validator: Validator.validateEmail,
                          ),

                          _buildInputText(
                            "Password",
                            "Enter your password",
                            10.hGap,
                            password,
                            validator: Validator.validatePassword,
                          ),
                          10.hGap,

                          /// Sign Up Button
                          ActionButton(
                            text: "Sign Up",
                            onTap: () {
                              final isOnline =
                                  context.read<ConnectivityBloc>().state
                                      is ConnectivityOnline;
                              if (isOnline) {
                                if (_formKey.currentState?.validate() ??
                                    false) {
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
                                            state is ImageUploaded
                                                ? state.imageUrl
                                                : null,
                                      ),
                                    ),
                                  );
                                }
                              } else {
                                getIt<SnackBarHelper>().showError(
                                  "You are offline. Please check your internet connection.",
                                );
                              }
                            },
                          ),
                          20.hGap,

                          /// Already have account
                          Center(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Already have an account?",
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: Colors.black,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' Sign in',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
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
                  ],
                ).padAll(AppPaddings.defaultPadding),
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
    Widget bottomGap,
    TextEditingController controller, {
    TextInputType? keyboardType,
    FormFieldValidator<String>? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTexts.labelTextStyle),
        5.hGap,
        CustomTextField(
          hintText: hint,
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
        ),
        bottomGap,
      ],
    );
  }
}
