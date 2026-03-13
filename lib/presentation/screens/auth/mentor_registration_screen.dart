import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/data/models/payloads/user_payload.dart';
import 'package:gpsc_prep_app/domain/entities/subject_model.dart';
import 'package:gpsc_prep_app/presentation/blocs/authentication/auth_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/mentor/mentor_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/subject/subject_bloc.dart';
import 'package:gpsc_prep_app/presentation/widgets/action_button.dart';
import 'package:gpsc_prep_app/presentation/widgets/custom_text_field.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/enums/user_role.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:gpsc_prep_app/utils/services/validator.dart';
import 'package:image_picker/image_picker.dart';

class MentorRegistrationScreen extends StatefulWidget {
  const MentorRegistrationScreen({super.key});

  @override
  State<MentorRegistrationScreen> createState() =>
      _MentorRegistrationScreenState();
}

class _MentorRegistrationScreenState extends State<MentorRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController customSubjectController = TextEditingController();

  File? _profileImage;
  final List<SubjectModel> _selectedSubjects = [];
  final List<SubjectModel> _customSubjects = [];

  @override
  void initState() {
    super.initState();
    context.read<SubjectBloc>().add(FetchSubjects());
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    bioController.dispose();
    customSubjectController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _addCustomSubject() {
    final subjectName = customSubjectController.text.trim();
    if (subjectName.isEmpty) return;

    if (_selectedSubjects.any((s) => s.subjectName == subjectName) ||
        _customSubjects.any((s) => s.subjectName == subjectName)) {
      getIt<SnackBarHelper>().showError("Subject already exists");
      return;
    }

    final newSubject = SubjectModel(subjectId: -1, subjectName: subjectName);
    setState(() {
      _customSubjects.add(newSubject);
      _selectedSubjects.add(newSubject);
      customSubjectController.clear();
    });
  }

  void _handleRegistration() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedSubjects.isEmpty) {
        getIt<SnackBarHelper>().showError("Please select at least one subject");
        return;
      }

      final payload = UserPayload(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        role: UserRole.mentor.role,
        bio: bioController.text.trim(),
        subjectExpertise: _selectedSubjects.map((s) => s.subjectName).toList(),
      );

      context.read<AuthBloc>().add(
        CreateMentorRequested(payload, profileImage: _profileImage),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Register Mentor",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAccountCreated) {
            getIt<SnackBarHelper>().showSuccess(
              "Mentor registered successfully",
            );
            context.read<MentorBloc>().add(FetchMentorList());
            context.pop();
          } else if (state is AuthFailure) {
            getIt<SnackBarHelper>().showError(state.message);
          } else if (state is AuthAccountCreateError) {
            getIt<SnackBarHelper>().showError(state.message);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.all(24.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 100.w,
                          height: 100.w,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            shape: BoxShape.circle,
                            image:
                                _profileImage != null
                                    ? DecorationImage(
                                      image: FileImage(_profileImage!),
                                      fit: BoxFit.cover,
                                    )
                                    : null,
                          ),
                          child:
                              _profileImage == null
                                  ? Icon(
                                    Icons.person_outline,
                                    size: 40.sp,
                                    color: Colors.grey[400],
                                  )
                                  : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                size: 16.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  24.hGap,
                  _buildLabel("Full Name"),
                  8.hGap,
                  CustomTextField(
                    hintText: "Enter mentor's name",
                    controller: nameController,
                    prefixIcon: Icons.person_outline,
                    validator:
                        (val) =>
                            val == null || val.isEmpty
                                ? "Name is required"
                                : null,
                  ),
                  20.hGap,
                  _buildLabel("Email Address"),
                  8.hGap,
                  CustomTextField(
                    hintText: "mentor@example.com",
                    controller: emailController,
                    prefixIcon: Icons.email_outlined,
                    validator: Validator.validateEmail,
                  ),
                  20.hGap,
                  _buildLabel("Password"),
                  8.hGap,
                  CustomTextField(
                    hintText: "••••••••",
                    controller: passwordController,
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    validator: Validator.validatePassword,
                  ),
                  20.hGap,
                  _buildLabel("Subjects of Expertise"),
                  8.hGap,
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          hintText: "Add custom subject",
                          controller: customSubjectController,
                          prefixIcon: Icons.add_circle_outline,
                        ),
                      ),
                      8.wGap,
                      GestureDetector(
                        onTap: _addCustomSubject,
                        child: Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 24.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  16.hGap,
                  BlocBuilder<SubjectBloc, SubjectState>(
                    builder: (context, state) {
                      if (state is SubjectLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      List<SubjectModel> subjects = [];
                      if (state is SubjectSuccess) {
                        subjects = state.subjects;
                      }
                      final allSubjects = [...subjects, ..._customSubjects];

                      return Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children:
                            allSubjects.map((subject) {
                              final isSelected = _selectedSubjects.any(
                                (s) => s.subjectName == subject.subjectName,
                              );
                              return FilterChip(
                                label: Text(subject.subjectName),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedSubjects.add(subject);
                                    } else {
                                      _selectedSubjects.removeWhere(
                                        (s) =>
                                            s.subjectName ==
                                            subject.subjectName,
                                      );
                                    }
                                  });
                                },
                                selectedColor: AppColors.primary.withAlpha(10),
                                checkmarkColor: AppColors.primary,
                                labelStyle: TextStyle(
                                  color:
                                      isSelected
                                          ? AppColors.primary
                                          : Colors.grey[700],
                                  fontSize: 12.sp,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                ),
                                backgroundColor: Colors.grey[50],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.r),
                                  side: BorderSide(
                                    color:
                                        isSelected
                                            ? AppColors.primary
                                            : Colors.grey[200]!,
                                  ),
                                ),
                              );
                            }).toList(),
                      );
                    },
                  ),
                  20.hGap,
                  _buildLabel("Short Bio"),
                  8.hGap,
                  CustomTextField(
                    hintText: "A brief professional summary...",
                    controller: bioController,
                    maxLine: 4,
                  ),
                  32.hGap,
                  ActionButton(
                    isLoading:
                        state is AuthLoading ||
                        state is AuthCreatingAccount ||
                        state is ImageUploading,
                    text: "Register Mentor",
                    onTap: _handleRegistration,
                  ),
                  20.hGap,
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: Colors.grey[800],
      ),
    );
  }
}
