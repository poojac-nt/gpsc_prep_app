import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/presentation/widgets/bordered_container.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

class TestModule extends StatelessWidget {
  const TestModule({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.cards = const <Widget>[],
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Widget> cards;

  @override
  Widget build(BuildContext context) {
    return BorderedContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.black),
              10.wGap,
              Text(
                title,
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Text(subtitle, style: AppTexts.subTitle),
          10.hGap,
          ...cards,
        ],
      ),
    );
  }
}
