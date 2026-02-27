import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase implements UseCase<UserEntity, SignUpParams> {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignUpParams params) async {
    return await repository.signUp(
      email: params.email,
      password: params.password,
      name: params.name,
      age: params.age,
      birthDate: params.birthDate,
    );
  }
}

class SignUpParams extends Equatable {
  final String email;
  final String password;
  final String name;
  final int age;
  final DateTime birthDate;

  const SignUpParams({
    required this.email,
    required this.password,
    required this.name,
    required this.age,
    required this.birthDate,
  });

  @override
  List<Object> get props => [email, password, name, age, birthDate];
}