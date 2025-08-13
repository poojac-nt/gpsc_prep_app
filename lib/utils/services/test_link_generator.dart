import 'package:share_plus/share_plus.dart';

class DeepLinkGenerator {
  static const String _baseUrl = 'https://starics.netlify.app';
  static const String _packageName = 'app.starics';
  static const String _playStoreUrl =
      'https://play.google.com/store/apps/details?id=$_packageName';

  /// Generate a shareable URL with just the test ID
  static String generateShareableUrl({required int testId}) {
    return '$_baseUrl/openTest?id=$testId';
  }

  /// Generate all variants of links for the test
  static Map<String, String> generateTestLinks({required int testId}) {
    final path =
        '/studentDashboard/mcqTestScreen/testInstructionScreen/$testId';

    final deepLink = '$_baseUrl$path';
    final intentLink =
        'intent://${Uri.parse(_baseUrl).host}$path#Intent;'
        'scheme=https;'
        'package=$_packageName;'
        'S.browser_fallback_url=${Uri.encodeComponent(_playStoreUrl)};'
        'end';

    return {
      'deepLink': deepLink,
      'intentLink': intentLink,
      'playStoreUrl': _playStoreUrl,
      'shareableUrl': generateShareableUrl(testId: testId),
    };
  }

  /// Share link using SharePlus
  static Future<void> shareTestLink({required int testId}) async {
    final shareableUrl = generateShareableUrl(testId: testId);
    final uri = Uri.parse(shareableUrl);
    await SharePlus.instance.share(
      ShareParams(
        uri: uri,
        text: 'Check out this test!',
        subject: 'GPSC Prep Test Share',
      ),
    );
  }
}
