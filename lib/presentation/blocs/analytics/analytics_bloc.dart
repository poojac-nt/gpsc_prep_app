import 'package:bloc/bloc.dart';
import 'package:gpsc_prep_app/core/error/failure.dart';
import 'package:gpsc_prep_app/data/repositories/analytics_repository.dart';
import 'package:gpsc_prep_app/domain/entities/overall_analytics_model.dart';
import 'package:meta/meta.dart';

part 'analytics_event.dart';
part 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final AnalyticsRepository _analyticsRepository;

  AnalyticsBloc(this._analyticsRepository) : super(AnalyticsInitial()) {
    on<FetchAnalyticsEvent>(_loadAnalytics);
  }

  Future<void> _loadAnalytics(
    FetchAnalyticsEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(AnalyticsLoading());

    final data = await _analyticsRepository.fetchOverAllAnalytics();
    data.fold(
      (failure) {
        emit(AnalyticsError(failure));
      },
      (analyticsData) {
        emit(AnalyticsLoaded(analyticsData));
      },
    );
  }
}
