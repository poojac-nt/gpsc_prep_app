import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/presentation/widgets/action_button.dart';
import 'package:gpsc_prep_app/presentation/widgets/custom_drop_down.dart';
import 'package:gpsc_prep_app/presentation/widgets/custom_text_field.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

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
  String? _selectedTest;
  String _selectedLanguage = 'en'; // Default language code

  final List<TestItem> dummyTests = [
    TestItem(id: '1', name: 'Unit Test'),
    TestItem(id: '2', name: 'Integration Test'),
    TestItem(id: '3', name: 'Widget Test'),
    TestItem(id: '4', name: 'End-to-End Test'),
    TestItem(id: '5', name: 'Performance Test'),
    TestItem(id: '6', name: 'Security Test'),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _linkController.dispose();
    _testController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Study Material", style: AppTexts.titleTextStyle),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon
            Container(
              padding: EdgeInsets.all(16.sp),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.primary.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.sp),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
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

            // Main card
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: AppColors.primary.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(24.sp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title field with label
                    _buildFieldLabel("Material Title", Icons.title_rounded),
                    8.hGap,
                    CustomTextField(
                      controller: _titleController,
                      hintText: "Enter title",
                    ),
                    20.hGap,
                    // Link field with label
                    _buildFieldLabel("Resource Link", Icons.link_rounded),
                    8.hGap,
                    CustomTextField(
                      controller: _linkController,
                      hintText: "Paste Google Drive / PDF link",
                    ),
                    20.hGap,
                    // Test selector with label
                    _buildFieldLabel("Select Test", Icons.assignment_rounded),
                    8.hGap,
                    CustomTestDropdown(
                      items: dummyTests,
                      selectedValue: _selectedTest,
                      hint: "Select Test",
                      onChanged: (value) {
                        setState(() {
                          _selectedTest = value;
                        });
                      },
                    ),
                    20.hGap,
                    // Language selector with label
                    _buildFieldLabel("Select Language", Icons.language_rounded),
                    12.hGap,
                    Container(
                      padding: EdgeInsets.all(12.sp),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildRadioOption(
                            'English',
                            'en',
                            _selectedLanguage == 'en',
                          ),
                          8.hGap,
                          _buildRadioOption(
                            'Gujarati',
                            'gj',
                            _selectedLanguage == 'gj',
                          ),
                        ],
                      ),
                    ),
                    30.hGap,
                    // Upload button
                    ActionButton(
                      text: "Upload Material",
                      onTap: () {
                        // You can access the selected language code here
                        print('Selected language code: $_selectedLanguage');
                      },
                    ),
                    20.hGap,
                    // Divider with text
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: AppColors.primary.withOpacity(0.2),
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.sp),
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
                            color: AppColors.primary.withOpacity(0.2),
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
                        color: AppColors.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.1),
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
                            onTap: () {},
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
            color: AppColors.primary.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildRadioOption(String label, String value, bool isSelected) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedLanguage = value;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 8.sp),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _selectedLanguage,
              onChanged: (newValue) {
                setState(() {
                  _selectedLanguage = newValue!;
                });
              },
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
                        : AppColors.primary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
