import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../bloc/auth_bloc.dart';
import '../widgets/auth_text_field.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ageController = TextEditingController();

  DateTime? _selectedDate;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _submitForm() {
    // 1. Validar inputs locales
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Por favor, selecciona tu fecha de nacimiento')));
      return;
    }

    // 2. Ejecutar evento de BLoC si  es correcto
    context.read<AuthBloc>().add(
      AuthSignUpRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        age: int.parse(_ageController.text),
        birthDate: _selectedDate!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            context.go('/');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Cuenta creada con éxito!'),
                backgroundColor: Colors.green,
              ),
            );
          }
          if (state.status == AuthStatus.error) {
            // Manejo de errores de Firebase (Email ya existe, etc)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Ocurrió un error inesperado'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Únete a AION",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Tu asistente inteligente de nueva generación",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white54),
                    ),
                    const SizedBox(height: 40),

                    // Nombre
                    AuthTextField(
                      controller: _nameController,
                      label: "Nombre completo",
                      prefixIcon: Icons.person_outline,
                      validator: (v) => v!.length < 3 ? "Nombre demasiado corto" : null,
                    ),

                    // Edad
                    AuthTextField(
                      controller: _ageController,
                      label: "Edad",
                      prefixIcon: Icons.numbers,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final age = int.tryParse(v ?? '');
                        if (age == null || age <= 0) return "Edad no válida";
                        return null;
                      },
                    ),

                    // Email
                    AuthTextField(
                      controller: _emailController,
                      label: "Correo electrónico",
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                        if (!emailRegex.hasMatch(v ?? '')) return "Email no válido";
                        return null;
                      },
                    ),

                    // Password
                    AuthTextField(
                      controller: _passwordController,
                      label: "Contraseña",
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      validator: (v) => v!.length < 6 ? "Mínimo 6 caracteres" : null,
                    ),

                    // Date Picker elegante
                    _buildDatePicker(context),

                    const SizedBox(height: 30),

                    // Botón con manejo de carga
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return ElevatedButton(
                          onPressed: state.status == AuthStatus.loading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurpleAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 5,
                          ),
                          child: state.status == AuthStatus.loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "CREAR CUENTA",
                                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                                ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime(2000),
          firstDate: DateTime(1920),
          lastDate: DateTime.now(),
        );
        if (picked != null) setState(() => _selectedDate = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month, color: Colors.deepPurpleAccent),
            const SizedBox(width: 12),
            Text(
              _selectedDate == null
                  ? "Fecha de Nacimiento"
                  : DateFormat('dd / MM / yyyy').format(_selectedDate!),
              style: TextStyle(color: _selectedDate == null ? Colors.white54 : Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
