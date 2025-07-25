import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/presentation/blocs/authentication/auth_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/connectivity_bloc/connectivity_bloc.dart';
import 'package:gpsc_prep_app/presentation/widgets/elevated_container.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:gpsc_prep_app/utils/services/validator.dart';

import '../../widgets/action_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_wrapper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    getIt<ConnectivityBloc>().add(CheckConnectivity());
    super.initState();
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            context.pushReplacement(AppRoutes.studentDashboard);
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Container(
                            height: 70.h,
                            width: 70.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: AppColors.primary,
                            ),
                            child: Center(
                              child: Icon(
                                CupertinoIcons.book,
                                color: Colors.white,
                                size: 40.sp,
                              ),
                            ),
                          ),
                          10.hGap,
                          Text(
                            "Exam Prep",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          5.hGap,
                          Text(
                            "Smart Learning Platform",
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    40.hGap,
                    ElevatedContainer(
                      padding: EdgeInsets.symmetric(
                        vertical: 24.h,
                        horizontal: 16.w,
                      ),
                      color: Colors.white,
                      borderRadius: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              'Welcome Back',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          5.hGap,
                          Center(
                            child: Text(
                              'Sign in to continue your learning journey',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          20.hGap,
                          _buildLabel("Email"),
                          10.hGap,
                          BlocLoadingWrapper<AuthBloc, AuthState>(
                            isLoadingSelector: (state) => state is AuthLoading,
                            builder: (isLoading) {
                              return CustomTextField(
                                hintText: "Enter your email",
                                controller: email,
                                validator: Validator.validateEmail,
                                isLoading: isLoading,
                              );
                            },
                          ),
                          20.hGap,
                          _buildLabel("Password"),
                          10.hGap,
                          BlocLoadingWrapper<AuthBloc, AuthState>(
                            isLoadingSelector: (state) => state is AuthLoading,
                            builder: (isLoading) {
                              return CustomTextField(
                                hintText: "Enter your password",
                                controller: password,
                                validator: Validator.validatePassword,
                                isLoading: isLoading,
                              );
                            },
                          ),
                          30.hGap,
                          BlocLoadingWrapper<AuthBloc, AuthState>(
                            isLoadingSelector: (state) => state is AuthLoading,
                            builder: (isLoading) {
                              return ActionButton(
                                isLoading: isLoading,
                                text: "Sign In",
                                onTap: () {
                                  final isOnline =
                                      context.read<ConnectivityBloc>().state
                                          is ConnectivityOnline;
                                  if (isOnline) {
                                    if (_formKey.currentState?.validate() ??
                                        false) {
                                      context.read<AuthBloc>().add(
                                        LoginRequested(
                                          email: email.text.trim(),
                                          password: password.text.trim(),
                                        ),
                                      );
                                    }
                                  } else {
                                    getIt<SnackBarHelper>().showError(
                                      'No Internet Connection',
                                    );
                                  }
                                },
                              );
                            },
                          ),
                          20.hGap,
                          Center(
                            child: BlocLoadingWrapper<AuthBloc, AuthState>(
                              isLoadingSelector:
                                  (state) => state is AuthLoading,
                              builder: (isLoading) {
                                return Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "Don't have an account?",
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color: Colors.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' Create one',
                                        style: TextStyle(
                                          color:
                                              isLoading
                                                  ? Colors.grey
                                                  : AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        recognizer:
                                            TapGestureRecognizer()
                                              ..onTap = () {
                                                if (!isLoading) {
                                                  context.go(
                                                    AppRoutes
                                                        .registrationScreen,
                                                  );
                                                }
                                              },
                                      ),
                                    ],
                                  ),
                                );
                              },
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

  /// Optional helper widget for label styling
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppTexts.labelTextStyle.copyWith(
        fontWeight: FontWeight.w600,
        color: Colors.grey[800],
      ),
    );
  }
}
