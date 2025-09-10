import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import '../widgets/school_image.dart';
import '../widgets/responsive_helper.dart';
import '../widgets/school_footer.dart';
import '../../core/theme/school_colors.dart';

class ResponsiveScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  const ResponsiveScaffold({super.key, required this.body, required this.title});

  @override
  Widget build(BuildContext context) {
    final isWide = !ResponsiveHelper.isMobile(context);
    final nav = _NavBar(isWide: isWide);
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SchoolImages.schoolLogo(
              width: ResponsiveHelper.isMobile(context) ? 24 : 32, 
              height: ResponsiveHelper.isMobile(context) ? 24 : 32
            ),
            SizedBox(width: ResponsiveHelper.isMobile(context) ? 8 : 12),
            Expanded(
              child: ResponsiveText(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: ResponsiveHelper.isMobile(context) ? 18 : 20,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: isWide ? nav.items(context) : null,
        elevation: 2,
      ),
      drawer: isWide ? null : Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: nav.drawerItems(context),
        ),
      ),
      body: Stack(
        children: [
          // Main content area that takes full height and is scrollable
          SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 
                         kToolbarHeight - 
                         MediaQuery.of(context).padding.top,
              ),
              child: Column(
                children: [
                  // Main content
                  Padding(
                    padding: ResponsiveHelper.getResponsiveEdgeInsets(context),
                    child: body,
                  ),
                  // Add some space before footer
                  SizedBox(height: 40),
                  // Footer
                  const SchoolFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavBar {
  final bool isWide;
  _NavBar({required this.isWide});

  List<Widget> items(BuildContext context) {
    return [
      _NavItem(text: 'Home', onTap: () => context.go('/')),
      _NavItem(text: 'About', onTap: () => context.go('/about')),
      _NavItem(text: 'Academics', onTap: () => context.go('/academics')),
      _NavItem(text: 'Sports', onTap: () => context.go('/sports')),
      _NavItem(text: 'Health & Diet', onTap: () => context.go('/health-diet')),
      _NavItem(text: 'Achievements', onTap: () => context.go('/achievements')),
      _NavItem(text: 'Blog', onTap: () => context.go('/blog')),
      _NavItem(text: 'Events', onTap: () => context.go('/events')),
      _NavItem(text: 'Admissions', onTap: () => context.go('/admissions')),
      _NavItem(text: 'Gallery', onTap: () => context.go('/gallery')),
      _NavItem(text: 'Contact', onTap: () => context.go('/contact')),
      const SizedBox(width: 8),
      FilledButton(
        onPressed: () => context.go('/admin/login'),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ), 
        child: const Text('Admin'),
      ),
      const SizedBox(width: 8),
    ];
  }

  List<Widget> drawerItems(BuildContext context) {
    return [
      DrawerHeader(
        decoration: BoxDecoration(
          gradient: SchoolColors.primaryGradient,
        ),
        child: Row(
          children: [
            SchoolImages.schoolLogo(width: 48, height: 48),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'City View School',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      _DrawerItem(icon: Icons.home, text: 'Home', onTap: () => context.go('/')),
      _DrawerItem(icon: Icons.info, text: 'About', onTap: () => context.go('/about')),
      _DrawerItem(icon: Icons.school, text: 'Academics', onTap: () => context.go('/academics')),
      _DrawerItem(icon: Icons.sports_soccer, text: 'Sports', onTap: () => context.go('/sports')),
      _DrawerItem(icon: Icons.restaurant, text: 'Health & Diet', onTap: () => context.go('/health-diet')),
      _DrawerItem(icon: Icons.emoji_events, text: 'Achievements', onTap: () => context.go('/achievements')),
      _DrawerItem(icon: Icons.article, text: 'Blog', onTap: () => context.go('/blog')),
      _DrawerItem(icon: Icons.event, text: 'Events', onTap: () => context.go('/events')),
      _DrawerItem(icon: Icons.app_registration, text: 'Admissions', onTap: () => context.go('/admissions')),
      _DrawerItem(icon: Icons.photo_library, text: 'Gallery', onTap: () => context.go('/gallery')),
      _DrawerItem(icon: Icons.contact_mail, text: 'Contact', onTap: () => context.go('/contact')),
      const Divider(),
      _DrawerItem(icon: Icons.admin_panel_settings, text: 'Admin', onTap: () => context.go('/admin/login')),
    ];
  }
}

/// Animated navigation item for desktop
class _NavItem extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const _NavItem({
    required this.text,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: TextButton(
              onPressed: widget.onTap,
              child: Text(
                widget.text,
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobile: 12, tablet: 14, desktop: 16),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Enhanced drawer item with icons
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(
        text,
        style: TextStyle(
          fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobile: 14, tablet: 16, desktop: 16),
        ),
      ),
      onTap: () {
        Navigator.of(context).pop(); // Close drawer
        onTap();
      },
      hoverColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
    );
  }
}


