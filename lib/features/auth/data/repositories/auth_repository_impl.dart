import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl(this._firebaseAuth, this._firestore);

  @override
  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
    required String name,
    required int age,
    required DateTime birthDate,
  }) async {
    try {
      final credential = await _firebaseAuth
        .createUserWithEmailAndPassword(
            email: email,
            password: password,
        )
        .timeout(const Duration(seconds: 10));

      final userModel = UserModel(
        id: credential.user!.uid,
        email: email,
        name: name,
        age: age,
        birthDate: birthDate,
      );

      await _firestore
          .collection('users')
          .doc(userModel.id)
          .set(userModel.toMap())
          .timeout(const Duration(seconds: 10));

      return Right(userModel);
    } on FirebaseAuthException catch (e) {
      return Left(ServerFailure(_mapError(e.code)));
    } on TimeoutException {
      return Left(ServerFailure("La operación tardó demasiado"));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }


  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Intentar login en Firebase Auth
      final credential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password)
          .timeout(const Duration(seconds: 10));

      final String uid = credential.user!.uid;

      // 2. Traer los datos extra desde Firestore (la base de datos 'aion')
      final userDoc = await _firestore
          .collection('users')
          .doc(uid)
          .get()
          .timeout(const Duration(seconds: 10));

      if (!userDoc.exists) {
        return const Left(ServerFailure('No se encontró el perfil del usuario en la base de datos.'));
      }

      // 3. Convertir el mapa de Firestore a nuestro modelo
      final userModel = UserModel.fromMap(userDoc.data()!, uid);

      return Right(userModel);

    } on FirebaseAuthException catch (e) {
      // Manejo de errores específicos de login
      return Left(ServerFailure(_handleLoginError(e.code)));
    } on FirebaseException catch (e) {
      return Left(ServerFailure("Error de base de datos: ${e.message}"));
    } catch (e) {
      return Left(ServerFailure("Ocurrió un error inesperado: $e"));
    }
  }

// Función auxiliar para mapear errores de Login (Nivel Senior)
  String _handleLoginError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No existe una cuenta con este correo.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'invalid-credential':
        return 'Credenciales inválidas. Revisa tus datos.';
      case 'user-disabled':
        return 'Esta cuenta ha sido inhabilitada.';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde.';
      default:
        return 'Fallo al iniciar sesión ($code)';
    }
  }

  @override
  Future<Either<Failure, void>> logout() async => Right(await _firebaseAuth.signOut());

  @override
  Stream<UserEntity?> get currentUser => _firebaseAuth.authStateChanges().map((user) {

    return user == null
        ? null
        : UserEntity(id: user.uid, email: user.email!, name: '', age: 0, birthDate: DateTime.now());
  });

  String _mapError(String code){
    print(code);
    switch(code){
      case 'email-already-in-use': return 'El email ya está en uso.';
      case 'invalid-email': return 'El formato del correo es incorrecto.';
      case 'weak-password': return 'La contraseña es muy débil.';
      default: return 'Fallo en el registro ($code)';
    }
  }
}