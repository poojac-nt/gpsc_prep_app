import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languages = [
      {'name': 'English', 'code': 'en'},
      {'name': 'Gujarati', 'code': 'gj'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Language', style: AppTexts.titleTextStyle),
      ),
      body: Column(
        children: [
          // Grid Section
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${languages.length} Languages Available',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  20.hGap,
                  Expanded(
                    child: GridView.builder(
                      itemCount: languages.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.w,
                        mainAxisSpacing: 16.h,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        final lang = languages[index];
                        return _LanguageCard(
                          language: lang,
                          index: index,
                          onTap: () {
                            final langData = {
                              'name': lang['name'] as String,
                              'code': lang['code'] as String,
                            };
                            context.push(
                              AppRoutes.studyMaterial,
                              extra: langData,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageCard extends StatefulWidget {
  final Map<String, dynamic> language;
  final int index;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.language,
    required this.index,
    required this.onTap,
  });

  @override
  State<_LanguageCard> createState() => _LanguageCardState();
}

class _LanguageCardState extends State<_LanguageCard> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.primary;

    return GestureDetector(
      onTapDown: (_) => setState(() => isPressed = true),
      onTapUp: (_) {
        setState(() => isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(isPressed ? 0.97 : 1.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: color.withOpacity(0.2), width: 2.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10.r,
              offset: Offset(0, 2.h),
            ),
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 20.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              12.hGap,
              Text(
                widget.language['name'],
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
