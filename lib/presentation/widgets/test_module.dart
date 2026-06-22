import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/domain/entities/desc_test_model.dart';
import 'package:gpsc_prep_app/domain/entities/test_model.dart';
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
    this.testModel,
    this.descTestModel,
    this.iconSize = 24,
    this.fontSize = 24,
    this.showShareButton = false,
    this.iconColor = Colors.black,
    this.prefixIcon,
    this.cards = const <Widget>[],
    this.testType = TestType.mcq,
    this.trailing,
    this.header,
    this.onShareTap,
  });

  final String title;
  final String? subtitle;
  final TestModel? testModel;
  final DescTestModel? descTestModel;
  final double? iconSize;
  final double? fontSize;
  final Color? iconColor;
  final bool showShareButton;
  final IconData? prefixIcon;
  final List<Widget> cards;
  final TestType testType;
  final Widget? trailing;
  final Widget? header;
  final VoidCallback? onShareTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (header != null) ...[header!, showShareButton ? 0.hGap : 8.hGap],
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
              if (showShareButton)
                IconButton(
                  tooltip: "Share Test",
                  icon: Icon(
                    Icons.share_outlined,
                    size: 20.sp,
                    color: AppColors.primary,
                  ),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(),
                  onPressed:
                      onShareTap ??
                      () {
                        _handleShare(context, testType);
                      },
                ),
              if (trailing != null) trailing!,
            ],
          ),
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            Text(subtitle ?? '', style: AppTexts.subTitle),
            10.hGap,
          ],
          ...cards,
        ],
      ),
    );
  }

  Future<void> _handleShare(BuildContext context, TestType testType) async {
    try {
      final bool isDescriptiveType =
          testType == TestType.desc || testType == TestType.mains;

      final id = (isDescriptiveType && descTestModel != null)
          ? descTestModel!.id
          : testModel!.id;

      final name = (isDescriptiveType && descTestModel != null)
          ? descTestModel!.name
          : testModel!.name;

      final shareableUrl = DeepLinkGenerator.generateShareableUrl(
        testId: id,
        testType: testType,
      );

      final uri = Uri.parse(shareableUrl);
      await SharePlus.instance.share(
        ShareParams(
          text: "Check out this $name Test! 🚀\n$uri",
          subject: 'GPSC Prep Test Share',
        ),
      );
    } catch (e) {
      getIt<SnackBarHelper>().showError('Error sharing test: ${e.toString()}');
    }
  }
}
