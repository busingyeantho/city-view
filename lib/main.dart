import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_strategy/url_strategy.dart';

import 'app.dart';
import 'core/firebase/firebase_bootstrap.dart';
import 'core/theme/theme_controller.dart';
import 'core/auth/auth_controller.dart';
import 'features/admin/pagescms/providers/page_provider.dart';
import 'features/gallery/providers/gallery_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();
  await FirebaseBootstrap.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeController>(
          create: (_) => ThemeController()..loadTheme(),
        ),
        ChangeNotifierProvider<AuthController>(create: (_) => AuthController()),
        ChangeNotifierProvider<PageProvider>(create: (_) => PageProvider()),
        ChangeNotifierProvider<GalleryProvider>(
          create: (_) => GalleryProvider()..initialize(),
        ),
      ],
      child: const CityViewApp(),
    ),
  );
}
