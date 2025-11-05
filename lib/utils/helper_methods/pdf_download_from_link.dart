import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/cupertino.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/error/failure.dart';
import 'package:gpsc_prep_app/core/helpers/log_helper.dart';
import 'package:http/http.dart' as http;
import 'package:media_store_plus/media_store_plus.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

Future<Either<Failure, String>> downloadAndOpenPdf({
  required String normalUrl,
  required String filename,
}) async {
  final log = getIt<LogHelper>();
  try {
    final url = normalizeDriveLink(normalUrl);
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      log.e('Failed to download PDF. Status code: ${response.statusCode}');
      throw Exception('Failed to download PDF.');
    }
    debugPrint(response.headers['content-type']);
    final pdfBytes = response.bodyBytes;

    if (Platform.isAndroid) {
      final sdkInt = (await DeviceInfoPlugin().androidInfo).version.sdkInt;

      if (sdkInt >= 29) {
        // ✅ Scoped Storage for Android 10+
        return Right(
          await _handleScopedStorageAndroid(pdfBytes, filename, log),
        );
      }
    }

    return Right(await _handleLegacyStorage(pdfBytes, filename, log));
  } catch (e) {
    getIt<LogHelper>().e('Error downloading/opening PDF: $e');
    return Left(Failure('Error downloading/opening PDF: $e'));
  }
}

Future<String> _handleScopedStorageAndroid(
  List<int> pdfBytes,
  String filename,
  LogHelper log,
) async {
  final tempDir = await getTemporaryDirectory();
  final tempFile = File('${tempDir.path}/$filename');
  await tempFile.writeAsBytes(pdfBytes);

  final mediaStore = MediaStore();
  MediaStore.appFolder = "StarICS";

  final saveInfo = await mediaStore.saveFile(
    tempFilePath: tempFile.path,
    dirName: DirName.download,
    dirType: DirType.download,
    relativePath: 'StarICS/',
  );

  if (saveInfo == null) throw Exception('Failed to save PDF to MediaStore');

  final uri = saveInfo.uri.path;
  log.i('Saved file URI: $uri');

  String? realPath;
  try {
    realPath = await mediaStore.getFilePathFromUri(uriString: uri);
    if (realPath != null) log.i('Resolved real path: $realPath');
  } catch (e) {
    log.e('Could not resolve path from URI: $e');
  }

  if (await tempFile.exists()) await tempFile.delete();

  final openPath = realPath ?? uri;
  final openResult = await OpenFilex.open(openPath);
  if (openResult.type != ResultType.done) {
    log.e('Failed to open PDF: ${openResult.message}');
    return 'Failed to open PDF: ${openResult.message}';
  }

  return openPath;
}

Future<String> _handleLegacyStorage(
  List<int> pdfBytes,
  String filename,
  LogHelper log,
) async {
  final dir = await getApplicationDocumentsDirectory();
  final filePath = '${dir.path}/$filename';
  final file = File(filePath);
  await file.writeAsBytes(pdfBytes);

  log.i('PDF saved locally: $filePath');

  final openResult = await OpenFilex.open(filePath);
  if (openResult.type != ResultType.done) {
    log.e('Failed to open PDF: ${openResult.message}');
    return 'Failed to open PDF: ${openResult.message}';
  }

  return filePath;
}

String normalizeDriveLink(String url) {
  if (url.contains('drive.google.com')) {
    final match = RegExp(r'(?:id=|file/d/)([a-zA-Z0-9_-]+)').firstMatch(url);
    if (match != null) {
      return 'https://drive.google.com/uc?export=download&id=${match.group(1)}';
    }
  }
  return url;
}
