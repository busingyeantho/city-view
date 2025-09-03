import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/theme/theme_controller.dart';
import 'core/auth/auth_controller.dart';
import 'features/public/home/home_screen.dart';
import 'features/admin/auth/admin_login_screen.dart';
import 'features/admin/dashboard/admin_dashboard_screen.dart';
import 'features/public/about/about_screen.dart';
import 'features/public/blog/blog_list_screen.dart';
import 'features/public/gallery/gallery_screen.dart';
import 'features/public/contact/contact_screen.dart';
import 'features/public/blog/blog_detail_screen.dart';
import 'features/public/preview/page_preview_screen.dart';
import 'features/public/academics/academics_screen.dart';
import 'features/public/sports/sports_screen.dart';
import 'features/public/health/health_screen.dart';
import 'features/public/achievements/achievements_screen.dart';
import 'features/admin/theme/theme_editor_screen.dart';
import 'features/admin/cms/page_editor_screen.dart';
import 'features/admin/blog/blog_admin_list_screen.dart';
import 'features/admin/blog/blog_editor_screen.dart';
import 'features/admin/gallery/gallery_admin_screen.dart';
import 'features/admin/live/live_stream_admin_screen.dart';
import 'features/admin/users/users_admin_screen.dart';

class CityViewApp extends StatelessWidget {
  const CityViewApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();

    final auth = context.watch<AuthController>();
    final router = GoRouter(
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/about',
          name: 'about',
          builder: (context, state) => const AboutScreen(),
        ),
        GoRoute(
          path: '/academics',
          name: 'academics',
          builder: (context, state) => const AcademicsScreen(),
        ),
        GoRoute(
          path: '/sports',
          name: 'sports',
          builder: (context, state) => const SportsScreen(),
        ),
        GoRoute(
          path: '/health-diet',
          name: 'health-diet',
          builder: (context, state) => const HealthScreen(),
        ),
        GoRoute(
          path: '/achievements',
          name: 'achievements',
          builder: (context, state) => const AchievementsScreen(),
        ),
        GoRoute(
          path: '/blog',
          name: 'blog',
          builder: (context, state) => const BlogListScreen(),
        ),
        GoRoute(
          path: '/blog/:slug',
          name: 'blog-detail',
          builder: (context, state) => BlogDetailScreen(slug: state.pathParameters['slug']!),
        ),
        GoRoute(
          path: '/gallery',
          name: 'gallery',
          builder: (context, state) => const GalleryScreen(),
        ),
        GoRoute(
          path: '/contact',
          name: 'contact',
          builder: (context, state) => const ContactScreen(),
        ),
        GoRoute(
          path: '/preview/:pageId/:variant',
          name: 'page-preview',
          builder: (context, state) => PagePreviewScreen(
            pageId: state.pathParameters['pageId']!,
            variant: state.pathParameters['variant']!,
          ),
        ),
        GoRoute(
          path: '/admin/login',
          name: 'admin-login',
          builder: (context, state) => const AdminLoginScreen(),
        ),
        GoRoute(
          path: '/admin',
          name: 'admin-dashboard',
          redirect: (context, state) {
            final a = context.read<AuthController>();
            if (!a.isAuthenticated) return '/admin/login';
            return null;
          },
          builder: (context, state) => const AdminDashboardScreen(),
        ),
        GoRoute(
          path: '/admin/theme',
          name: 'admin-theme',
          redirect: (context, state) {
            final a = context.read<AuthController>();
            if (!a.isAuthenticated) return '/admin/login';
            return null;
          },
          builder: (context, state) => const ThemeEditorScreen(),
        ),
        GoRoute(
          path: '/admin/pages',
          name: 'admin-pages',
          redirect: (context, state) {
            final a = context.read<AuthController>();
            if (!a.isAuthenticated) return '/admin/login';
            final role = a.role;
            if (role != 'super_admin' && role != 'content_manager') {
              return '/admin';
            }
            return null;
          },
          builder: (context, state) => const PageEditorScreen(),
        ),
        GoRoute(
          path: '/admin/blog',
          name: 'admin-blog',
          redirect: (context, state) {
            final a = context.read<AuthController>();
            if (!a.isAuthenticated) return '/admin/login';
            // blogger, content_manager, super_admin allowed
            if (a.role == null) return '/admin';
            return null;
          },
          builder: (context, state) => const BlogAdminListScreen(),
        ),
        GoRoute(
          path: '/admin/blog/new',
          name: 'admin-blog-new',
          redirect: (context, state) {
            final a = context.read<AuthController>();
            if (!a.isAuthenticated) return '/admin/login';
            if (a.role == null) return '/admin';
            return null;
          },
          builder: (context, state) => const BlogEditorScreen(),
        ),
        GoRoute(
          path: '/admin/gallery',
          name: 'admin-gallery',
          redirect: (context, state) {
            final a = context.read<AuthController>();
            if (!a.isAuthenticated) return '/admin/login';
            final role = a.role;
            if (role != 'super_admin' && role != 'content_manager') {
              return '/admin';
            }
            return null;
          },
          builder: (context, state) => const GalleryAdminScreen(),
        ),
        GoRoute(
          path: '/admin/live',
          name: 'admin-live',
          redirect: (context, state) {
            final a = context.read<AuthController>();
            if (!a.isAuthenticated) return '/admin/login';
            return null;
          },
          builder: (context, state) => const LiveStreamAdminScreen(),
        ),
        GoRoute(
          path: '/admin/users',
          name: 'admin-users',
          redirect: (context, state) {
            final a = context.read<AuthController>();
            if (!a.isAuthenticated) return '/admin/login';
            final role = a.role;
            if (role != 'super_admin') return '/admin';
            return null;
          },
          builder: (context, state) => const UsersAdminScreen(),
        ),
      ],
      initialLocation: '/',
      debugLogDiagnostics: false,
    );

    return MaterialApp.router(
      title: 'City View School',
      theme: themeController.currentTheme,
      routerConfig: router,
    );
  }
}


