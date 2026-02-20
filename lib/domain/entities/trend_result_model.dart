import 'package:gpsc_prep_app/domain/entities/trend_model.dart';

class TrendResultModel {
  final List<TrendModel> weekly;
  final List<TrendModel> monthly;

  TrendResultModel({required this.weekly, required this.monthly});

  factory TrendResultModel.fromRpcResponse(List<dynamic> response) {
    final allStats = response.map((e) => TrendModel.fromJson(e)).toList();

    return TrendResultModel(
      weekly: allStats.where((e) => e.periodType == PeriodType.weekly).toList(),
      monthly:
          allStats.where((e) => e.periodType == PeriodType.monthly).toList(),
    );
  }
}
