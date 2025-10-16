import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/router/args.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:gpsc_prep_app/utils/helper_methods/pdf_download_from_link.dart';
import 'package:share_plus/share_plus.dart';

class StudyMaterialListScreen extends StatelessWidget {
  final String selectedLanguage;

  const StudyMaterialListScreen({super.key, required this.selectedLanguage});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> materials = [
      {
        'title': 'Indian History Notes',
        'link': 'https://example.com/history.pdf',
        'date': DateTime(2025, 10, 10),
        'subject': 'History',
        'pages': 45,
      },
      {
        'title': 'Geography Study Material',
        'link': 'https://example.com/geography.pdf',
        'date': DateTime(2025, 9, 25),
        'subject': 'Geography',
        'pages': 38,
      },
      {
        'title': 'General Science',
        'link': 'https://example.com/science.pdf',
        'date': DateTime(2025, 9, 15),
        'subject': 'Science',
        'pages': 52,
      },
      {
        'title': 'Indian History Notes',
        'link': 'https://example.com/history.pdf',
        'date': DateTime(2025, 10, 10),
        'subject': 'History',
        'pages': 45,
      },
      {
        'title': 'Geography Study Material',
        'link': 'https://example.com/geography.pdf',
        'date': DateTime(2025, 9, 25),
        'subject': 'Geography',
        'pages': 38,
      },
      {
        'title': 'General Science',
        'link': 'https://example.com/science.pdf',
        'date': DateTime(2025, 9, 15),
        'subject': 'Science',
        'pages': 52,
      },
      {
        'title': 'Indian History Notes',
        'link': 'https://example.com/history.pdf',
        'date': DateTime(2025, 10, 10),
        'subject': 'History',
        'pages': 45,
      },
      {
        'title': 'Geography Study Material',
        'link': 'https://example.com/geography.pdf',
        'date': DateTime(2025, 9, 25),
        'subject': 'Geography',
        'pages': 38,
      },
      {
        'title': 'General Science',
        'link': 'https://example.com/science.pdf',
        'date': DateTime(2025, 9, 15),
        'subject': 'Science',
        'pages': 52,
      },
    ];

    materials.sort((a, b) => b['date'].compareTo(a['date'])); // latest first

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "$selectedLanguage Study Materials",
          style: TextStyle(
            color: const Color(0xFF1E293B),
            fontWeight: FontWeight.w700,
            fontSize: 20.sp,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Materials List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(20.sp),
              itemCount: materials.length,
              itemBuilder: (context, index) {
                final item = materials[index];
                return _MaterialCard(item: item, index: index);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MaterialCard extends StatelessWidget {
  final Map<String, dynamic> item;
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
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Decorative gradient background
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [color.withOpacity(0.08), color.withOpacity(0.0)],
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
                            colors: [color, color.withOpacity(0.8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.3),
                              blurRadius: 8,
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'],
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1E293B),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  16.hGap,

                  // Metadata R
                  _InfoChip(
                    icon: Icons.calendar_today_outlined,
                    label: _formatDate(item['date']),
                    color: const Color(0xFF64748B),
                  ),
                  16.hGap,
                  // Action Buttons
                  Row(
                    children: [
                      // Start Test Button (Primary)
                      Expanded(
                        flex: 2,
                        child: _ActionButton(
                          icon: Icons.play_circle_fill,
                          label: 'Start Test',
                          isPrimary: true,
                          color: color,
                          onPressed: () {
                            context.push(
                              AppRoutes.mcqTestInstructionScreen,
                              extra: TestInstructionScreenArgs(testId: 147),
                            );
                          },
                        ),
                      ),
                      12.wGap,
                      // Secondary Actions
                      _IconActionButton(
                        icon: Icons.download_rounded,
                        color: color,
                        onPressed: () async {
                          DocumentDownloader downloader = DocumentDownloader();

                          // With progress tracking
                          await downloader.downloadDocument(
                            url:
                                'https://docs.google.com/document/d/188iDSc_oNWvgcissp2Q3l1oDqaafufweXRSqCLh6_sM/edit?usp=sharing',
                            fileName: item['title'],
                            onProgress: (progress) {
                              debugPrint(
                                'Progress: ${(progress * 100).toStringAsFixed(0)}%',
                              );
                            },
                          );
                        },
                      ),
                      8.wGap,
                      _IconActionButton(
                        icon: Icons.share_rounded,
                        color: color,
                        onPressed: () {
                          SharePlus.instance.share(
                            ShareParams(
                              text:
                                  'Check out this study material: ${item['link']}',
                              subject: item['title'],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
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
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.sp, color: color),
        4.wGap,
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
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
      color: isPrimary ? color : color.withOpacity(0.1),
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
      color: color.withOpacity(0.1),
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
