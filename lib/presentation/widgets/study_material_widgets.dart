import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/router/args.dart';
import 'package:gpsc_prep_app/domain/entities/study_material_model.dart';
import 'package:gpsc_prep_app/presentation/blocs/download%20pdf/download_pdf_bloc.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:gpsc_prep_app/utils/services/test_link_generator.dart';
import 'package:share_plus/share_plus.dart';

class MaterialCard extends StatelessWidget {
  final StudyMaterialModel item;
  final int index;
  final bool isHighlighted;

  const MaterialCard({
    super.key,
    required this.item,
    required this.index,
    required this.isHighlighted,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOutCubic,
      margin: EdgeInsets.only(bottom: 16.sp),
      padding: isHighlighted ? EdgeInsets.all(8.sp) : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isHighlighted ? 16.sp : 10.sp),
        gradient:
            isHighlighted
                ? LinearGradient(
                  colors: [
                    const Color(0xFF3B82F6).withAlpha(150),
                    const Color(0xFF3B82F6).withAlpha(80),
                    const Color(0xFF3B82F6).withAlpha(50),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.5, 1.0],
                )
                : null,
        border:
            isHighlighted
                ? Border.all(color: const Color(0xFF3B82F6).withAlpha(40))
                : null,
        boxShadow: [
          BoxShadow(
            color:
                isHighlighted
                    ? const Color(0xFF3B82F6).withAlpha(30)
                    : Colors.black.withValues(alpha: 0.04),
            blurRadius: isHighlighted ? 12 : 10,
            offset: Offset(0, isHighlighted ? 4 : 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isHighlighted ? 16.sp : 10.sp),
        child: Stack(
          children: [
            Positioned(
              top: -50.sp,
              right: -50.sp,
              child: Container(
                width: 150.w,
                height: 150.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      color.withValues(alpha: 0.08),
                      color.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(20.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Subject Icon
                      Container(
                        padding: EdgeInsets.all(12.sp),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color, color.withValues(alpha: 0.8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.3),
                              blurRadius: 8.r,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.description_outlined,
                          color: Colors.white,
                          size: 24.sp,
                        ),
                      ),
                      16.wGap,

                      // Title
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                            height: 1.3,
                          ),
                        ),
                      ),
                      10.wGap,

                      // Download Button
                      IconActionButton(
                        icon: Icons.download_rounded,
                        color: color,
                        onPressed: () async {
                          context.read<DownLoadPdfBloc>().add(
                            DownloadStudyMaterial(
                              url: item.link,
                              filename: "${item.title.trim()}.pdf",
                            ),
                          );
                        },
                      ),
                      12.wGap,

                      // Share Button
                      IconActionButton(
                        icon: Icons.share_rounded,
                        color: color,
                        onPressed: () {
                          _handleShare(context, item);
                        },
                      ),
                    ],
                  ),

                  // Start Test Button
                  if (item.testId != null) ...[
                    16.hGap,
                    StudyMaterialActionButton(
                      icon: Icons.play_circle_fill,
                      label: 'Start Test',
                      isPrimary: true,
                      color: color,
                      onPressed: () {
                        context.push(
                          AppRoutes.mcqTestInstructionScreen,
                          extra: TestInstructionScreenArgs(testId: item.testId),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatDateFromString(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return "";
    }
  }
}

class StudyMaterialActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final Color color;
  final VoidCallback onPressed;

  const StudyMaterialActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.isPrimary,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary ? color : color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.sp),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18.sp, color: isPrimary ? Colors.white : color),
              8.wGap,
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: isPrimary ? Colors.white : color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class IconActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const IconActionButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(12.sp),
          child: Icon(icon, size: 20.sp, color: color),
        ),
      ),
    );
  }
}

Future<void> _handleShare(
  BuildContext context,
  StudyMaterialModel model,
) async {
  try {
    final shareableUrl = DeepLinkGenerator.generateStudyMaterialLink(
      languageCode: model.language,
      studyMaterialId: model.id,
    );

    final uri = Uri.parse(shareableUrl);
    await SharePlus.instance.share(
      ShareParams(
        text: "Check out this ${model.title} Study Material 🚀\n$uri",
        subject: 'GPSC Prep Test Share',
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error sharing test: ${e.toString()}')),
    );
  }
}
