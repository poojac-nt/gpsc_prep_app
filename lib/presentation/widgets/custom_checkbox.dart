import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/bloc/question/question_bloc.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/cubit/question/question_cubit.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/cubit/question/question_cubit_state.dart';

import '../../utils/app_constants.dart';

class CustomCheckbox extends StatelessWidget {
  const CustomCheckbox({
    super.key,
    required this.value,
    this.isRounded = false,
    required this.title,
    required this.ontap,
  });

  final bool value;
  final String title;
  final bool isRounded;
  final VoidCallback ontap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuestionCubit, QuestionCubitState>(
      builder: (BuildContext context, state) {
        if (state is QuestionCubitLoaded) {
          return Row(
            children: [
              Checkbox(
                shape:
                    isRounded
                        ? RoundedRectangleBorder(
                          borderRadius: AppBorders.borderRadius,
                          side: BorderSide(color: Colors.green, width: 1),
                        )
                        : null,
                value: state.answeredStatus[state.currentIndex],
                onChanged: (value) {
                  state.answeredStatus[state.currentIndex] = true;
                },
                fillColor: WidgetStateProperty.resolveWith((state) {
                  if (state.contains(WidgetState.selected)) {
                    return AppColors.primary;
                  }
                  return Colors.white;
                }),
                checkColor: Colors.white,
              ),
              Expanded(
                child: Text(
                  maxLines: 2,
                  title,
                  style: AppTexts.labelTextStyle.copyWith(fontSize: 13.sp),
                ),
              ),
            ],
          );
        }
        return Container();
      },
    );
  }
}
