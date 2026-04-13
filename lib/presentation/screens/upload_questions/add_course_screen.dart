import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/domain/entities/product_model.dart';
import 'package:gpsc_prep_app/presentation/blocs/add_course/course_bloc.dart';
import 'package:gpsc_prep_app/presentation/widgets/action_button.dart';
import 'package:gpsc_prep_app/presentation/widgets/elevated_container.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/enums/course_test_type.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

class AddCourseScreen extends StatefulWidget {
  const AddCourseScreen({super.key});

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  CourseTestType _selectedTestType = CourseTestType.prelims; // Default value
  List<ProductModel> _products = [];
  ProductModel? _selectedSingleProduct;
  ProductModel? _selectedDualProduct;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final CourseBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = getIt<CourseBloc>();
    _bloc.add(FetchProductsRequested());
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
          testType: _selectedTestType,
          priceSingle: _selectedSingleProduct?.id,
          priceDual:
              _selectedTestType == CourseTestType.mains
                  ? _selectedDualProduct?.id
                  : null,
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
            _courseController.clear();
            _descriptionController.clear();
            setState(() {
              _selectedTestType = CourseTestType.prelims;
              _selectedSingleProduct = null;
              _selectedDualProduct = null;
            });
          } else if (state is FetchProductsSuccess) {
            setState(() {
              _products = state.products;
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
                            DropdownButtonFormField<CourseTestType>(
                              initialValue: _selectedTestType,
                              dropdownColor: Colors.white,
                              onChanged:
                                  isLoading
                                      ? null
                                      : (value) {
                                        if (value != null) {
                                          setState(() {
                                            _selectedTestType = value;
                                            if (value ==
                                                CourseTestType.prelims) {
                                              _selectedDualProduct = null;
                                            }
                                          });
                                        }
                                      },
                              decoration: _inputDecoration(
                                label: 'Test Type',
                                hint: null,
                              ),
                              items:
                                  CourseTestType.values.map((type) {
                                    return DropdownMenuItem(
                                      value: type,
                                      child: Text(type.displayName),
                                    );
                                  }).toList(),
                            ),
                            16.hGap,
                            DropdownButtonFormField<ProductModel>(
                              initialValue: _selectedSingleProduct,
                              dropdownColor: Colors.white,
                              onChanged:
                                  isLoading
                                      ? null
                                      : (value) {
                                        setState(() {
                                          _selectedSingleProduct = value;
                                          if (_selectedDualProduct == value) {
                                            _selectedDualProduct = null;
                                          }
                                        });
                                      },
                              decoration: _inputDecoration(
                                label: 'Price (Single Assessment)',
                                hint: 'Select product/price',
                              ),
                              items:
                                  _products.map((product) {
                                    return DropdownMenuItem(
                                      value: product,
                                      child: Text(
                                        '${product.title} (₹${product.price})',
                                      ),
                                    );
                                  }).toList(),
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a product';
                                }
                                return null;
                              },
                            ),
                            16.hGap,
                            DropdownButtonFormField<ProductModel>(
                              initialValue:
                                  _selectedTestType == CourseTestType.prelims
                                      ? null
                                      : _selectedDualProduct,
                              dropdownColor: Colors.white,
                              onChanged:
                                  isLoading ||
                                          _selectedTestType ==
                                              CourseTestType.prelims
                                      ? null
                                      : (value) {
                                        setState(() {
                                          _selectedDualProduct = value;
                                        });
                                      },
                              decoration: _inputDecoration(
                                label: 'Price (Dual Assessment)',
                                hint:
                                    _selectedTestType == CourseTestType.prelims
                                        ? 'Not applicable for Prelims'
                                        : 'Select product/price',
                              ),
                              items:
                                  _selectedTestType == CourseTestType.prelims
                                      ? []
                                      : _products
                                          .where(
                                            (p) =>
                                                p.id !=
                                                _selectedSingleProduct?.id,
                                          )
                                          .map((product) {
                                            return DropdownMenuItem(
                                              value: product,
                                              child: Text(
                                                '${product.title} (₹${product.price})',
                                              ),
                                            );
                                          })
                                          .toList(),
                              validator: (value) {
                                if (_selectedTestType == CourseTestType.mains &&
                                    value == null) {
                                  return 'Please select a product';
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
