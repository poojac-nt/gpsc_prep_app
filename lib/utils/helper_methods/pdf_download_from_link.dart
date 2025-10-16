import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DocumentDownloader {
  final Dio _dio = Dio();

  /// Downloads a document from the given URL to the Downloads folder
  ///
  /// [url] - The download link of the document
  /// [fileName] - Optional custom file name (if not provided, extracts from URL)
  /// [onProgress] - Optional callback to track download progress (0.0 to 1.0)
  ///
  /// Returns the path where the file was saved
  Future<String> downloadDocument({
    required String url,
    String? fileName,
    Function(double progress)? onProgress,
  }) async {
    try {
      // Request storage permission
      bool hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        throw Exception('Storage permission denied');
      }

      // Get the Downloads directory
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        // Fallback if the directory doesn't exist
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('Could not get download directory');
      }

      // Extract file name from URL if not provided
      fileName ??= _extractFileName(url);

      // Full file path
      String filePath = '${directory.path}/$fileName';

      // Download the file
      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            double progress = received / total;
            onProgress(progress);
          }
        },
      );

      if (kDebugMode) {
        print('File downloaded successfully to: $filePath');
      }
      OpenFilex.open(filePath);
      return filePath;
    } catch (e) {
      if (kDebugMode) {
        print('Error downloading file: $e');
      }
      rethrow;
    }
  }

  /// Request storage permission for Android
  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      // For Android 13+ (API 33+)
      if (await Permission.photos.isGranted ||
          await Permission.videos.isGranted ||
          await Permission.audio.isGranted) {
        return true;
      }

      // For Android 10-12
      if (await Permission.storage.isGranted) {
        return true;
      }

      // Request permission
      Map<Permission, PermissionStatus> statuses =
          await [Permission.storage].request();

      return statuses[Permission.storage]?.isGranted ?? false;
    }

    // iOS doesn't require explicit permission for app documents directory
    return true;
  }

  /// Extract file name from URL
  String _extractFileName(String url) {
    Uri uri = Uri.parse(url);
    String fileName = uri.pathSegments.last;

    // If filename doesn't have an extension, add a default one
    if (!fileName.contains('.')) {
      fileName = '$fileName.pdf';
    }
    return fileName;
  }

  /// Download with custom file name and progress tracking
  Future<String> downloadWithProgress({
    required String url,
    required String fileName,
    required Function(double) onProgress,
  }) async {
    return downloadDocument(
      url: url,
      fileName: fileName,
      onProgress: onProgress,
    );
  }
}
