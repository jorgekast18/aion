import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aion/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:aion/core/injection/injection_container.dart' as di;
import 'package:aion/features/chat/presentation/bloc/chat_bloc.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final String currentRoute = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF12121F),
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "AION AI",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              authState.user?.name ?? "Usuario",
              style: const TextStyle(fontSize: 12, color: Colors.white54),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: () => context.read<AuthBloc>().add(AuthLogoutRequested()),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildDrawer(context),
      body: BlocProvider<ChatBloc>(
        create: (context) => di.sl<ChatBloc>(
          param1: context.read<AuthBloc>().state.user?.id ?? '',
        ),
        child: child,
      ),
      // Usamos BottomNavigationBar para movilidad, o NavigationRail para tablets
      bottomNavigationBar: NavigationBar(
        selectedIndex: _getSelectedIndex(currentRoute),
        onDestinationSelected: (index) => _onItemTapped(index, context),
        backgroundColor: const Color(0xFF12121F),
        indicatorColor: Colors.deepPurpleAccent.withOpacity(0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble, color: Colors.deepPurpleAccent),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome, color: Colors.deepPurpleAccent),
            label: 'Resumidor',
          ),
          NavigationDestination(
            icon: Icon(Icons.lightbulb_outline),
            selectedIcon: Icon(Icons.lightbulb, color: Colors.deepPurpleAccent),
            label: 'Notas AI',
          ),
        ],
      ),
    );
  }

  int _getSelectedIndex(String route) {
    if (route.startsWith('/chat')) return 0;
    if (route.startsWith('/summarizer')) return 1;
    if (route.startsWith('/notes')) return 2;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0: context.go('/chat'); break;
      case 1: context.go('/summarizer'); break;
      case 2: context.go('/notes'); break;
    }
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF12121F),
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.deepPurpleAccent),
            child: Center(
              child: Text("AION PREMIUM",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Configuración"),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}