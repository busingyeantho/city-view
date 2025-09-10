import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PortalHomeScreen extends StatelessWidget {
  const PortalHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Parent/Student Portal')),
      body: GridView.count(
        padding: const EdgeInsets.all(24),
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _Card(title: 'Homework', onTap: () => context.go('/portal/homework')),
          _Card(title: 'Attendance', onTap: () {}),
          _Card(title: 'Results', onTap: () {}),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  const _Card({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Center(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
      ),
    );
  }
}


