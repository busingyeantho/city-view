import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/auth/auth_controller.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Users',
            onPressed: () => context.go('/admin/users'),
            icon: const Icon(Icons.group),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: () async {
              await context.read<AuthController>().signOut();
              if (context.mounted) context.go('/admin/login');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(24),
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _DashCard(title: 'Pages / CMS', onTap: () => context.go('/admin/pages')),
          _DashCard(title: 'Blog', onTap: () => context.go('/admin/blog')),
          _DashCard(title: 'Gallery', onTap: () => context.go('/admin/gallery')),
          _DashCard(title: 'Live Stream', onTap: () => context.go('/admin/live')),
          _DashCard(title: 'Users', onTap: () => context.go('/admin/users')),
          _DashCard(title: 'Theme', onTap: () => context.go('/admin/theme')),
        ],
      ),
    );
  }
}

class _DashCard extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  const _DashCard({required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
      ),
    );
  }
}


