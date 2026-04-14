import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/domain/entities/course_model.dart';
import 'package:gpsc_prep_app/utils/services/test_link_generator.dart';
import 'package:share_plus/share_plus.dart';

class ShareHelper {
  static Future<void> shareCourse(CourseModel course) async {
    try {
      final shareableUrl = DeepLinkGenerator.generateCourseLink(
        courseId: course.id,
      );
      final uri = Uri.parse(shareableUrl);
      await SharePlus.instance.share(
        ShareParams(
          text: "Check out this ${course.name} Course! 🚀\n$uri",
          subject: 'GPSC Prep Course Share',
        ),
      );
    } catch (e) {
      getIt<SnackBarHelper>().showError(
        'Error sharing course: ${e.toString()}',
      );
    }
  }
}
