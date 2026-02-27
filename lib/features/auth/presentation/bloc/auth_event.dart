part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}
// Verificar si hay una sesión activa al arrancar
class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthLoginRequested({required this.email, required this.password});
}


class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final int age;
  final DateTime birthDate;

  const AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.name,
    required this.age,
    required this.birthDate,
  });
}

class AuthLogoutRequested extends AuthEvent {}

