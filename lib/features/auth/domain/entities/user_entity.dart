import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final int age;
  final DateTime birthDate;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.age,
    required this.birthDate,
  });

  @override
  List<Object?> get props => [id, email, name, age, birthDate];
}