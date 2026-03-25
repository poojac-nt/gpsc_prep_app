import 'package:intl/intl.dart';

extension TestTimeStringExtensions on String {
  /// Parses the DB timestamp and converts to local DateTime
  DateTime toLocalDateTime() {
    return DateTime.parse(this).toLocal();
  }

  /// Returns hours passed since the timestamp
  int hoursPassedSince() {
    return DateTime.now().difference(toLocalDateTime()).inHours;
  }

  /// Returns hours remaining until [cooldownHours] is reached
  int hoursRemaining(int cooldownHours) {
    final passed = hoursPassedSince();
    final remaining = cooldownHours - passed;
    return remaining > 0 ? remaining : 0;
  }

  /// Formats the timestamp to 'dd MMM, hh:mm a'
  String toFormattedDate() {
    try {
      final dateTime = toLocalDateTime();
      return DateFormat('dd MMM, hh:mm a').format(dateTime);
    } catch (e) {
      return this; // Return original string if parsing fails
    }
  }
}
