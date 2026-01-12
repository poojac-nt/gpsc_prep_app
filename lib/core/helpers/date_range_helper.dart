import 'package:gpsc_prep_app/utils/enums/date_range_enum.dart';

class AnalyticsDateRange {
  final DateTime? from;
  final DateTime? to;

  const AnalyticsDateRange({this.from, this.to});
}

class AnalyticsDateRangeHelper {
  static AnalyticsDateRange calculate(AnalyticsRange range) {
    final nowUtc = DateTime.now().toUtc();

    // End = yesterday 23:59:59 UTC
    final end = DateTime.utc(
      nowUtc.year,
      nowUtc.month,
      nowUtc.day,
    ).subtract(const Duration(seconds: 1));

    switch (range) {
      case AnalyticsRange.weekly:
        return AnalyticsDateRange(
          from: end.subtract(const Duration(days: 7)),
          to: end,
        );

      case AnalyticsRange.monthly:
        return AnalyticsDateRange(
          from: end.subtract(const Duration(days: 30)),
          to: end,
        );

      case AnalyticsRange.lifetime:
        return const AnalyticsDateRange();
    }
  }
}
