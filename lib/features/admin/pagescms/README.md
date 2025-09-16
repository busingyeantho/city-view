# Pages CMS

A modern, user-friendly content management system for managing website pages.

## Features

- Create, edit, and delete pages
- Draft and publish workflow
- Version history and rollback
- SEO-friendly URLs and metadata
- Responsive design for all devices
- Image management with previews

## Project Structure

```
lib/features/admin/pagescms/
├── models/
│   └── page_data.dart       # Page data model
├── providers/
│   └── page_provider.dart   # State management
├── screens/
│   ├── pages_list_screen.dart  # List all pages
│   └── page_editor_screen.dart # Edit/create page
└── pages_router.dart        # Routing configuration
```

## Usage

### Accessing the Pages CMS
1. Log in to the admin dashboard
2. Click on "Pages / CMS"

### Creating a New Page
1. Click the "+" button in the app bar
2. Fill in the page details (title, slug, content, etc.)
3. Click "Save Draft" to save your changes
4. Click "Publish" to make the page live

### Editing a Page
1. Click on a page in the list
2. Make your changes
3. Click "Save Draft" or "Publish"

### Managing Versions
1. Click the history icon in the app bar
2. View previous versions
3. Click on a version to restore it

## Data Model

### PageData
- `id`: Unique identifier
- `title`: Page title
- `slug`: URL-friendly identifier
- `content`: Page content (JSON)
- `draft`: Unsaved changes (optional)
- `isPublished`: Whether the page is live
- `heroImageUrl`: Main image URL (optional)
- `seoDescription`: Meta description for SEO
- `createdAt`: Creation timestamp
- `updatedAt`: Last update timestamp
- `createdBy`: User who created the page
- `updatedBy`: User who last updated the page

## Integration

The Pages CMS is integrated with the main app router and can be accessed at `/admin/pages`.

### Dependencies
- `provider`: State management
- `cloud_firestore`: Database
- `firebase_storage`: File storage
- `go_router`: Navigation

## Future Improvements

- [ ] Add rich text editor integration
- [ ] Add image cropping and optimization
- [ ] Add page templates
- [ ] Add scheduled publishing
- [ ] Add page analytics
