import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';


class MockSignUpUseCase extends Mock implements SignUpUseCase {}

void main() {
  late AuthBloc authBloc;
  late MockSignUpUseCase mockSignUpUseCase;

  setUp(() {
    mockSignUpUseCase = MockSignUpUseCase();
    authBloc = AuthBloc(signUpUseCase: mockSignUpUseCase);
  });

  blocTest<AuthBloc, AuthState>(
    'debe emitir [loading, authenticated] cuando el registro es exitoso',
    build: () {
      when(() => mockSignUpUseCase(any())).thenAnswer(
            (_) async => Right(UserEntity(id: '1', email: 'test@aion.com', name: 'Jorge', age: 30, birthDate: DateTime.now())),
      );
      return authBloc;
    },
    act: (bloc) => bloc.add(const AuthSignUpRequested(
        email: 'test@aion.com', password: 'password', name: 'Jorge', age: 30, birthDate: DateTime.now()
    )),
    expect: () => [
      const AuthState(status: AuthStatus.loading),
      isA<AuthState>().having((s) => s.status, 'status', AuthStatus.authenticated),
    ],
  );
}