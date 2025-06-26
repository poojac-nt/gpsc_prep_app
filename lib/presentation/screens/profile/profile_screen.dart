import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/presentation/widgets/bordered_container.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/sizedbox.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.edit))],
      ),
      body: Padding(
        padding: AppPaddings.defaultPadding,
        child: Column(
          children: [
            BorderedContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Profile Photo",
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  10.hGap,
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(
                            "https://picsum.photos/206",
                          ),
                          radius: 40.r,
                        ),

                        Text(
                          "John Deo",
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "John.deo@example.cooooooooooooooom",
                          // style: AppTexts.descriptionTextStyle,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            10.hGap,
            BorderedContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Quick Stats",
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  10.hGap,
                  QuickStats(text: "Test Taken", num: "64"),
                  10.hGap,
                  QuickStats(text: "Average Score", num: "83"),
                  10.hGap,
                  QuickStats(text: "Study Strike", num: "12 days"),
                  10.hGap,
                  QuickStats(text: "Rank", num: "#264"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuickStats extends StatelessWidget {
  const QuickStats({super.key, required this.text, required this.num});
  final String text;
  final String num;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Text(text, style: AppTexts.descriptionTextStyle),
        Text(
          num,
          // style: AppTexts.descriptionTextStyle.copyWith(color: Colors.black),
        ),
      ],
    );
  }
}
