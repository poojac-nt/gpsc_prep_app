import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/domain/entities/mentor_model.dart';
import 'package:gpsc_prep_app/domain/entities/subject_model.dart';
import 'package:gpsc_prep_app/presentation/blocs/edit_mentor/edit_mentor_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/edit_mentor/edit_mentor_event.dart';
import 'package:gpsc_prep_app/presentation/blocs/edit_mentor/edit_mentor_state.dart';
import 'package:gpsc_prep_app/presentation/widgets/action_button.dart';
import 'package:gpsc_prep_app/presentation/widgets/custom_text_field.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:image_picker/image_picker.dart';

class EditMentorScreen extends StatefulWidget {
  final MentorModel mentor;
  const EditMentorScreen({super.key, required this.mentor});

  @override
  State<EditMentorScreen> createState() => _EditMentorScreenState();
}

class _EditMentorScreenState extends State<EditMentorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  final TextEditingController _tagController = TextEditingController();

  File? _newProfileImage;
  late List<String> _specializations;
  List<SubjectModel> _availableSubjects = [];
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.mentor.user.name);
    _bioController = TextEditingController(text: widget.mentor.user.bio);
    _specializations =
        widget.mentor.subjects.map((s) => s.subjectName).toList();
    _isActive = widget.mentor.user.isActive ?? false;
    context.read<EditMentorBloc>().add(FetchSubjects());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (picked != null) {
      setState(() => _newProfileImage = File(picked.path));
    }
  }

  void _showAddSpecializationDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        if (_availableSubjects.isEmpty) {
          return Center(
            child: Text(
              "No subjects available to add.",
              style: TextStyle(fontSize: 14.sp, color: AppColors.gray500),
            ),
          );
        }
        return ListView.separated(
          padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
          itemCount: _availableSubjects.length,
          separatorBuilder: (_, _) => const Divider(),
          itemBuilder: (context, index) {
            final subjectName = _availableSubjects[index].subjectName;
            final isSelected = _specializations.contains(subjectName);
            return ListTile(
              title: Text(
                subjectName,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: isSelected ? AppColors.primary : AppColors.gray900,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              trailing:
                  isSelected
                      ? Icon(Icons.check_circle, color: AppColors.primary)
                      : const Icon(Icons.circle_outlined),
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _specializations.remove(subjectName);
                  } else {
                    _specializations.add(subjectName);
                  }
                });
                Navigator.pop(ctx);
              },
            );
          },
        );
      },
    );
  }

  void _removeSpecialization(String tag) {
    setState(() => _specializations.remove(tag));
  }

  void _handleSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final mentorId = widget.mentor.user.id;
    if (mentorId == null) return;

    context.read<EditMentorBloc>().add(
      UpdateMentor(
        userId: mentorId,
        name: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        subjectExpertise: _specializations,
        isActive: _isActive,
        profileImage: _newProfileImage,
      ),
    );
  }

  void _handleDelete() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            title: Text(
              'Delete Mentor',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16.sp),
            ),
            content: Text(
              'Are you sure you want to permanently delete this mentor account? This action cannot be undone.',
              style: TextStyle(fontSize: 13.sp, color: AppColors.gray500),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.gray500),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  final id = widget.mentor.user.id;
                  if (id != null) {
                    context.read<EditMentorBloc>().add(DeleteMentor(id));
                  }
                },
                child: Text(
                  'Delete',
                  style: TextStyle(
                    color: AppColors.red500,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: AppColors.gray900,
            size: 20.sp,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Edit Mentor Profile',
          style: TextStyle(
            color: AppColors.gray900,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: BlocListener<EditMentorBloc, EditMentorState>(
        listener: (context, state) {
          if (state is MentorUpdateSuccess) {
            context.pop(true); // pop and signal refresh
          } else if (state is MentorDeleteSuccess) {
            // Pop twice — edit screen and list will refresh
            context.pop(true);
          } else if (state is MentorOperationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.red500,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is SubjectsLoaded) {
            setState(() {
              _availableSubjects = state.subjects;
            });
          }
        },
        child: BlocBuilder<EditMentorBloc, EditMentorState>(
          builder: (context, state) {
            final isSaving = state is MentorSaving;
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.all(24.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAvatarSection(),
                    28.hGap,
                    _buildLabel('Full Name'),
                    8.hGap,
                    CustomTextField(
                      controller: _nameController,
                      hintText: "Enter mentor's full name",
                      prefixIcon: Icons.person_outline,
                      validator:
                          (val) =>
                              val == null || val.isEmpty
                                  ? 'Name is required'
                                  : null,
                    ),
                    20.hGap,
                    _buildLabel('Email Address'),
                    8.hGap,
                    CustomTextField(
                      controller: TextEditingController(
                        text: widget.mentor.user.email,
                      ),
                      hintText: 'Email',
                      prefixIcon: Icons.email_outlined,
                      isLoading: true, // disabled — email not editable
                    ),
                    20.hGap,
                    _buildLabel('Specialization'),
                    8.hGap,
                    _buildSpecializationSection(),
                    20.hGap,
                    _buildLabel('Bio / Professional Summary'),
                    8.hGap,
                    CustomTextField(
                      controller: _bioController,
                      hintText:
                          'Tell us about your professional background and teaching experience...',
                      maxLine: 4,
                    ),
                    20.hGap,
                    _buildAccountStatusCard(),
                    32.hGap,
                    ActionButton(
                      isLoading: isSaving,
                      text: 'Save Changes',
                      onTap: _handleSave,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    20.hGap,
                    Center(
                      child: GestureDetector(
                        onTap: isSaving ? null : _handleDelete,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.delete_outline_rounded,
                              color: AppColors.red500,
                              size: 18.sp,
                            ),
                            6.wGap,
                            Text(
                              'Delete Mentor Account',
                              style: TextStyle(
                                color: AppColors.red500,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    20.hGap,
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              _buildAvatar(),
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
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      size: 16.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          12.hGap,
          Text(
            'Edit Photo',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.gray900,
            ),
          ),
          4.hGap,
          Text(
            'Update your profile picture',
            style: TextStyle(fontSize: 12.sp, color: AppColors.gray500),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountStatusCard() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account Status',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray900,
                  ),
                ),
                4.hGap,
                Text(
                  'Temporarily deactivate mentor profile',
                  style: TextStyle(fontSize: 12.sp, color: AppColors.gray500),
                ),
              ],
            ),
          ),
          Switch(
            value: _isActive,
            onChanged: (val) => setState(() => _isActive = val),
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final profilePic = widget.mentor.user.profilePicture;
    return CircleAvatar(
      radius: 52.r,
      backgroundColor: const Color(0xFFEFF6FF),
      backgroundImage:
          _newProfileImage != null
              ? FileImage(_newProfileImage!) as ImageProvider
              : (profilePic != null && profilePic.isNotEmpty
                  ? NetworkImage(profilePic)
                  : null),
      child:
          (_newProfileImage == null &&
                  (profilePic == null || profilePic.isEmpty))
              ? Text(
                _getInitials(widget.mentor.user.name),
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              )
              : null,
    );
  }

  Widget _buildSpecializationSection() {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        ..._specializations.map(
          (tag) => Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(15),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: AppColors.primary.withAlpha(40)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tag,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                6.wGap,
                GestureDetector(
                  onTap: () => _removeSpecialization(tag),
                  child: Icon(
                    Icons.close_rounded,
                    size: 16.sp,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: _showAddSpecializationDialog,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: AppColors.gray200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, size: 16.sp, color: AppColors.gray500),
                6.wGap,
                Text(
                  'Add',
                  style: TextStyle(
                    color: AppColors.gray500,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: const Color(0xff374151),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'M';
  }
}
