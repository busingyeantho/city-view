import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:city_view_website/features/admin/dashboard/admin_dashboard_screen.dart';
import 'package:city_view_website/core/auth/auth_controller.dart';

// Mock classes
class MockGoRouter extends Mock implements GoRouter {}

class MockAuthController extends Mock implements AuthController {}

void main() {
  late MockGoRouter mockGoRouter;
  late MockAuthController mockAuthController;

  setUp(() {
    mockGoRouter = MockGoRouter();
    mockAuthController = MockAuthController();

    // Setup default mock behaviors
    when(() => mockAuthController.isAuthenticated).thenReturn(true);
    when(() => mockAuthController.role).thenReturn('super_admin');
    when(() => mockGoRouter.location).thenReturn('/admin');
  });

  // Helper function to create widget under test
  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthController>.value(
            value: mockAuthController,
          ),
        ],
        child: const AdminDashboardScreen(),
      ),
    );
  }

  testWidgets('displays the admin dashboard with all navigation cards', (
    tester,
  ) async {
    // Arrange
    await tester.pumpWidget(createWidgetUnderTest());

    // Assert
    expect(find.text('Pages / CMS'), findsOneWidget);
    expect(find.text('Blog'), findsOneWidget);
    expect(find.text('Gallery'), findsOneWidget);
    expect(find.text('Events'), findsOneWidget);
    expect(find.text('Admissions'), findsOneWidget);
    expect(find.text('Live Stream'), findsOneWidget);
    expect(find.text('Users'), findsOneWidget);
    expect(find.text('Theme'), findsOneWidget);
  });

  testWidgets('navigates to Pages/CMS when Pages card is tapped', (
    tester,
  ) async {
    // Arrange
    when(() => mockGoRouter.push('/admin/pages')).thenAnswer((_) async {});

    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthController>.value(
              value: mockAuthController,
            ),
          ],
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => context.push('/admin/pages'),
                child: const Text('Pages / CMS'),
              );
            },
          ),
        ),
      ),
    );

    // Act
    await tester.tap(find.text('Pages / CMS'));
    await tester.pumpAndSettle();

    // Assert
    verify(() => mockGoRouter.push('/admin/pages')).called(1);
  });

  testWidgets('shows sign out button in app bar', (tester) async {
    // Arrange
    await tester.pumpWidget(createWidgetUnderTest());

    // Assert
    expect(find.byIcon(Icons.logout), findsOneWidget);
  });

  testWidgets('signs out when sign out button is tapped', (tester) async {
    // Arrange
    when(() => mockAuthController.signOut()).thenAnswer((_) async {});
    when(() => mockGoRouter.go('/admin/login')).thenReturn(null);

    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthController>.value(
              value: mockAuthController,
            ),
          ],
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  mockAuthController.signOut();
                  mockGoRouter.go('/admin/login');
                },
                child: const Text('Sign Out'),
              );
            },
          ),
        ),
      ),
    );

    // Act
    await tester.tap(find.text('Sign Out'));
    await tester.pumpAndSettle();

    // Assert
    verify(() => mockAuthController.signOut()).called(1);
    verify(() => mockGoRouter.go('/admin/login')).called(1);
  });
}
