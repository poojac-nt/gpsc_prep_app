import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/presentation/blocs/authentication/auth_bloc.dart';
import 'package:gpsc_prep_app/presentation/widgets/action_button.dart';
import 'package:gpsc_prep_app/presentation/widgets/elevated_container.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:gpsc_prep_app/utils/services/validator.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(() {});
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleResetPassword() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<AuthBloc>().add(
      ResetPasswordRequested(_newPasswordController.text),
    );
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is ResetPasswordSuccess) {
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                context.go(AppRoutes.login);
              }
            });
          } else if (state is ResetPasswordFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final isLoading = state is ResetPasswordLoading;
          final showSuccess = state is ResetPasswordSuccess;

          return SafeArea(
            child: Stack(
              children: [
                if (!showSuccess)
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        20.hGap,
                        _buildFormCard(isLoading, state),
                        20.hGap,
                        Center(
                          child: TextButton(
                            onPressed: () => context.go(AppRoutes.login),
                            child: Text(
                              'Back to Login',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ),
                        20.hGap,
                      ],
                    ).padAll(AppPaddings.defaultPadding),
                  ),
                if (showSuccess) _buildSuccessOverlay(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
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

          Text(
            'Create a strong and secure password',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(bool isLoading, AuthState state) {
    return ElevatedContainer(
      padding: EdgeInsets.all(20.w),
      borderRadius: 10,
      color: Colors.white,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('New Password', style: AppTexts.labelTextStyle),
            8.hGap,
            TextFormField(
              controller: _newPasswordController,
              obscureText: _obscureNewPassword,
              validator: Validator.validatePassword,
              cursorColor: Colors.black,
              decoration: InputDecoration(
                hintText: 'Enter your new password',
                hintStyle: TextStyle(color: Colors.grey),
                isDense: true,
                prefixIcon: Icon(
                  Icons.lock_outline_rounded,
                  color: AppColors.primary,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNewPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.grey.shade700,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: AppBorders.borderRadius,
                  borderSide: BorderSide(color: Colors.red, width: 1),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: AppBorders.borderRadius,
                  borderSide: BorderSide(color: Colors.red, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppBorders.borderRadius,
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppBorders.borderRadius,
                  borderSide: BorderSide(color: Colors.black, width: 2),
                ),
              ),
            ),
            20.hGap,
            Text('Confirm Password', style: AppTexts.labelTextStyle),
            8.hGap,
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              validator: _validateConfirmPassword,
              cursorColor: Colors.black,
              decoration: InputDecoration(
                hintText: 'Re-enter your new password',
                hintStyle: TextStyle(color: Colors.grey),
                isDense: true,
                prefixIcon: Icon(
                  Icons.lock_outline_rounded,
                  color: AppColors.primary,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.grey.shade700,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: AppBorders.borderRadius,
                  borderSide: BorderSide(color: Colors.red, width: 1),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: AppBorders.borderRadius,
                  borderSide: BorderSide(color: Colors.red, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppBorders.borderRadius,
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppBorders.borderRadius,
                  borderSide: BorderSide(color: Colors.black, width: 2),
                ),
              ),
            ),

            24.hGap,

            // Submit Button
            ActionButton(
              text: isLoading ? 'Resetting...' : 'Reset Password',
              onTap: isLoading ? () {} : _handleResetPassword,
              backgroundColor: AppColors.primary,
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessOverlay() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(60),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                Icons.check_rounded,
                size: 60.sp,
                color: Colors.white,
              ),
            ),
            32.hGap,
            Text(
              'Password Reset!',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            12.hGap,
            Text(
              'Your password has been successfully reset',
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
