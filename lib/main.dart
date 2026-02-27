import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/injection/injection_container.dart' as di;
import 'core/router/app_router.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'firebase_options.dart';


void main() async {


  // 1. Siempre primero los bindings y las variables de entorno
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // 2. Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. CRÍTICO: Inicializar el Storage ANTES que la inyección de dependencias
  // Si di.init() o cualquier llamada posterior intenta instanciar un Bloc,
  // el storage ya debe estar asignado.
  final directory = await getApplicationDocumentsDirectory();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(directory.path),
  );

  // 4. inicializamos GetIt
  await di.init();

  // 5. Verificamos sesión
  //di.sl<AuthBloc>().add(AuthCheckRequested());

  runApp(const AionApp());
}

class AionApp extends StatelessWidget {
  const AionApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenemos el authBloc una sola vez
    final authBloc = di.sl<AuthBloc>();

    return BlocProvider.value(
      value: authBloc..add(AuthCheckRequested()), // Disparamos el check aquí
      child: MaterialApp.router(
        title: 'AION AI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
            surface: const Color(0xFF0D0D17),
            background: const Color(0xFF07070C),
          ),
          appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF12121F), elevation: 0),
        ),
        // Pasamos el Bloc al router para la lógica de redirección
        routerConfig: AppRouter(authBloc).router,
      ),
    );
  }
}