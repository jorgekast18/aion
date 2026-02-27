// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'router_refresh_stream.dart';
import 'package:aion/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:aion/features/auth/presentation/pages/signup_page.dart';
import 'package:aion/features/chat/presentation/pages/chat_page.dart';
import 'package:aion/features/home/presentation/pages/main_layout.dart';
import 'package:aion/features/auth/presentation/pages/login_page.dart';
class AppRouter {
  final AuthBloc authBloc;

  AppRouter(this.authBloc);

  late final router = GoRouter(
    initialLocation: '/login',
    // ESTA ES LA CLAVE: El router escuchará los cambios del Bloc
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      final isAuth = authState.status == AuthStatus.authenticated;
      final bool isLoggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/signup';

      // 1. Si NO está autenticado y no está en signup, lo mandamos a signup
      if (!isAuth && !isLoggingIn) return '/login';

      // 2. Si ESTÁ autenticado y está en signup, lo mandamos al chat
      if (isAuth && isLoggingIn) return '/chat';


      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const Scaffold(body: Center(child: CircularProgressIndicator()))),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/signup', builder: (context, state) => const SignUpPage()),
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(path: '/chat', builder: (context, state) => const ChatPage()),
          GoRoute(path: '/', redirect: (_, __) => '/chat'), // Redirigir raíz al chat
        ],
      ),
    ],
  );
}