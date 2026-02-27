import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_text_field.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A12),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) context.go('/chat');
          if (state.status == AuthStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Error'), backgroundColor: Colors.redAccent),
            );
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Icon(Icons.auto_awesome, size: 80, color: Colors.deepPurpleAccent),
                  const SizedBox(height: 24),
                  const Text("Bienvenido a AION", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 40),
                  AuthTextField(
                    controller: _emailController,
                    label: "Email",
                    prefixIcon: Icons.email_outlined,
                    validator: (v) => v!.isEmpty ? "Campo requerido" : null,
                  ),
                  AuthTextField(
                    controller: _passwordController,
                    label: "Contraseña",
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    validator: (v) => v!.length < 6 ? "Mínimo 6 caracteres" : null,
                  ),
                  const SizedBox(height: 24),
                  _LoginButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<AuthBloc>().add(AuthLoginRequested(
                          email: _emailController.text.trim(),
                          password: _passwordController.text.trim(),
                        ));
                      }
                    },
                  ),
                  TextButton(
                    onPressed: () => context.push('/signup'),
                    child: const Text("¿No tienes cuenta? Regístrate aquí", style: TextStyle(color: Colors.white54)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _LoginButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final status = context.watch<AuthBloc>().state.status;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 54),
        backgroundColor: Colors.deepPurpleAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: status == AuthStatus.loading ? null : onPressed,
      child: status == AuthStatus.loading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text("INICIAR SESIÓN", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }
}