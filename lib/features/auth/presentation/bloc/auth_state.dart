part of 'auth_bloc.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  // Factory para el estado inicial
  factory AuthState.initial() => const AuthState();

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];

  // Métodos para HydratedBloc
  Map<String, dynamic> toMap() {
    return {
      'status': status.name,
      'user': user != null ? {
        'id': user!.id,
        'email': user!.email,
        'name': user!.name,
      } : null,
    };
  }

  factory AuthState.fromMap(Map<String, dynamic> map) {
    return AuthState(
      status: AuthStatus.values.byName(map['status']),
      user: map['user'] != null ? UserEntity(
        id: map['user']['id'],
        email: map['user']['email'],
        name: map['user']['name'],
        age: 0,
        birthDate: DateTime.now(),
      ) : null,
    );
  }
}