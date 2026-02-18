import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/domain/entities/course_model.dart';
import 'package:gpsc_prep_app/presentation/widgets/action_button.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

import '../../../core/router/args.dart';
import '../../blocs/add_course/course_bloc.dart';

class PaidCourseListScreen extends StatefulWidget {
  const PaidCourseListScreen({super.key});

  @override
  State<PaidCourseListScreen> createState() => _PaidCourseListScreenState();
}

class _PaidCourseListScreenState extends State<PaidCourseListScreen> {
  @override
  void initState() {
    context.read<CourseBloc>().add(FetchCoursesRequested());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Premium Courses",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocBuilder<CourseBloc, CourseState>(
        builder: (context, state) {
          if (state is CourseLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is FetchCoursesSuccess) {
            if (state.courses.isEmpty) {
              return const Center(child: Text("No courses found"));
            }
            final courses = state.courses;
            return ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              itemCount: courses.length, // Mock data count
              separatorBuilder: (context, index) => 16.hGap,
              itemBuilder: (context, index) {
                return PaidCourseListCard(courseModel: courses[index]);
              },
            );
          }
          if (state is FetchCoursesFailure) {
            return Center(child: Text(state.error));
          }
          return SizedBox.shrink();
        },
      ),
    );
  }
}

class PaidCourseListCard extends StatelessWidget {
  final CourseModel courseModel;

  const PaidCourseListCard({super.key, required this.courseModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            courseModel.name,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111827), // Gray 900
              height: 1.3,
            ),
          ),

          20.hGap,
          Divider(color: Colors.grey.shade100, height: 1),
          20.hGap,
          // Bottom Row: Price & Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Column(
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: [
              //     Text(
              //       "ENROLLMENT FEE",
              //       style: TextStyle(
              //         fontSize: 10.sp,
              //         fontWeight: FontWeight.bold,
              //         color: const Color(0xFF9CA3AF), // Gray 400
              //         letterSpacing: 0.5,
              //       ),
              //     ),
              //     4.hGap,
              //     Text(
              //       "Free",
              //       style: TextStyle(
              //         fontSize: 18.sp,
              //         fontWeight: FontWeight.w900,
              //         color: const Color(0xFF111827), // Gray 900
              //       ),
              //     ),
              //   ],
              // ),
              // 65.wGap,
              Expanded(
                child: ActionButton(
                  text: "Explore Course",
                  onTap: () {
                    context.push(
                      AppRoutes.courseDetails,
                      extra: CourseDetailsScreenArgs(courseModel: courseModel),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
