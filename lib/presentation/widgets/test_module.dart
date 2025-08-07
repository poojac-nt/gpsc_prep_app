import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/presentation/widgets/elevated_container.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

class TestModule extends StatelessWidget {
  const TestModule({
    super.key,
    required this.title,
    this.isReview = false,
    this.onTap,
    this.subtitle,
    this.iconSize = 24,
    this.fontSize = 24,
    this.iconColor = Colors.black,
    this.prefixIcon,
    this.cards = const <Widget>[],
  });

  final String title;
  final bool isReview;
  final VoidCallback? onTap;
  final String? subtitle;
  final double? iconSize;
  final double? fontSize;
  final Color? iconColor;
  final IconData? prefixIcon;
  final List<Widget> cards;

  @override
  Widget build(BuildContext context) {
    return ElevatedContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (prefixIcon != null) ...[
                Icon(prefixIcon, size: iconSize, color: iconColor),
                10.wGap,
              ],
              Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      title,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isReview)
                      IconButton(
                        tooltip: "Performance Review",
                        icon: Icon(CupertinoIcons.info, color: Colors.yellow),
                        onPressed: onTap ?? () {},
                      ),
                  ],
                ),
              ),
            ],
          ),
          Text(subtitle ?? '', style: AppTexts.subTitle),
          if (subtitle != null) 10.hGap,
          ...cards,
        ],
      ),
    );
  }
}
