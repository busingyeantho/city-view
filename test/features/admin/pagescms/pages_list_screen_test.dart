import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:city_view_website/features/admin/pagescms/models/page_data.dart';
import 'package:city_view_website/features/admin/pagescms/providers/page_provider.dart';
import 'package:city_view_website/features/admin/pagescms/screens/pages_list_screen.dart';

// Mock classes
class MockPageProvider extends Mock implements PageProvider {}

class MockGoRouter extends Mock implements GoRouter {}

class MockGoRouterState extends Mock implements GoRouterState {}

void main() {
  late MockPageProvider mockPageProvider;
  late MockGoRouter mockGoRouter;
  late MockGoRouterState mockGoRouterState;

  setUp(() {
    mockPageProvider = MockPageProvider();
    mockGoRouter = MockGoRouter();
    mockGoRouterState = MockGoRouterState();

    // Setup default mock behavior
    when(() => mockGoRouter.location).thenReturn('/admin/pages');
    when(() => mockGoRouterState.location).thenReturn('/admin/pages');
  });

  // Helper function to create widget under test
  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<PageProvider>.value(value: mockPageProvider),
        ],
        child: const PagesListScreen(),
      ),
    );
  }

  testWidgets('displays loading indicator when loading pages', (tester) async {
    // Arrange
    when(() => mockPageProvider.isLoading).thenReturn(true);
    when(
      () => mockPageProvider.watchPages(),
    ).thenAnswer((_) => const Stream.empty());

    // Act
    await tester.pumpWidget(createWidgetUnderTest());

    // Assert
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('displays error message when error occurs', (tester) async {
    // Arrange
    when(() => mockPageProvider.error).thenReturn('Test error');
    when(() => mockPageProvider.isLoading).thenReturn(false);
    when(
      () => mockPageProvider.watchPages(),
    ).thenAnswer((_) => const Stream.empty());

    // Act
    await tester.pumpWidget(createWidgetUnderTest());

    // Assert
    expect(find.text('Error: Test error'), findsOneWidget);
  });

  testWidgets('navigates to page editor when add button is pressed', (
    tester,
  ) async {
    // Arrange
    when(() => mockPageProvider.isLoading).thenReturn(false);
    when(
      () => mockPageProvider.watchPages(),
    ).thenAnswer((_) => Stream.value([]));
    when(() => mockGoRouter.push('/admin/pages/new')).thenAnswer((_) async {});

    // Wrap with MaterialApp to provide MediaQuery and other widgets
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<PageProvider>.value(value: mockPageProvider),
          ],
          child: Material(
            child: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () => context.push('/admin/pages/new'),
                  child: const Text('Add Page'),
                );
              },
            ),
          ),
        ),
      ),
    );

    // Act
    await tester.tap(find.text('Add Page'));
    await tester.pumpAndSettle();

    // Assert
    verify(() => mockGoRouter.push('/admin/pages/new')).called(1);
  });

  testWidgets('displays list of pages', (tester) async {
    // Arrange
    final testPages = [
      PageData(
        id: '1',
        title: 'Test Page 1',
        slug: 'test-page-1',
        content: {},
        isPublished: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      PageData(
        id: '2',
        title: 'Test Page 2',
        slug: 'test-page-2',
        content: {},
        isPublished: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    when(() => mockPageProvider.isLoading).thenReturn(false);
    when(
      () => mockPageProvider.watchPages(),
    ).thenAnswer((_) => Stream.value(testPages));

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Test Page 1'), findsOneWidget);
    expect(find.text('Test Page 2'), findsOneWidget);
    expect(find.byIcon(Icons.visibility), findsOneWidget); // Published icon
    expect(find.byIcon(Icons.visibility_off), findsOneWidget); // Draft icon
  });

  testWidgets('navigates to Pages/CMS screen', (tester) async {
    // Arrange
    when(() => mockGoRouter.push('/admin/pages')).thenAnswer((_) async {});

    // Wrap with MaterialApp to provide MediaQuery and other widgets
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => context.push('/admin/pages'),
                child: const Text('Go to Pages/CMS'),
              );
            },
          ),
        ),
      ),
    );

    // Act
    await tester.tap(find.text('Go to Pages/CMS'));
    await tester.pumpAndSettle();

    // Assert
    verify(() => mockGoRouter.push('/admin/pages')).called(1);
  });
}
