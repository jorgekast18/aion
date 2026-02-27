import 'package:get_it/get_it.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:aion/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:aion/features/chat/domain/repositories/chat_repository.dart';
import 'package:aion/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:aion/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aion/features/auth/domain/repositories/auth_repository.dart';
import 'package:aion/features/auth/domain/usecases/signup_use_case.dart';
import 'package:aion/features/auth/domain/usecases/login_use_case.dart';
import 'package:aion/features/auth/presentation/bloc/auth_bloc.dart';
import '../constants/firebase_constants.dart';

final sl = GetIt.instance; // sl = Service Locator

Future<void> init() async {
  //! Features - IA
  sl.registerLazySingleton(() => GenerativeModel(
    model: 'gemini-3-flash-preview',
    apiKey: dotenv.get('GEMINI_API_KEY'),
    systemInstruction: Content.system(
        "Eres AION, un asistente avanzado. La fecha actual es ${DateFormat('EEEE, d MMMM yyyy').format(DateTime.now())}. "
        "Responde siempre con información actualizada basada en este contexto temporal."
    ),
    generationConfig: GenerationConfig(
      temperature: 0.7,
      topP: 0.95,
      topK: 40,
    ),
  ));

  // Chat Feature
  sl.registerFactoryParam<ChatBloc, String, void>(
      (userId, _) => ChatBloc(repository: sl(), userId: userId),
  );

  sl.registerLazySingleton<ChatRepository>(
        () => ChatRepositoryImpl(sl(), sl()),
  );

  //! Features - Auth
  // Bloc
  sl.registerFactory(() => AuthBloc(
    signUpUseCase: sl(),
    loginUseCase: sl()
  ));

  // Use cases
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => LoginUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(sl(), sl()),
  );

  //! External
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: FirebaseConstants.firestoreDatabaseId,
  ));
}