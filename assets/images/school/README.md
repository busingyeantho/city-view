# School Branding Assets

This directory contains custom SVG images created specifically for City View School's website branding.

## Available Images

### `hero-background.svg`
- **Purpose**: Main hero section background
- **Dimensions**: 1200x600
- **Features**: School building illustration with blue gradient background
- **Usage**: Homepage hero section

### `digital-lab.svg`
- **Purpose**: IT Digital Community Laboratory showcase
- **Dimensions**: 800x400
- **Features**: Computer lab with students, teacher's desk, and interactive whiteboard
- **Usage**: Digital literacy section, highlights grid

### `school-logo.svg`
- **Purpose**: School logo and branding
- **Dimensions**: 200x200
- **Features**: Circular logo with school building, flag, and decorative elements
- **Usage**: Navigation bar, app headers, branding elements

### `students-learning.svg`
- **Purpose**: Active learning environment representation
- **Dimensions**: 600x400
- **Features**: Classroom with students, teacher, and blackboard
- **Usage**: Student life section, learning highlights

### `sports-activity.svg`
- **Purpose**: Sports and physical education showcase
- **Dimensions**: 600x400
- **Features**: Sports field with students playing, goal posts, and equipment
- **Usage**: Sports section, highlights grid

### `healthy-meals.svg`
- **Purpose**: Nutrition and cafeteria representation
- **Dimensions**: 600x400
- **Features**: Cafeteria with students, healthy food, and kitchen area
- **Usage**: Health & diet section, highlights grid

## Usage in Code

These images are used through the `SchoolImage` widget and `SchoolImages` helper class:

```dart
import '../../../shared/widgets/school_image.dart';

// Using predefined helpers
SchoolImages.heroBackground(width: double.infinity, height: 500)
SchoolImages.digitalLab(width: 32, height: 32)
SchoolImages.schoolLogo(width: 48, height: 48)

// Using the base widget
SchoolImage(
  assetPath: 'assets/images/school/custom-image.svg',
  width: 100,
  height: 100,
  fit: BoxFit.cover,
)
```

## Customization

To add new school images:

1. Create SVG file in this directory
2. Add helper method to `SchoolImages` class in `lib/shared/widgets/school_image.dart`
3. Use the new helper throughout the app

## Design Guidelines

- All images use consistent color palette (blues, greens, warm tones)
- SVG format for scalability and small file sizes
- School-appropriate content and styling
- Consistent visual style across all images
