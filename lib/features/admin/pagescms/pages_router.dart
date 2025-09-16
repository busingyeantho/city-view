import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/pages_list_screen.dart';
import 'screens/page_editor_screen.dart';

class PagesRouter {
  static const String pagesList = '/admin/pages';
  static const String pageEditor = '/admin/pages/:id';
  static const String newPage = '/admin/pages/new';

  static final router = GoRoute(
    path: 'pages',
    builder: (context, state) => const PagesListScreen(),
    routes: [
      GoRoute(
        path: 'new',
        builder: (context, state) => const PageEditorScreen(),
      ),
      GoRoute(
        path: ':id',
        builder: (context, state) {
          final pageId = state.pathParameters['id']!;
          return PageEditorScreen(pageId: pageId);
        },
      ),
    ],
  );

  static String getPageEditorPath(String pageId) => '/admin/pages/$pageId';
  static String getNewPagePath() => newPage;
  static String getPagesListPath() => pagesList;
}
