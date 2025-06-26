import 'package:bloc/bloc.dart';
import 'package:gpsc_prep_app/core/helpers/supabase_helper.dart';
import 'package:gpsc_prep_app/domain/entities/user_model.dart';
import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SupabaseHelper helper;

  AuthBloc(this.helper) : super(AuthInitial()) {
    on<LoginRequested>(_Login);
  }

  Future<void> _Login(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await helper.login(event.email, event.password);

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }
}
