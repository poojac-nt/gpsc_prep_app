import 'package:bloc/bloc.dart';
import 'package:gpsc_prep_app/core/cache_manager.dart';
import 'package:gpsc_prep_app/data/models/payloads/user_payload.dart';
import 'package:gpsc_prep_app/data/repositories/authentiction_repository.dart';
import 'package:gpsc_prep_app/domain/entities/user_model.dart';
import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final CacheManager _cache;

  AuthBloc(this.authRepository, this._cache) : super(AuthInitial()) {
    on<LoginRequested>(_login);
    on<LoadUserFromCache>(_loadUserFromCache);
    on<CreateUserRequested>(_createUser);
  }

  Future<void> _login(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await authRepository.login(event.email, event.password);

    result.fold((failure) => emit(AuthFailure(failure.message)), (user) {
      _cache.setUser(user);
      emit(AuthSuccess(user));
    });
  }

  Future<void> _loadUserFromCache(
    LoadUserFromCache event,
    Emitter<AuthState> emit,
  ) async {
    final user = await _cache.getInitUser();
    if (user != null) {
      emit(AuthSuccess(user));
    } else {
      emit(AuthFailure('No User Found in Cache Memory'));
    }
  }

  Future<void> _updateUserProfile(
    UpdateUserProfile event,
    Emitter<AuthState> emit,
  ) async {
    _cache.setUser(event.updateUser);

    /// update method from repository
    emit(AuthSuccess(event.updateUser));
  }

  Future<void> _createUser(
    CreateUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthCreating());

    final result = await authRepository.createUser(event.userPayload);

    result.fold((failure) => emit(AuthCreateFailure(failure.message)), (user) {
      _cache.setUser(user);
      emit(AuthCreated(user));
    });
  }
}
