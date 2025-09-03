import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ResponsiveScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  const ResponsiveScaffold({super.key, required this.body, required this.title});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;
    final nav = _NavBar(isWide: isWide);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: isWide ? nav.items(context) : null,
      ),
      drawer: isWide ? null : Drawer(child: ListView(children: nav.drawerItems(context))),
      body: body,
    );
  }
}

class _NavBar {
  final bool isWide;
  _NavBar({required this.isWide});

  List<Widget> items(BuildContext context) {
    return [
      TextButton(onPressed: () => context.go('/'), child: const Text('Home')),
      TextButton(onPressed: () => context.go('/about'), child: const Text('About')),
      TextButton(onPressed: () => context.go('/academics'), child: const Text('Academics')),
      TextButton(onPressed: () => context.go('/sports'), child: const Text('Sports')),
      TextButton(onPressed: () => context.go('/health-diet'), child: const Text('Health & Diet')),
      TextButton(onPressed: () => context.go('/achievements'), child: const Text('Achievements')),
      TextButton(onPressed: () => context.go('/blog'), child: const Text('Blog')),
      TextButton(onPressed: () => context.go('/gallery'), child: const Text('Gallery')),
      TextButton(onPressed: () => context.go('/contact'), child: const Text('Contact')),
      const SizedBox(width: 8),
      FilledButton(onPressed: () => context.go('/admin/login'), child: const Text('Admin')),
      const SizedBox(width: 8),
    ];
  }

  List<Widget> drawerItems(BuildContext context) {
    return [
      const DrawerHeader(child: Text('City View School')),
      ListTile(title: const Text('Home'), onTap: () => context.go('/')),
      ListTile(title: const Text('About'), onTap: () => context.go('/about')),
      ListTile(title: const Text('Academics'), onTap: () => context.go('/academics')),
      ListTile(title: const Text('Sports'), onTap: () => context.go('/sports')),
      ListTile(title: const Text('Health & Diet'), onTap: () => context.go('/health-diet')),
      ListTile(title: const Text('Achievements'), onTap: () => context.go('/achievements')),
      ListTile(title: const Text('Blog'), onTap: () => context.go('/blog')),
      ListTile(title: const Text('Gallery'), onTap: () => context.go('/gallery')),
      ListTile(title: const Text('Contact'), onTap: () => context.go('/contact')),
      const Divider(),
      ListTile(title: const Text('Admin'), onTap: () => context.go('/admin/login')),
    ];
  }
}


