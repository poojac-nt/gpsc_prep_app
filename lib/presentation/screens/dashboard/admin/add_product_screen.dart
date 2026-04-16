import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/presentation/blocs/add_product/add_product_bloc.dart';
import 'package:gpsc_prep_app/presentation/widgets/action_button.dart';
import 'package:gpsc_prep_app/presentation/widgets/elevated_container.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:gpsc_prep_app/data/models/payloads/product_payload.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _productIdController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _titleFocusNode = FocusNode();
  final _productIdFocusNode = FocusNode();
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _titleFocusNode.addListener(() => setState(() {}));
    _productIdFocusNode.addListener(() => setState(() {}));
    _priceFocusNode.addListener(() => setState(() {}));
    _descriptionFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _productIdController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _titleFocusNode.dispose();
    _productIdFocusNode.dispose();
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final payload = ProductPayload(
        title: _titleController.text.trim(),
        productId: _productIdController.text.trim(),
        price: int.parse(_priceController.text.trim()),
        description: _descriptionController.text.trim(),
        isActive: _isActive,
      );
      context.read<AddProductBloc>().add(AddProductRequested(payload: payload));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<AddProductBloc>(),
      child: BlocConsumer<AddProductBloc, AddProductState>(
        listener: (context, state) {
          if (state is AddProductSuccess) {
            _titleController.clear();
            _productIdController.clear();
            _priceController.clear();
            _descriptionController.clear();
            setState(() {
              _isActive = true;
            });
          }
        },
        builder: (context, state) {
          final isLoading = state is AddProductLoading;
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              title: Text(
                'Add Product',
                style: AppTexts.titleTextStyle.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 22.sp,
                  color: AppColors.gray900,
                ),
              ),
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.black,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Product Overview',
                      style: AppTexts.heading.copyWith(
                        fontSize: 20.sp,
                        color: AppColors.gray900,
                        letterSpacing: -0.6,
                      ),
                    ),
                    8.hGap,
                    Text(
                      'Provide the necessary details to set up a new in-app product for students.',
                      style: AppTexts.subTitle.copyWith(
                        color: Colors.black,
                        fontSize: 14.sp,
                        height: 1.4,
                      ),
                    ),
                    32.hGap,
                    _buildTextField(
                      controller: _titleController,
                      focusNode: _titleFocusNode,
                      label: 'Product Title',
                      hint: 'e.g., GPSC Premium Pass',
                      icon: Icons.label_important_outline_rounded,
                      validator:
                          (val) =>
                              val == null || val.isEmpty
                                  ? 'Please enter a title'
                                  : null,
                    ),
                    24.hGap,
                    _buildTextField(
                      controller: _productIdController,
                      focusNode: _productIdFocusNode,
                      label: 'Store Product ID',
                      hint: 'e.g., premium_subscription_yearly',
                      icon: Icons.token_outlined,
                      validator:
                          (val) =>
                              val == null || val.isEmpty
                                  ? 'Product ID is required'
                                  : null,
                    ),
                    24.hGap,
                    _buildTextField(
                      controller: _priceController,
                      focusNode: _priceFocusNode,
                      label: 'Price (INR)',
                      hint: '999',
                      icon: Icons.currency_rupee_rounded,
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.isEmpty)
                          return 'Price is required';
                        if (int.tryParse(val) == null)
                          return 'Enter a valid number';
                        return null;
                      },
                    ),
                    24.hGap,
                    _buildTextField(
                      controller: _descriptionController,
                      focusNode: _descriptionFocusNode,
                      label: 'Detailed Description',
                      hint: 'Describe what this product offers to students...',
                      icon: Icons.description_outlined,
                      maxLines: 4,
                      validator:
                          (val) =>
                              val == null || val.isEmpty
                                  ? 'Description is required'
                                  : null,
                    ),
                    // 32.hGap,
                    // _buildStatusToggle(),
                    32.hGap,
                    ActionButton(
                      onTap: isLoading ? () {} : _submit,
                      text: isLoading ? 'CREATING...' : 'ADD PRODUCT',
                      icon: isLoading ? null : Icons.add_circle_outline_rounded,
                      isLoading: isLoading,
                      height: 56.h,
                      borderRadius: BorderRadius.circular(16.r),
                      gradient: const LinearGradient(
                        colors: [Color(0xff3b82f6), Color(0xff2563eb)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    60.hGap,
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusToggle() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.gray100),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color:
                  _isActive ? const Color(0xffecfdf5) : const Color(0xfffef2f2),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              _isActive
                  ? Icons.check_circle_outline_rounded
                  : Icons.highlight_off_rounded,
              color:
                  _isActive ? const Color(0xff059669) : const Color(0xffdc2626),
              size: 20.sp,
            ),
          ),
          12.wGap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Status',
                  style: AppTexts.labelTextStyle.copyWith(fontSize: 14.sp),
                ),
                Text(
                  _isActive ? 'Visible to students' : 'Hidden from store',
                  style: AppTexts.subTitle.copyWith(
                    fontSize: 12.sp,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _isActive,
            onChanged: (val) => setState(() => _isActive = val),
            activeColor: const Color(0xff3b82f6),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return FormField<String>(
      initialValue: controller.text,
      validator: validator,
      builder: (FormFieldState<String> fieldState) {
        final isFocused = focusNode.hasFocus;
        final hasError = fieldState.hasError;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTexts.labelTextStyle.copyWith(
                fontSize: 14.sp,
                color: AppColors.gray700,
              ),
            ),
            8.hGap,
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: (isFocused ? AppColors.primary : AppColors.gray200),
                  width: (isFocused || hasError) ? 1.5 : 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: maxLines > 1 ? 18.h : 15.h,
                      left: 16.w,
                      right: 0,
                    ),
                    child: Icon(
                      icon,
                      color: isFocused ? AppColors.primary : AppColors.gray400,
                      size: 20.sp,
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      keyboardType: keyboardType,
                      maxLines: maxLines,
                      onChanged: (val) {
                        fieldState.didChange(val);
                      },
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.gray900,
                      ),
                      decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: TextStyle(
                          color: AppColors.gray400,
                          fontSize: 14.sp,
                        ),
                        filled: false,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 14.h,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        errorStyle: const TextStyle(height: 0, fontSize: 0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (hasError)
              Padding(
                padding: EdgeInsets.only(top: 6.h, left: 16.w),
                child: Text(
                  fieldState.errorText!,
                  style: TextStyle(
                    color: Colors.red.shade400,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
