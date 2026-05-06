import 'package:postgrest/postgrest.dart';
import 'package:gpsc_prep_app/core/errors/db_error_parser.dart';
import 'package:gpsc_prep_app/core/helpers/log_helper.dart';

/// Wraps any Supabase RPC call.
/// - On success: returns the result.
/// - On PostgrestException: logs the raw error for dev, calls onError
///   with a clean user message, returns null.
Future<T?> callRpc<T>({
  required Future<T> Function() call,
  required void Function(String userMessage) onError,
}) async {
  try {
    return await call();
  } on PostgrestException catch (e) {
    final parsed = DbErrorParser.parse(e);
    LogHelper().e('RPC error: ${parsed.devSnippet}');
    onError(parsed.userMessage);
    return null;
  }
}
