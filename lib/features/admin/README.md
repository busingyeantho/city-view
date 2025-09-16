# Admin Screens

This directory contains the admin screens for the application. We've implemented a base template system to ensure consistency and reduce code duplication across admin screens.

## Base Admin Screen

The `BaseAdminScreen` class provides common functionality for admin screens, including:
- Loading states
- Error handling
- Firestore integration
- Common UI elements

### Creating a New Admin Screen

1. **Simple Admin Screen**:

```dart
import 'package:flutter/material.dart';
import '../shared/base_admin_screen.dart';

class MyAdminScreen extends BaseAdminScreen<MyAdminScreen> {
  const MyAdminScreen({Key? key}) 
    : super(
        key: key,
        title: 'My Admin Screen',
        collectionName: 'my_collection',
      );

  @override
  State<MyAdminScreen> createState() => _MyAdminScreenState();
}

class _MyAdminScreenState extends BaseAdminScreenState<MyAdminScreen> {
  @override
  Widget buildContent(BuildContext context) {
    return const Center(
      child: Text('My Admin Screen Content'),
    );
  }
}
```

2. **List Admin Screen**:

```dart
import 'package:flutter/material.dart';
import '../shared/base_admin_screen.dart';

class MyListScreen extends BaseListAdminScreen<MyListScreen> {
  const MyListScreen({Key? key}) 
    : super(
        key: key,
        title: 'My List Screen',
        collectionName: 'my_collection',
      );

  @override
  State<MyListScreen> createState() => _MyListScreenState();
}

class _MyListScreenState extends BaseListAdminScreenState<MyListScreen> {
  @override
  Widget buildListItem(
    BuildContext context,
    DocumentSnapshot<Map<String, dynamic>> doc,
    int index,
  ) {
    final data = doc.data() ?? {};
    return ListTile(
      title: Text(data['title'] ?? 'No Title'),
      subtitle: Text(data['description'] ?? ''),
    );
  }
}
```

## Common Patterns

### Loading Data

```dart
Future<void> loadData() async {
  await executeWithLoader(() async {
    // Your data loading logic here
  });
}
```

### Showing Messages

```dart
// Success message
showMessage('Operation completed successfully');

// Error message
showMessage('An error occurred', isError: true);
```

### Accessing Firestore

```dart
// Get collection reference
final collection = collectionRef;

// Get document reference (if documentId is provided)
if (documentRef != null) {
  final doc = await documentRef!.get();
  // Use document data
}
```

## Best Practices

1. **Error Handling**: Always use `executeWithLoader` for async operations to handle loading and error states.
2. **State Management**: Use the built-in state management for simple screens. Consider using a state management solution for complex screens.
3. **Responsive Design**: Ensure your admin screens work well on different screen sizes.
4. **Documentation**: Add clear documentation for complex screens and custom functionality.

## Next Steps

1. Refactor existing admin screens to use the base template
2. Add more reusable components to the `shared` directory
3. Implement common form fields and validators
4. Add automated tests for the base functionality
