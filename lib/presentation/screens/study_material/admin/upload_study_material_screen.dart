import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/core/router/args.dart';
import 'package:gpsc_prep_app/domain/entities/test_without_material_model.dart';
import 'package:gpsc_prep_app/presentation/blocs/study_material/study_material_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/upload%20questions/upload_questions_bloc.dart';
import 'package:gpsc_prep_app/presentation/widgets/action_button.dart';
import 'package:gpsc_prep_app/presentation/widgets/custom_drop_down.dart';
import 'package:gpsc_prep_app/presentation/widgets/custom_text_field.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/enums/language_enum.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:gpsc_prep_app/utils/services/validator.dart';

class UploadStudyMaterialScreen extends StatefulWidget {
  const UploadStudyMaterialScreen({super.key});

  @override
  State<UploadStudyMaterialScreen> createState() =>
      _UploadStudyMaterialScreenState();
}

class _UploadStudyMaterialScreenState extends State<UploadStudyMaterialScreen> {
  final _titleController = TextEditingController();
  final _linkController = TextEditingController();
  final _testController = TextEditingController();
  int? _selectedTest;
  LanguageEnum? _selectedLanguage;
  final _formKey = GlobalKey<FormState>();
  bool _isFetchingTests = false;
  late StudyMaterialBloc _studyMaterialBloc;

  @override
  void initState() {
    super.initState();
    _studyMaterialBloc = context.read<StudyMaterialBloc>();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _linkController.dispose();
    _testController.dispose();
    _studyMaterialBloc.add(ClearTestWithoutMaterial());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return MultiBlocListener(
      listeners: [
        BlocListener<StudyMaterialBloc, StudyMaterialState>(
          listener: (context, state) {
            if (state is StudyMaterialAdded) {
              getIt<SnackBarHelper>().showSuccess(
                "Material uploaded successfully",
              );
              _titleController.clear();
              _linkController.clear();
              _testController.clear();
              setState(() {
                _selectedTest = null;
                _selectedLanguage = null;
                _isFetchingTests = false;
              });
            } else if (state is StudyMaterialLoading) {
              setState(() {
                _isFetchingTests = true;
              });
            } else if (state is TestWithoutMaterialLoaded ||
                state is StudyMaterialError) {
              setState(() {
                _isFetchingTests = false;
              });
            }
          },
        ),
        BlocListener<UploadQuestionsBloc, UploadQuestionsState>(
          listener: (context, state) {
            if (state is McqParseFileSuccess) {
              context.push(
                AppRoutes.reviewQuestion,
                extra: ReviewQuestionScreenArgs(
                  isTestUpload: state.isTestUpload,
                  payload: state.parsedPayload,
                  isFromStudyMaterial: true,
                  title: _titleController.text,
                  url: _linkController.text,
                  language: _selectedLanguage!.name,
                ),
              );
              _titleController.clear();
              _linkController.clear();
              _testController.clear();
              setState(() {
                _selectedTest = null;
                _selectedLanguage = null;
              });
            }
          },
        ),
      ],
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              title: Text(
                "Upload Study Material",
                style: AppTexts.titleTextStyle,
              ),
            ),
            body: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.sp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      padding: EdgeInsets.all(16.sp),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.1),
                            AppColors.primary.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12.sp),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.upload_file_rounded,
                              color: AppColors.primary,
                              size: 28.sp,
                            ),
                          ),
                          16.wGap,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Add New Study Material",
                                  style: textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                4.hGap,
                                Text(
                                  "Fill out the details below to upload your study material.",
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    20.hGap,

                    // Main Card
                    Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(24.sp),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel(
                              "Material Title",
                              Icons.title_rounded,
                            ),
                            8.hGap,
                            CustomTextField(
                              controller: _titleController,
                              hintText: "Enter title",
                              validator: Validator.validateTitle,
                            ),
                            20.hGap,

                            _buildFieldLabel(
                              "Resource Link",
                              Icons.link_rounded,
                            ),
                            8.hGap,
                            CustomTextField(
                              controller: _linkController,
                              hintText: "Paste Google Drive / PDF link",
                              validator: Validator.validateLink,
                            ),
                            20.hGap,

                            _buildFieldLabel(
                              "Select Language",
                              Icons.language_rounded,
                            ),
                            12.hGap,
                            Container(
                              padding: EdgeInsets.all(12.sp),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.05,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  width: 1,
                                ),
                              ),
                              child: RadioGroup<LanguageEnum>(
                                groupValue: _selectedLanguage,
                                onChanged: (value) {
                                  if (value != null) {
                                    _handleLanguageChange(value);
                                  }
                                },
                                child: Column(
                                  children: [
                                    _buildRadioOption(
                                      'English',
                                      LanguageEnum.en,
                                      _selectedLanguage == LanguageEnum.en,
                                    ),
                                    _buildRadioOption(
                                      'Gujarati',
                                      LanguageEnum.gj,
                                      _selectedLanguage == LanguageEnum.gj,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            20.hGap,

                            _buildFieldLabel(
                              "Select Test",
                              Icons.assignment_rounded,
                            ),
                            8.hGap,
                            BlocBuilder<StudyMaterialBloc, StudyMaterialState>(
                              builder: (context, state) {
                                if (state is TestWithoutMaterialLoaded) {
                                  // Get tests from backend
                                  final tests = state.tests;

                                  // Add "None" as a virtual first item
                                  final updatedTests = [
                                    const TestWithoutMaterial(
                                      id: -1,
                                      name: 'None',
                                    ),
                                    ...tests,
                                  ];

                                  return CustomTestDropdown(
                                    items: updatedTests,
                                    selectedValue: _selectedTest,
                                    hint: "Select Test",
                                    onChanged: (value) {
                                      setState(() {
                                        // If user selects “None”, store null in _selectedTest
                                        _selectedTest =
                                            (value == -1) ? null : value;
                                      });
                                    },
                                  );
                                } else if (state is StudyMaterialError) {
                                  return Text(
                                    state.failure.message,
                                    style: TextStyle(color: Colors.red),
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              },
                            ),
                            30.hGap,
                            ActionButton(
                              text: "Upload Material",
                              onTap: () {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  if (_selectedLanguage == null) {
                                    getIt<SnackBarHelper>().showError(
                                      "Please select a language first.",
                                    );
                                    return;
                                  }
                                  _studyMaterialBloc.add(
                                    UploadStudyMaterial(
                                      title: _titleController.text,
                                      url: _linkController.text,
                                      language: _selectedLanguage!.name,
                                      testId: _selectedTest,
                                    ),
                                  );
                                }
                              },
                            ),

                            20.hGap,
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.2,
                                    ),
                                    thickness: 1,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.sp,
                                  ),
                                  child: Text(
                                    "Or",
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.2,
                                    ),
                                    thickness: 1,
                                  ),
                                ),
                              ],
                            ),
                            20.hGap,

                            // Alternative action
                            Container(
                              padding: EdgeInsets.all(16.sp),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.05,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.add_circle_outline_rounded,
                                        color: AppColors.primary,
                                        size: 20.sp,
                                      ),
                                      8.wGap,
                                      Expanded(
                                        child: Text(
                                          "Create a new test",
                                          style: textTheme.bodyMedium?.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  12.hGap,
                                  ActionButton(
                                    text: "Upload with New Test",
                                    onTap: () {
                                      if (_selectedTest != null) {
                                        getIt<SnackBarHelper>().showError(
                                          "Please clear the selected test to create a new one.",
                                        );
                                        return;
                                      }
                                      if (_formKey.currentState?.validate() ??
                                          false) {
                                        if (_selectedLanguage == null) {
                                          getIt<SnackBarHelper>().showError(
                                            "Please select a language first.",
                                          );
                                          return;
                                        }
                                        context.read<UploadQuestionsBloc>().add(
                                          McqParseUploadFile(
                                            isTestUpload: true,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
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
            ),
          ),

          // Full screen overlay loader
          if (_isFetchingTests)
            Container(
              color: Colors.black.withValues(alpha: 0.4),
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: AppColors.primary),
        8.wGap,
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.primary.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildRadioOption(
    String label,
    LanguageEnum languageEnum,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () => _handleLanguageChange(languageEnum),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 8.sp),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Radio<LanguageEnum>.adaptive(
              value: languageEnum,
              activeColor: AppColors.primary,
            ),
            8.wGap,
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color:
                    isSelected
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Extract the common logic
  void _handleLanguageChange(LanguageEnum value) {
    setState(() {
      _selectedLanguage = value;
      _selectedTest = null;
    });
    _studyMaterialBloc.add(FetchTestWithoutMaterial(language: value));
  }
}
