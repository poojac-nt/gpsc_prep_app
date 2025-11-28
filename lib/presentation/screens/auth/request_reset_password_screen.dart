import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/presentation/blocs/authentication/auth_bloc.dart';
import 'package:gpsc_prep_app/presentation/widgets/action_button.dart';
import 'package:gpsc_prep_app/presentation/widgets/elevated_container.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:gpsc_prep_app/utils/services/validator.dart';

class RequestResetPasswordScreen extends StatefulWidget {
  const RequestResetPasswordScreen({super.key});

  @override
  State<RequestResetPasswordScreen> createState() =>
      _RequestResetPasswordScreenState();
}

class _RequestResetPasswordScreenState
    extends State<RequestResetPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final snackBar = getIt<SnackBarHelper>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void _handleRequestReset() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        RequestResetPasswordEvent(emailController.text.trim()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Request Reset Password", style: AppTexts.heading),
      ),
      backgroundColor: AppColors.scaffoldColor,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is RequestResetPasswordSuccess) {
            snackBar.showSuccess(
              'Password reset link sent to ${emailController.text}',
            );
          } else if (state is RequestResetPasswordFailure) {
            snackBar.showError(state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is RequestResetPasswordLoading;

          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(20.w),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withAlpha(80),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.lock_reset_rounded,
                            size: 40.sp,
                            color: Colors.white,
                          ),
                        ),

                        20.hGap,

                        Text(
                          'Reset Password',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),

                        8.hGap,

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32.w),
                          child: Text(
                            'Enter your email address and we\'ll send you a link to reset your password',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),

                  30.hGap,

                  ElevatedContainer(
                    padding: EdgeInsets.all(20.w),
                    borderRadius: 10,
                    color: Colors.white,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Email Address', style: AppTexts.labelTextStyle),
                          8.hGap,
                          TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              hintText: 'Enter your email',
                              hintStyle: TextStyle(color: Colors.grey),
                              isDense: true,
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: AppColors.primary,
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: AppBorders.borderRadius,
                                borderSide: BorderSide(
                                  color: Colors.red,
                                  width: 1,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: AppBorders.borderRadius,
                                borderSide: BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: AppBorders.borderRadius,
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: AppBorders.borderRadius,
                                borderSide: BorderSide(
                                  color: Colors.black,
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: Validator.validateEmail,
                          ),
                          24.hGap,
                          ActionButton(
                            text: isLoading ? 'Sending...' : 'Send Reset Link',
                            onTap: isLoading ? () {} : _handleRequestReset,
                            backgroundColor: AppColors.primary,
                            isLoading: isLoading,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ).padAll(AppPaddings.defaultPadding),
            ),
          );
        },
      ),
    );
  }
}
