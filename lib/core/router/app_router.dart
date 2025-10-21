import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/expenses/presentation/pages/expenses_page.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/payments/presentation/pages/payments_page.dart';
import '../../features/teachers/presentation/pages/teachers_page.dart';
import '../../features/students/presentation/pages/students_page.dart';
import '../../features/courses/presentation/pages/courses_page.dart';
import '../../features/unpaid/presentation/pages/unpaid_students_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final authBloc = context.read<AuthBloc>();
      final isAuthenticated = authBloc.state is AuthenticatedState;
      final isLoggingIn = state.fullPath == '/login';

      if (!isAuthenticated && !isLoggingIn) {
        return '/login';
      }
      if (isAuthenticated && isLoggingIn) {
        return '/teachers';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(
            path: '/teachers',
            builder: (context, state) => const TeachersPage(),
          ),
          GoRoute(
            path: '/students',
            builder: (context, state) => const StudentsPage(),
          ),
          GoRoute(
            path: '/unpaid-students',
            builder: (context, state) => const UnpaidStudentsPage(),
          ),
          GoRoute(
            path: '/courses',
            builder: (context, state) => const CoursesPage(),
          ),
          GoRoute(
            path: '/payments',
            builder: (context, state) => const PaymentsPage(),
          ),
          GoRoute(
            path: '/expenses',
            builder: (context, state) => const ExpensesPage(),
          ),
        ],
      ),
    ],
  );
}

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EduNova - Education Management'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthBloc>().add(LogoutEvent());
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: child,
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).fullPath;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.school, size: 48, color: Colors.white),
                SizedBox(height: 16),
                Text(
                  'EduNova',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Education Management',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          _DrawerItem(
            icon: Icons.people,
            title: 'Teachers',
            path: '/teachers',
            isSelected: currentLocation == '/teachers',
          ),
          _DrawerItem(
            icon: Icons.school,
            title: 'Students',
            path: '/students',
            isSelected: currentLocation == '/students',
          ),
          _DrawerItem(
            icon: Icons.warning,
            title: 'Unpaid Students',
            path: '/unpaid-students',
            isSelected: currentLocation == '/unpaid-students',
            badgeColor: Colors.red,
          ),
          _DrawerItem(
            icon: Icons.book,
            title: 'Courses',
            path: '/courses',
            isSelected: currentLocation == '/courses',
          ),
          _DrawerItem(
            icon: Icons.payment,
            title: 'Payments',
            path: '/payments',
            isSelected: currentLocation == '/payments',
          ),
          _DrawerItem(
            icon: Icons.receipt_long,
            title: 'Expenses',
            path: '/expenses',
            isSelected: currentLocation == '/expenses',
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              context.read<AuthBloc>().add(LogoutEvent());
            },
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String path;
  final bool isSelected;
  final Color? badgeColor;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.path,
    required this.isSelected,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Stack(
        children: [
          Icon(icon, color: isSelected ? Colors.blue : null),
          if (badgeColor != null)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.blue : null,
          fontWeight: isSelected ? FontWeight.bold : null,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Colors.blue.withOpacity(0.1),
      onTap: () {
        Navigator.pop(context);
        context.go(path);
      },
    );
  }
}