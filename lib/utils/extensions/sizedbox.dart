import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

extension Spacing on num {
  SizedBox get hGap => SizedBox(height: toDouble().h);
  SizedBox get wGap => SizedBox(width: toDouble().w);
}
