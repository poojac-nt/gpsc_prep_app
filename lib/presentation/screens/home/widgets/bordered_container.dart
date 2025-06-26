import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/presentation/screens/home/widgets/stats_widget.dart';
import 'package:gpsc_prep_app/utils/extensions/sizedbox.dart';

class BorderedContainer extends StatelessWidget {
  const BorderedContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: child,
    );
  }
}
