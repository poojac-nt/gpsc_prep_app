import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/data/models/payloads/user_payload.dart';
import 'package:gpsc_prep_app/presentation/screens/auth/auth_bloc.dart';
import 'package:gpsc_prep_app/presentation/screens/profile/edit_profile_bloc.dart';
import 'package:gpsc_prep_app/presentation/screens/profile/widgets/quick_stats.dart';
import 'package:gpsc_prep_app/presentation/widgets/action_button.dart';
import 'package:gpsc_prep_app/presentation/widgets/bordered_container.dart';
import 'package:gpsc_prep_app/presentation/widgets/test_module.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:gpsc_prep_app/utils/services/validator.dart';

import '../../widgets/custom_text_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController email;
  late final TextEditingController password;
  late final TextEditingController name;
  late final TextEditingController address;
  late final TextEditingController number;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    email = TextEditingController();
    password = TextEditingController();
    name = TextEditingController();
    address = TextEditingController();
    number = TextEditingController();
    context.read<EditProfileBloc>().add(LoadInitialProfile());
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    name.dispose();
    address.dispose();
    number.dispose();
    super.dispose();
  }

  List<String> exams = [
    "GPSC Class 1-2",
    "UPSC Prelims",
    "GSSSB Clerk",
    "GPSC AE",
    "TAT",
    "HTAT",
  ];

  List<bool> checkedList = List.generate(6, (index) => false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Profile', style: AppTexts.titleTextStyle)),
      body: BlocBuilder<EditProfileBloc, EditProfileState>(
        builder: (context, state) {
          if (state is EditProfileLoading ||
              state is EditProfileInitial ||
              state is EditImagePicking ||
              state is EditImageUploading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is EditProfileLoaded ||
              state is EditProfileSuccess ||
              state is EditImageUploaded) {
            final user =
                state is EditProfileLoaded
                    ? state.user
                    : state is EditProfileSuccess
                    ? state.user
                    : (state as EditImageUploaded).user;

            email.text = user.email;
            name.text = user.name;
            number.text = user.number.toString();
            address.text = user.address!;

            return SingleChildScrollView(
              child: Column(
                children: [
                  TestModule(
                    title: "Profile Photo",
                    cards: [
                      Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    context.read<EditProfileBloc>().add(
                                      EditImage(),
                                    );
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
                                          user.profilePicture == null
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
                                          user.profilePicture != null &&
                                                  user
                                                      .profilePicture!
                                                      .isNotEmpty
                                              ? CachedNetworkImage(
                                                imageUrl: user.profilePicture!,
                                                fit: BoxFit.cover,
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(Icons.error),
                                              )
                                              : Icon(
                                                Icons.person,
                                                size: 35.sp,
                                                color: Colors.white,
                                              ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    height: 28.h,
                                    width: 28.h,
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
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 12.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              user.name,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              user.email,
                              textAlign: TextAlign.center,
                              style: AppTexts.labelTextStyle.copyWith(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  10.hGap,
                  TestModule(
                    title: 'Quick Stats',
                    cards: [
                      QuickStats(text: "Test Taken", num: "64"),
                      10.hGap,
                      QuickStats(text: "Average Score", num: "83"),
                      10.hGap,
                      QuickStats(text: "Study Strike", num: "12 days"),
                      10.hGap,
                      QuickStats(text: "Rank", num: "#264"),
                    ],
                  ),
                  10.hGap,
                  Form(
                    key: _formKey,
                    child: TestModule(
                      title: 'Personal Information',
                      prefixIcon: Icons.person_outline,
                      cards: [
                        10.hGap,
                        Text("Full Name", style: AppTexts.labelTextStyle),
                        5.hGap,
                        CustomTextField(
                          controller: name,
                          validator: Validator.validateName,
                        ),
                        10.hGap,
                        Text("Mobile Number", style: AppTexts.labelTextStyle),
                        5.hGap,
                        CustomTextField(
                          keyboardType: TextInputType.number,
                          controller: number,
                          validator: Validator.validatePhone,
                        ),
                        10.hGap,
                        Text("Address", style: AppTexts.labelTextStyle),
                        5.hGap,
                        CustomTextField(
                          maxLine: 3,
                          controller: address,
                          validator: Validator.validateAddress,
                        ),
                        10.hGap,
                        ActionButton(
                          text: 'Update Information',
                          onTap: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              context.read<EditProfileBloc>().add(
                                SaveProfileRequested(
                                  UserPayload(
                                    authID: user.authID,
                                    email: user.email,
                                    name: name.text.trim(),
                                    address: address.text.trim(),
                                    number: int.parse(number.text.trim()),
                                    profilePicture: user.profilePicture,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  // 10.hGap,
                  // TestModule(
                  //   title: "Exam Preferences",
                  //   subtitle: "Select the exams you are preparing for",
                  //   cards: [
                  //     5.hGap,
                  //     Text(
                  //       "Preparing for exams",
                  //       style: AppTexts.labelTextStyle,
                  //     ),
                  //     5.hGap,
                  //     ListView.builder(
                  //       physics: NeverScrollableScrollPhysics(),
                  //       shrinkWrap: true,
                  //       itemCount: exams.length,
                  //       itemBuilder:
                  //           (context, index) => Padding(
                  //             padding: EdgeInsets.symmetric(vertical: 5.h),
                  //             child: ExamPrefTile(
                  //               title: exams[index],
                  //               value: checkedList[index],
                  //               onChanged: (value) {
                  //                 setState(() {
                  //                   checkedList[index] = value!;
                  //                 });
                  //               },
                  //             ),
                  //           ),
                  //     ),
                  //     10.hGap,
                  //     Text("Selected Exams", style: AppTexts.labelTextStyle),
                  //     5.hGap,
                  //     Wrap(
                  //       runSpacing: 3,
                  //       spacing: 5,
                  //       children: [
                  //         CustomTag(exam: exams[0]),
                  //         CustomTag(exam: exams[1]),
                  //       ],
                  //     ),
                  //   ],
                  // ),
                  10.hGap,
                  TestModule(
                    title: "Account Actions",
                    cards: [
                      GestureDetector(
                        onTap:
                            () => showDeleteAccountDialog(context, user.authID),
                        child: BorderedContainer(
                          borderColor: Colors.red,
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 7.h,
                          ),
                          child: Center(
                            child: Text(
                              "Delete Account",
                              style: AppTexts.labelTextStyle.copyWith(
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ).padAll(AppPaddings.defaultPadding),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void showDeleteAccountDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      barrierDismissible: false, // prevent accidental dismiss
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 12,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: IntrinsicHeight(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icon
                  Align(
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.delete,
                      size: 48,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    "Delete Account",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Message
                  Text(
                    "Are you sure you want to delete your account?",
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            context.read<AuthBloc>().add(
                              DeleteUserRequested(userId),
                            );
                            context.pushReplacement(AppRoutes.login);
                          },
                          child: const Text("Delete"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
