import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/presentation/blocs/add_course/course_bloc.dart';
import 'package:gpsc_prep_app/presentation/widgets/action_button.dart';
import 'package:gpsc_prep_app/presentation/widgets/elevated_container.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:gpsc_prep_app/utils/services/validator.dart';

class AddCourseScreen extends StatefulWidget {
  const AddCourseScreen({super.key});

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceSingleController = TextEditingController();
  final TextEditingController _priceDualController = TextEditingController();
  String _selectedTestType = 'Prelims'; // Default value
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final CourseBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = getIt<CourseBloc>();
  }

  @override
  void dispose() {
    _courseController.dispose();
    _descriptionController.dispose();
    _priceSingleController.dispose();
    _priceDualController.dispose();
    super.dispose();
  }

  void _saveCourse() {
    if (_formKey.currentState!.validate()) {
      final courseName = _courseController.text.trim();
      final description = _descriptionController.text.trim();
      final priceSingle = int.tryParse(_priceSingleController.text.trim());
      final priceDual = int.tryParse(_priceDualController.text.trim());

      _bloc.add(
        AddCourseRequested(
          name: courseName,
          description: description.isNotEmpty ? description : null,
          testType: _selectedTestType.toLowerCase(),
          priceSingle: priceSingle,
          priceDual: priceDual,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<CourseBloc, CourseState>(
        listener: (context, state) {
          if (state is AddCourseSuccess) {
            getIt<SnackBarHelper>().showSuccess(
              'Course "${state.course.name}" added!',
            );
            context.pop({
              'id': state.course.id,
              'name': state.course.name,
              'description': state.course.description,
            });
          } else if (state is AddCourseFailure) {
            getIt<SnackBarHelper>().showError(state.error);
          }
        },
        builder: (context, state) {
          final isLoading = state is CourseLoading;
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Add New Course',
                style: AppTexts.titleTextStyle.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.all(AppPaddings.defaultPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedContainer(
                      child: Padding(
                        padding: EdgeInsets.all(20.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Course Details',
                              style: AppTexts.subTitle.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            16.hGap,
                            TextFormField(
                              controller: _courseController,
                              enabled: !isLoading,
                              decoration: _inputDecoration(
                                label: 'Course Name',
                                hint:
                                    'Enter course name (e.g., GPSC Class 1-2)',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a course name';
                                }
                                return null;
                              },
                            ),
                            16.hGap,
                            TextFormField(
                              controller: _descriptionController,
                              enabled: !isLoading,
                              maxLines: 3,
                              decoration: _inputDecoration(
                                label: 'Description',
                                hint: 'Enter course description',
                              ),
                            ),
                            16.hGap,
                            DropdownButtonFormField<String>(
                              initialValue: _selectedTestType,
                              dropdownColor: Colors.white,
                              onChanged:
                                  isLoading
                                      ? null
                                      : (value) {
                                        if (value != null) {
                                          setState(() {
                                            _selectedTestType = value;
                                          });
                                        }
                                      },
                              decoration: _inputDecoration(
                                label: 'Test Type',
                                hint: null,
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Prelims',
                                  child: Text('Prelims'),
                                ),
                                DropdownMenuItem(
                                  value: 'Mains',
                                  child: Text('Mains'),
                                ),
                              ],
                            ),
                            16.hGap,
                            TextFormField(
                              controller: _priceSingleController,
                              enabled: !isLoading,
                              keyboardType: TextInputType.number,
                              decoration: _inputDecoration(
                                label: 'Price (Single Assessment)',
                                hint: 'Enter price (e.g., 500)',
                              ),
                              validator: (value) {
                                return Validator.validatePrice(
                                  value,
                                  fieldName: 'Price (Single Assessment)',
                                );
                              },
                            ),
                            16.hGap,
                            TextFormField(
                              controller: _priceDualController,
                              enabled: !isLoading,
                              keyboardType: TextInputType.number,
                              decoration: _inputDecoration(
                                label: 'Price (Dual Assessment)',
                                hint:
                                    _selectedTestType == 'Mains'
                                        ? 'Enter price (e.g., 800)'
                                        : 'Enter price (optional)',
                              ),
                              validator: (value) {
                                if (_selectedTestType == 'Mains') {
                                  return Validator.validatePrice(
                                    value,
                                    fieldName: 'Price (Dual Assessment)',
                                  );
                                }
                                if (value != null && value.trim().isNotEmpty) {
                                  final price = int.tryParse(value);
                                  if (price == null) {
                                    return 'Please enter a valid number';
                                  }
                                  if (price < 0) {
                                    return 'Price cannot be negative';
                                  }
                                }
                                return null;
                              },
                            ),
                            24.hGap,
                            SizedBox(
                              width: double.infinity,
                              child: ActionButton(
                                onTap: isLoading ? () {} : _saveCourse,
                                text: isLoading ? 'Adding...' : 'Add Course',
                                icon:
                                    isLoading
                                        ? Icons.hourglass_empty
                                        : Icons.add,
                                backgroundColor:
                                    isLoading ? Colors.grey : AppColors.primary,
                              ),
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

  InputDecoration _inputDecoration({required String label, String? hint}) {
    return InputDecoration(
      labelText: label,
      floatingLabelStyle: TextStyle(color: AppColors.primary),
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: AppColors.primary),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      alignLabelWithHint: true,
    );
  }
}
