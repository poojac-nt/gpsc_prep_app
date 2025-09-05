import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/router/args.dart';
import 'package:gpsc_prep_app/domain/entities/desc_test_model.dart';
import 'package:gpsc_prep_app/presentation/blocs/question/question_bloc.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

import '../../../utils/app_constants.dart';

class DescriptiveTestInstructionScreen extends StatefulWidget {
  final DescTestModel descTestModel;

  const DescriptiveTestInstructionScreen({
    super.key,
    required this.descTestModel,
  });

  @override
  State<DescriptiveTestInstructionScreen> createState() =>
      _DescriptiveTestInstructionScreenState();
}

class _DescriptiveTestInstructionScreenState
    extends State<DescriptiveTestInstructionScreen> {
  @override
  void initState() {
    super.initState();
    context.read<QuestionBloc>().add(
      LoadDescQuestion(widget.descTestModel.id, "en"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.descTestModel.name, style: AppTexts.titleTextStyle),
      ),
      body: BlocBuilder<QuestionBloc, QuestionState>(
        builder: (context, state) {
          if (state is QuestionLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DescQuestionLoaded) {
            return ListView.separated(
              itemBuilder: (context, index) {
                final q = state.questionsModels[index].questionEn;
                return InkWell(
                  onTap: () {
                    context.push(
                      AppRoutes.descriptiveTestScreen,
                      extra: DescTestScreenArgs(
                        dailyTestModel: widget.descTestModel,
                        initialInex: index,
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16.r),
                  splashColor: AppColors.primary.withOpacity(0.1),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 18.h,
                      horizontal: 16.w,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Hero(
                          tag: 'questionNumber$index',
                          child: CircleAvatar(
                            radius: 22.r,
                            backgroundColor: AppColors.primary.withOpacity(
                              0.15,
                            ),
                            child: Text(
                              "${index + 1}",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        10.wGap,
                        Expanded(
                          child: Text(
                            q.questionTxt,
                            style: AppTexts.subTitle.copyWith(
                              fontSize: 17.sp,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                              height: 1.3,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        /// Animated Arrow
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 500),
                          builder:
                              (context, value, child) => Transform.translate(
                                offset: Offset(4 * value, 0),
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 20,
                                  color: AppColors.primary,
                                  shadows: [
                                    Shadow(
                                      color: AppColors.primary.withOpacity(
                                        0.15,
                                      ),
                                      blurRadius: 3,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                        ),
                      ],
                    ),
                  ),
                ).padAll(AppPaddings.appPaddingInt);
              },
              separatorBuilder: (context, index) => 2.hGap, // ✅ Fixed
              itemCount: state.questionsModels.length,
            );
          } else if (state is QuestionLoadFailed) {
            return Center(
              child: Text('Failed to load questions: ${state.failure.message}'),
            );
          }
          return const Center(child: Text('No Questions Available'));
        },
      ),
    );
  }
}
