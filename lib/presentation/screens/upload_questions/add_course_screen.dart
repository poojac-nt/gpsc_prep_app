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

class AddCourseScreen extends StatefulWidget {
  const AddCourseScreen({super.key});

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
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
    super.dispose();
  }

  void _saveCourse() {
    if (_formKey.currentState!.validate()) {
      final courseName = _courseController.text.trim();
      final description = _descriptionController.text.trim();
      _bloc.add(
        AddCourseRequested(
          name: courseName,
          description: description.isNotEmpty ? description : null,
          testType: _selectedTestType.toLowerCase(),
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
                              decoration: InputDecoration(
                                labelText: 'Course Name',
                                floatingLabelStyle: TextStyle(
                                  color: AppColors.primary,
                                ),
                                hintText:
                                    'Enter course name (e.g., GPSC Class 1-2)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                  borderSide: BorderSide(
                                    color: AppColors.primary,
                                  ),
                                ),
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
                              decoration: InputDecoration(
                                labelText: 'Description',
                                floatingLabelStyle: TextStyle(
                                  color: AppColors.primary,
                                ),
                                hintText: 'Enter course description (optional)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                  borderSide: BorderSide(
                                    color: AppColors.primary,
                                  ),
                                ),
                                alignLabelWithHint: true,
                              ),
                            ),
                            16.hGap,
                            DropdownButtonFormField<String>(
                              value: _selectedTestType,
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
                              decoration: InputDecoration(
                                labelText: 'Test Type',
                                floatingLabelStyle: TextStyle(
                                  color: AppColors.primary,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                  borderSide: BorderSide(
                                    color: AppColors.primary,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 12.h,
                                ),
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
}
