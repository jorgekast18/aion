import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_use_case.dart';
import '../../domain/usecases/signup_use_case.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends HydratedBloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final SignUpUseCase _signUpUseCase;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required SignUpUseCase signUpUseCase,
  }) : _loginUseCase = loginUseCase,
        _signUpUseCase = signUpUseCase,
        super(AuthState.initial()) {

    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onAuthCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: UserEntity(id: user.uid, email: user.email!, name: user.displayName ?? '', age: 0, birthDate: DateTime.now())
      ));
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onLoginRequested(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await _loginUseCase(LoginParams(email: event.email, password: event.password));

    result.fold(
          (failure) => emit(state.copyWith(status: AuthStatus.error, errorMessage: failure.message)),
          (user) => emit(state.copyWith(status: AuthStatus.authenticated, user: user)),
    );
  }

  Future<void> _onSignUpRequested(AuthSignUpRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await _signUpUseCase(SignUpParams(
        email: event.email,
        password: event.password,
        name: event.name,
        age: event.age,
        birthDate: event.birthDate
    ));

    result.fold(
          (failure) => emit(state.copyWith(status: AuthStatus.error, errorMessage: failure.message)),
          (user) => emit(state.copyWith(status: AuthStatus.authenticated, user: user)),
    );
  }

  Future<void> _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await FirebaseAuth.instance.signOut();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  @override
  AuthState? fromJson(Map<String, dynamic> json) => AuthState.fromMap(json);

  @override
  Map<String, dynamic>? toJson(AuthState state) => state.toMap();
}