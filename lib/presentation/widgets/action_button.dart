import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    this.text,
    this.onTap,
    this.backgroundColor = const Color(0xff3b82f6),
    this.isLoading = false,
    this.fontColor = Colors.white,
    this.padding = const EdgeInsets.all(10),
    this.icon,
    this.suffixIcon,
    this.width,
    this.height,
    this.gradient,
    this.borderRadius,
    this.border,
  });

  final String? text;
  final VoidCallback? onTap;
  final Color fontColor;
  final Color backgroundColor;
  final bool isLoading;
  final EdgeInsets padding;
  final IconData? icon;
  final IconData? suffixIcon;
  final double? width;
  final double? height;
  final Gradient? gradient;
  final BorderRadius? borderRadius;
  final Border? border;

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? AppBorders.borderRadius;

    return Skeleton.shade(
      child: Container(
        width: width ?? double.infinity,
        height: height ?? 45.h,
        decoration: BoxDecoration(
          color:
              gradient == null
                  ? (isLoading ? Colors.grey : backgroundColor)
                  : null,
          gradient: isLoading ? null : gradient,
          borderRadius: effectiveBorderRadius,
          border: border,
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: padding,
            shape: RoundedRectangleBorder(borderRadius: effectiveBorderRadius),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: width == null ? MainAxisSize.max : MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: fontColor, size: 18.sp),
                if (text != null) 8.wGap,
              ],
              if (text != null)
                Flexible(
                  child: Text(
                    text!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: fontColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              if (suffixIcon != null) ...[
                if (text != null || icon != null) 8.wGap,
                Icon(suffixIcon, color: fontColor, size: 18.sp),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
