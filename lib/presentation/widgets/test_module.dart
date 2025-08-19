import 'package:flutter/material.dart';
import 'package:gpsc_prep_app/icons/icons.dart';
import 'package:gpsc_prep_app/presentation/widgets/elevated_container.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:gpsc_prep_app/utils/services/test_link_generator.dart';
import 'package:share_plus/share_plus.dart';

class TestModule extends StatelessWidget {
  const TestModule({
    super.key,
    required this.title,
    this.subtitle,
    this.testId,
    this.iconSize = 24,
    this.fontSize = 24,
    this.showShareButton = false,
    this.iconColor = Colors.black,
    this.prefixIcon,
    this.cards = const <Widget>[],
  });

  final String title;
  final String? subtitle;
  final int? testId;
  final double? iconSize;
  final double? fontSize;
  final Color? iconColor;
  final bool showShareButton;
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
                    icon: const Icon(AppIcons.share_test),
                    onPressed: () {
                      _handleShare(context);
                    },
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

  Future<void> _handleShare(BuildContext context) async {
    if (testId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot share this test at the moment')),
      );
      return;
    }

    try {
      final shareableUrl = DeepLinkGenerator.generateShareableUrl(
        testId: testId!,
      );

      final uri = Uri.parse(shareableUrl);
      await SharePlus.instance.share(
        ShareParams(uri: uri, subject: 'GPSC Prep Test Share'),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing test: ${e.toString()}')),
      );
    }
  }
}
