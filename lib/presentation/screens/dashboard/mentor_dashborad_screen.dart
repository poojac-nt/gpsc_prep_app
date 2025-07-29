import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/presentation/screens/dashboard/widgets/selection_drawer.dart';
import 'package:gpsc_prep_app/presentation/screens/dashboard/widgets/stats_widget.dart';
import 'package:gpsc_prep_app/presentation/widgets/action_button.dart';
import 'package:gpsc_prep_app/presentation/widgets/bordered_container.dart';
import 'package:gpsc_prep_app/presentation/widgets/elevated_container.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

class MentorDashboardScreen extends StatefulWidget {
  const MentorDashboardScreen({super.key});

  @override
  State<MentorDashboardScreen> createState() => _MentorDashboardScreenState();
}

class _MentorDashboardScreenState extends State<MentorDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SelectionDrawer(),
      drawerEdgeDragWidth: 150,
      appBar: AppBar(title: Text('Dashboard', style: AppTexts.titleTextStyle)),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedContainer(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 15.h,
                  ),
                  child: StatsWidget(
                    text: 'Pending Reviews ',
                    num: '24',
                    icon: Icons.error_outline_outlined,
                    iconColor: Colors.orange,
                  ),
                ),
              ),
              10.wGap,
              Expanded(
                child: ElevatedContainer(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 15.h,
                  ),
                  child: StatsWidget(
                    text: 'Completed Today',
                    num: '78%',
                    icon: Icons.check_circle_outline,
                    iconColor: Colors.green,
                  ),
                ),
              ),
            ],
          ),
          10.hGap,
          Row(
            children: [
              Expanded(
                child: ElevatedContainer(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 15.h,
                  ),
                  child: StatsWidget(
                    text: 'Average Score',
                    num: '12 days',
                    icon: Icons.description_outlined,
                    iconColor: Colors.blueAccent,
                  ),
                ),
              ),
              10.wGap,
              Expanded(
                child: ElevatedContainer(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 15.h,
                  ),
                  child: StatsWidget(
                    text: 'Total Students',
                    num: '+15%',
                    icon: Icons.person_outline,
                    iconColor: Colors.purple,
                  ),
                ),
              ),
            ],
          ),
          10.hGap,
          ElevatedContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Student Submissions',
                  style: AppTexts.titleTextStyle.copyWith(fontSize: 16.sp),
                ),
                Text(
                  'Review and evaluate descriptive test submissions',
                  style: TextStyle(fontSize: 10.sp),
                ),
                5.hGap,
                BorderedContainer(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'John Doe',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text('STU001'),
                          Text(
                            "Economics Essay Test",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: const [Text('2024-12-20'), Text('14:30')],
                          ),
                          const Text('3 questions • 50 marks'),
                        ],
                      ),
                      Expanded(
                        child: Container(
                          color: Colors.black,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: EdgeInsets.all(5.sp),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(20.sp),
                                ),
                                child: Text(
                                  "Pending",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IntrinsicWidth(
                                child: ActionButton(
                                  text: 'Evaluate',
                                  onTap: () {},
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ).padAll(AppPaddings.defaultPadding),
    );
  }
}
