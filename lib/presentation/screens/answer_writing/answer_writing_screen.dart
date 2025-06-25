import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/presentation/widgets/action_button.dart';
import 'package:gpsc_prep_app/presentation/widgets/bordered_container.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/sizedbox.dart';
import '../home/widgets/selection_drawer.dart';

class AnswerWritingScreen extends StatelessWidget {
  const AnswerWritingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Answer Writing Practice'),
        shape: Border(bottom: BorderSide(width: 1.0)),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      body: Padding(
        padding: AppPaddings.defaultPadding,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Answer Writing",
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ActionButton(text: "Start New Practice", onTap: () {}),
                ),
              ],
            ),
            20.hGap,
            BorderedContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined),
                      5.wGap,
                      Text(
                        "Daily Practice",
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "Subject based daily writing prompts",
                    // style: AppTexts.descriptionTextStyle,
                  ),
                  10.hGap,
                  BorderedContainer(
                    padding: EdgeInsets.all(15),
                    radius: BorderRadius.zero,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Good Governance",
                              style: AppTexts.labelTextStyle.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "General Studies - 250 words",
                              // style: AppTexts.descriptionTextStyle,
                            ),
                          ],
                        ),
                        10.wGap,
                        Expanded(
                          child: ActionButton(text: "Write", onTap: () {}),
                        ),
                      ],
                    ),
                  ),
                  8.hGap,
                  BorderedContainer(
                    padding: EdgeInsets.all(15),
                    radius: BorderRadius.zero,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Economic Reforms",
                                style: AppTexts.labelTextStyle.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Current Affairs - 250 wordssssssssssssssssssssssssssssssssssssssss",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                // style: AppTexts.descriptionTextStyle,
                              ),
                            ],
                          ),
                        ),
                        10.wGap,
                        Expanded(
                          flex: 1,
                          child: ActionButton(text: "Write", onTap: () {}),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
