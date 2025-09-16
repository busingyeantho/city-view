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
import 'features/public/admissions/admissions_screen.dart';
import 'features/public/admissions/admissions_payment_screen.dart';
import 'features/public/events/events_screen.dart';
import 'features/admin/theme/theme_editor_screen_new.dart' as theme_editor;
import 'features/admin/blog/screens/blog_admin_list_screen.dart';
import 'features/admin/blog/screens/blog_editor_screen.dart';
import 'features/admin/gallery/gallery_admin_screen.dart';
import 'features/admin/live/live_stream_admin_screen.dart';
import 'features/admin/users/users_admin_screen.dart';
import 'features/admin/admissions/admissions_admin_list_screen.dart';
import 'features/admin/events/events_admin_screen.dart';
import 'features/portal/auth/portal_login_screen.dart';
import 'features/portal/home/portal_home_screen.dart';
import 'features/portal/homework/portal_homework_screen.dart';
import 'features/admin/homework/homework_admin_screen.dart';
import 'features/admin/attendance/attendance_admin_screen.dart';
import 'features/portal/attendance/portal_attendance_screen.dart';
import 'features/admin/results/results_admin_screen.dart';
import 'features/portal/results/portal_results_screen.dart';
import 'features/portal/results/portal_result_print_screen.dart';
import 'features/admin/pagescms/screens/pages_list_screen.dart';
import 'features/admin/pagescms/screens/page_editor_screen.dart' as pages_cms;

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
          builder:
              (context, state) =>
                  BlogDetailScreen(slug: state.pathParameters['slug']!),
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
          builder:
              (context, state) => PagePreviewScreen(
                pageId: state.pathParameters['pageId']!,
                variant: state.pathParameters['variant']!,
              ),
        ),
        GoRoute(
          path: '/admissions',
          name: 'admissions',
          builder: (context, state) => const AdmissionsScreen(),
        ),
        GoRoute(
          path: '/admissions/pay/:id',
          name: 'admissions-pay',
          builder:
              (context, state) => AdmissionsPaymentScreen(
                admissionId: state.pathParameters['id']!,
              ),
        ),
        GoRoute(
          path: '/events',
          name: 'events',
          builder: (context, state) => const EventsScreen(),
        ),
        GoRoute(
          path: '/portal/login',
          name: 'portal-login',
          builder: (context, state) => const PortalLoginScreen(),
        ),
        GoRoute(
          path: '/portal',
          name: 'portal-home',
          redirect: (context, state) {
            final a = context.read<AuthController>();
            if (!a.isAuthenticated) return '/portal/login';
            return null;
          },
          builder: (context, state) => const PortalHomeScreen(),
        ),
        GoRoute(
          path: '/portal/homework',
          name: 'portal-homework',
          redirect: (context, state) {
            final a = context.read<AuthController>();
            if (!a.isAuthenticated) return '/portal/login';
            return null;
          },
          builder: (context, state) => const PortalHomeworkScreen(),
        ),
        GoRoute(
          path: '/portal/attendance',
          name: 'portal-attendance',
          redirect: (context, state) {
            final a = context.read<AuthController>();
            if (!a.isAuthenticated) return '/portal/login';
            return null;
          },
          builder: (context, state) => const PortalAttendanceScreen(),
        ),
        GoRoute(
          path: '/portal/results',
          name: 'portal-results',
          redirect: (context, state) {
            final a = context.read<AuthController>();
            if (!a.isAuthenticated) return '/portal/login';
            return null;
          },
          builder: (context, state) => const PortalResultsScreen(),
        ),
        GoRoute(
          path: '/portal/results/:id/print',
          name: 'portal-result-print',
          redirect: (context, state) {
            final a = context.read<AuthController>();
            if (!a.isAuthenticated) return '/portal/login';
            return null;
          },
          builder:
              (context, state) => PortalResultPrintScreen(
                resultId: state.pathParameters['id']!,
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
          builder: (context, state) => const theme_editor.ThemeEditorScreen(),
        ),
        GoRoute(
          path: '/admin/pages',
          redirect: (context, state) {
            final a = context.read<AuthController>();
            if (!a.isAuthenticated) return '/admin/login';
            return null;
          },
          routes: [
            GoRoute(
              path: 'new',
              name: 'admin-pages-new',
              builder: (context, state) => const pages_cms.PageEditorScreen(),
            ),
            GoRoute(
              path: ':id',
              name: 'admin-pages-edit',
              builder: (context, state) {
                final pageId = state.pathParameters['id']!;
                if (pageId == 'new') {
                  return const pages_cms.PageEditorScreen();
                }
                return pages_cms.PageEditorScreen(pageId: pageId);
              },
            ),
          ],
          builder: (context, state) => const PagesListScreen(),
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
          path: '/admin/admissions',
          name: 'admin-admissions',
          redirect: (context, state) {
            final a = context.read<AuthController>();
            if (!a.isAuthenticated) return '/admin/login';
            final role = a.role;
            if (role != 'super_admin' && role != 'content_manager') {
              return '/admin';
            }
            return null;
          },
          builder: (context, state) => const AdmissionsAdminListScreen(),
        ),
        GoRoute(
          path: '/admin/events',
          name: 'admin-events',
          redirect: (context, state) {
            final a = context.read<AuthController>();
            if (!a.isAuthenticated) return '/admin/login';
            final role = a.role;
            if (role != 'super_admin' && role != 'content_manager')
              return '/admin';
            return null;
          },
          builder: (context, state) => const EventsAdminScreen(),
        ),
        GoRoute(
          path: '/admin/portal/homework',
          name: 'admin-portal-homework',
          redirect: (context, state) {
            final a = context.read<AuthController>();
            if (!a.isAuthenticated) return '/admin/login';
            final role = a.role;
            if (role != 'super_admin' && role != 'content_manager')
              return '/admin';
            return null;
          },
          builder: (context, state) => const HomeworkAdminScreen(),
        ),
        GoRoute(
          path: '/admin/portal/attendance',
          name: 'admin-portal-attendance',
          redirect: (context, state) {
            final a = context.read<AuthController>();
            if (!a.isAuthenticated) return '/admin/login';
            final role = a.role;
            if (role != 'super_admin' && role != 'content_manager')
              return '/admin';
            return null;
          },
          builder: (context, state) => const AttendanceAdminScreen(),
        ),
        GoRoute(
          path: '/admin/portal/results',
          name: 'admin-portal-results',
          redirect: (context, state) {
            final a = context.read<AuthController>();
            if (!a.isAuthenticated) return '/admin/login';
            final role = a.role;
            if (role != 'super_admin' && role != 'content_manager')
              return '/admin';
            return null;
          },
          builder: (context, state) => const ResultsAdminScreen(),
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
      debugShowCheckedModeBanner: false,
    );
  }
}
