import 'package:flutter/material.dart';
import 'package:gpsc_prep_app/presentation/widgets/action_button.dart';
import 'package:gpsc_prep_app/presentation/widgets/bordered_container.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

class TestTile extends StatelessWidget {
  const TestTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.buttonTitle,
    this.widgets = const <Widget>[],
  });

  final String title;
  final String subtitle;
  final String buttonTitle;
  final VoidCallback onTap;
  final List<Widget> widgets;

  @override
  Widget build(BuildContext context) {
    return BorderedContainer(
      borderColor: AppColors.accentColor,
      padding: EdgeInsets.all(10),
      radius: BorderRadius.circular(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTexts.title),
              10.wGap,
              Text(subtitle, style: AppTexts.subTitle),
            ],
          ),
          if (widgets.isNotEmpty) 10.wGap,
          ...widgets,
          10.wGap,
          IntrinsicWidth(child: ActionButton(text: buttonTitle, onTap: onTap)),
        ],
      ),
    );
  }
}
