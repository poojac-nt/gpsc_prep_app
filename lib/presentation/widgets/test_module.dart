import 'package:flutter/material.dart';
import 'package:gpsc_prep_app/presentation/widgets/elevated_container.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

class TestModule extends StatelessWidget {
  const TestModule({
    super.key,
    required this.title,
    this.subtitle,
    this.iconSize = 24,
    this.fontSize = 24,
    this.showShareButton = false,
    this.onShare,
    this.iconColor = Colors.black,
    this.prefixIcon,
    this.cards = const <Widget>[],
  });

  final String title;
  final String? subtitle;
  final double? iconSize;
  final double? fontSize;
  final Color? iconColor;
  final bool showShareButton;
  final VoidCallback? onShare;
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
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              showShareButton
                  ? IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: onShare,
                  )
                  : SizedBox.shrink(),
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
