import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/router/args.dart';
import 'package:gpsc_prep_app/domain/entities/study_material_model.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:gpsc_prep_app/utils/helper_methods/pdf_download_from_link.dart';
import 'package:share_plus/share_plus.dart';

import '../../../blocs/study_material/study_material_bloc.dart';
import '../../../blocs/study_material/study_material_state.dart';

class StudyMaterialListScreen extends StatelessWidget {
  final String selectedLanguage;

  const StudyMaterialListScreen({super.key, required this.selectedLanguage});

  @override
  Widget build(BuildContext context) {
    debugPrint(selectedLanguage);
    List<StudyMaterialModel> materials = [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "Study Materials",
          style: TextStyle(
            color: const Color(0xFF1E293B),
            fontWeight: FontWeight.w700,
            fontSize: 20.sp,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      body: BlocBuilder<StudyMaterialBloc, StudyMaterialState>(
        builder: (context, state) {
          if (state is StudyMaterialLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is StudyMaterialLoaded) {
            materials =
                state.materials
                    .where((element) => element.language == selectedLanguage)
                    .toList();
            if (materials.isEmpty || materials == []) {
              return Center(
                child: Text(
                  'No Materials Found for ${selectedLanguage == "gj" ? "Gujarati" : "English"} language.',
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(20.sp),
              itemCount: materials.length,
              itemBuilder: (context, index) {
                final item = materials[index];
                return _MaterialCard(item: item, index: index);
              },
            );
          }
          if (state is StudyMaterialError) {
            return const Center(child: Text('Something went wrong'));
          }
          return SizedBox.shrink();
        },
      ),
    );
  }
}

class _MaterialCard extends StatelessWidget {
  final StudyMaterialModel item;
  final int index;

  const _MaterialCard({required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.primary;

    return Container(
      margin: EdgeInsets.only(bottom: 16.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
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
                      // Subject Color Indicator
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
                      // Title and Subject
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
                      _IconActionButton(
                        icon: Icons.download_rounded,
                        color: color,
                        onPressed: () async {
                          DocumentDownloader downloader = DocumentDownloader();

                          // With progress tracking
                          await downloader.downloadDocument(
                            url:
                                'https://docs.google.com/document/d/188iDSc_oNWvgcissp2Q3l1oDqaafufweXRSqCLh6_sM/edit?usp=sharing',
                            fileName: item.title,
                            onProgress: (progress) {
                              debugPrint(
                                'Progress: ${(progress * 100).toStringAsFixed(0)}%',
                              );
                            },
                          );
                        },
                      ),
                      12.wGap,
                      _IconActionButton(
                        icon: Icons.share_rounded,
                        color: color,
                        onPressed: () {
                          SharePlus.instance.share(
                            ShareParams(
                              text:
                                  'Check out this study material: ${item.link}',
                              subject: item.title,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  if (item.testId != null) ...[
                    16.hGap,
                    _ActionButton(
                      icon: Icons.play_circle_fill,
                      label: 'Start Test',
                      isPrimary: true,
                      color: item.testId == null ? Colors.grey : color,
                      onPressed:
                          item.testId == null
                              ? () {}
                              : () {
                                context.push(
                                  AppRoutes.mcqTestInstructionScreen,
                                  extra: TestInstructionScreenArgs(
                                    testId: item.testId,
                                  ),
                                );
                              },
                    ),
                    12.wGap,
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
      // Convert string to DateTime (automatically handles +00 timezone)
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
    } catch (e) {
      return ""; // prevent crash if invalid format
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
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

class _IconActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _IconActionButton({
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
