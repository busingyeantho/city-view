import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/school_colors.dart';
import '../../../../shared/widgets/error_display.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructiveAction;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    required this.onConfirm,
    this.onCancel,
    this.isDestructiveAction = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: onCancel ?? () => Navigator.of(context).pop(),
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: onConfirm,
          style: isDestructiveAction
              ? TextButton.styleFrom(foregroundColor: SchoolColors.error)
              : null,
          child: Text(confirmText),
        ),
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? action;
  
  const SectionHeader({
    super.key,
    required this.title,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: SchoolColors.darkText,
                ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}
import '../providers/gallery_admin_provider.dart';
import '../models/gallery_category.dart';
import '../models/gallery_image.dart';
import '../widgets/category_form_dialog.dart';
import '../widgets/image_upload_dialog.dart';

class GalleryAdminScreen extends StatefulWidget {
  const GalleryAdminScreen({super.key});

  @override
  State<GalleryAdminScreen> createState() => _GalleryAdminScreenState();
}

class _GalleryAdminScreenState extends State<GalleryAdminScreen> {
  final _scrollController = ScrollController();
  bool _isInitialized = false;
  bool _isLoading = true;
  String? _error;
  StreamSubscription? _errorSubscription;
  StreamSubscription? _loadingSubscription;
  GalleryAdminProvider? _provider;
  List<GalleryCategory> _categories = [];

  Future<void> _initialize() async {
    if (_isInitialized) return;
    
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      await Provider.of<GalleryAdminProvider>(context, listen: false).loadCategories();
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize: $e')),
        );
      }
    }
  }
  
  void _setupProviderListeners() {
    _errorSubscription?.cancel();
    _loadingSubscription?.cancel();
    
    _errorSubscription = _provider?.errorStream.listen((error) {
      if (mounted) {
        setState(() {
          _error = error;
          _isLoading = false;
        });
      }
    });
    
    _loadingSubscription = _provider?.loadingStream.listen((isLoading) {
      if (mounted) {
        setState(() {
          _isLoading = isLoading;
        });
      }
    });
  }
  
  Future<void> _showAddCategoryDialog() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                try {
                  await _provider?.addCategory(
                    name: name,
                    description: descriptionController.text.trim(),
                  );
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Category added successfully')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to add category: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _showUploadImagesDialog(GalleryCategory category) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );
    
    if (result != null && result.files.isNotEmpty) {
      try {
        await _provider?.uploadImages(
          categoryId: category.id,
          files: result.files,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Images uploaded successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload images: $e')),
          );
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newProvider = Provider.of<GalleryAdminProvider>(context, listen: true);
    if (newProvider != _provider) {
      _provider = newProvider;
      _setupProviderListeners();
      
      // Update categories when provider changes
      if (_provider != null) {
        _categories = _provider!.categories;
        if (!_isInitialized) {
          _initialize();
        }
      }
  }

  void _setupProviderListeners() {
    _errorSubscription?.cancel();
    _loadingSubscription?.cancel();

    _errorSubscription = _provider?.errorStream.listen((error) {
      if (mounted) {
        setState(() {
          _error = error;
        });
      }
    });

    _loadingSubscription = _provider?.loadingStream.listen((isLoading) {
      if (mounted) {
        setState(() {
          _isLoading = isLoading;
        });
      }
    });
  }

  Future<void> _initialize() async {
    if (_isInitialized || _provider == null) return;

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      await _provider!.initialize();
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = Theme.of(context).colorScheme;
    final provider = Provider.of<GalleryAdminProvider>(context);

    // Update local state from provider
    if (provider.categories != _categories) {
      _categories = provider.categories;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery Management'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.0),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _initialize,
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: _isLoading && _categories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorDisplay()
              : _categories.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.photo_library, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            'No categories found',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add a new category to get started',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    )
                  : _buildContent(theme, colors),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCategoryDialog,
        icon: const Icon(Icons.add_photo_alternate),
        label: const Text('Add Category'),
        backgroundColor: SchoolColors.primary,
        foregroundColor: SchoolColors.lightText,
      ),
    );
  }

  Widget _buildErrorDisplay() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 24),
            Text(
              'Failed to load gallery data',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _error ?? 'An unknown error occurred',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _isLoading ? null : _initialize,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.refresh),
              label: Text(_isLoading ? 'Loading...' : 'Retry'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme, ColorScheme colors) {
    return Consumer<GalleryAdminProvider>(
      builder: (context, provider, _) {
        // Update local state from provider
        if (provider.categories != _categories) {
          _categories = provider.categories;
        }
        if (provider.categories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  size: 64,
                  color: colors.onSurface.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No categories found. Tap + to add a new category.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: SchoolColors.darkText.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _initialize,
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: provider.categories.length,
            itemBuilder: (context, index) {
              final category = provider.categories[index];
              return _buildCategoryCard(category, provider, colors);
            },
          ),
        );
      },
    );
  }

  Widget _buildCategoryCard(
    GalleryCategory category,
    GalleryAdminProvider provider,
    ColorScheme colors,
  ) {
    final theme = Theme.of(context);
    final images = provider.imagesByCategory[category.id] ?? [];
    final isProcessing = provider.isProcessingCategory(category.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colors.outline.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Category Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surfaceVariant.withOpacity(0.3),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    category.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (isProcessing)
                  const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                PopupMenuButton<String>(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit Category'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete Category'),
                    ),
                  ],
                  onSelected: (value) async {
                    if (value == 'edit') {
                      await _showEditCategoryDialog(category);
                    } else if (value == 'delete') {
                      await _showDeleteCategoryDialog(category);
                    }
                  },
                  icon: Icon(
                    Icons.more_vert,
                    color: SchoolColors.darkText.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          
          // Images Grid
          if (images.isNotEmpty) _buildImagesGrid(images, provider, category.id),
          
          // Add Images Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: isProcessing ? null : () => _showUploadImagesDialog(category.id),
              icon: const Icon(Icons.add_photo_alternate_outlined, size: 20),
              label: const Text('Add Images'),
              style: ElevatedButton.styleFrom(
                backgroundColor: SchoolColors.secondary2,
                foregroundColor: colors.onSurfaceVariant,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesGrid(
    List<GalleryImage> images,
    GalleryAdminProvider provider,
    String categoryId,
  ) {
    final theme = Theme.of(context);
    final colors = SchoolColors.of(context);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = (constraints.maxWidth / 150).floor().clamp(2, 4);
        final itemSize = (constraints.maxWidth - 32 - ((crossAxisCount - 1) * 8)) / crossAxisCount;
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: images.length,
          itemBuilder: (context, index) {
            final image = images[index];
            final isProcessing = provider.isProcessingImage(image.id);
            
            return Stack(
              fit: StackFit.expand,
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: image.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: colors.surfaceVariant,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: colors.errorContainer,
                      child: const Icon(Icons.broken_image),
                    ),
                  ),
                ),
                
                // Processing Overlay
                if (isProcessing)
                  Container(
                    decoration: BoxDecoration(
                      color: SchoolColors.darkText.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                
                // Hover Actions
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        // Show image in full screen
                        _showImagePreview(image);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: colors.primary.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Delete Button
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.errorContainer.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      color: colors.onErrorContainer,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: isProcessing
                          ? null
                          : () => _showDeleteImageDialog(image, categoryId),
                      tooltip: 'Delete Image',
                    ),
                  ),
                ),
                
                // Featured Badge
                if (image.isFeatured)
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Featured',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showAddCategoryDialog() async {
    final result = await showDialog<GalleryCategory?>(
      context: context,
      builder: (context) => const CategoryFormDialog(),
    );
    
    if (result != null && mounted) {
      final provider = context.read<GalleryAdminProvider>();
      await provider.addCategory(result);
    }
  }

  Future<void> _showEditCategoryDialog(GalleryCategory category) async {
    final result = await showDialog<GalleryCategory?>(
      context: context,
      builder: (context) => CategoryFormDialog(category: category),
    );
    
    if (result != null && mounted) {
      final provider = context.read<GalleryAdminProvider>();
      await provider.updateCategory(category.id, result);
    }
  }

  Future<void> _showDeleteCategoryDialog(GalleryCategory category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Delete Category',
        message: 'Are you sure you want to delete "${category.name}"? This will also delete all images in this category.',
        confirmText: 'Delete',
        cancelText: 'Cancel',
        isDestructiveAction: true,
        onConfirm: () {
          Navigator.of(context).pop(true);
        },
      ),
    );
    
    if (confirmed == true && mounted) {
      final provider = context.read<GalleryAdminProvider>();
      await provider.deleteCategory(category.id);
    }
  }

  Future<void> _showUploadImagesDialog(String categoryId) async {
    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (context) => ImageUploadDialog(categoryId: categoryId),
    );
    
    if (result != null && mounted) {
      final provider = context.read<GalleryAdminProvider>();
      final files = result['files'] as List<PlatformFile>;
      final isFeatured = result['isFeatured'] as bool;
      
      await provider.uploadImages(
        categoryId: categoryId,
        files: files,
        isFeatured: isFeatured,
      );
    }
  }

  Future<void> _showDeleteImageDialog(GalleryImage image, String categoryId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Delete Image',
        message: 'Are you sure you want to delete this image?',
        confirmText: 'Delete',
        cancelText: 'Cancel',
        isDestructiveAction: true,
        onConfirm: () {
          Navigator.of(context).pop(true);
        },
      ),
    );
    
    if (confirmed == true && mounted) {
      final provider = context.read<GalleryAdminProvider>();
      await provider.deleteImage(image.id, categoryId);
    }
  }

  void _showImagePreview(GalleryImage image) {
    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: Stack(
          children: [
            // Fullscreen Image
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: image.imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
            
            // Close Button
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            
            // Image Info
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black87,
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (image.title?.isNotEmpty ?? false)
                      Text(
                        image.title!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (image.description?.isNotEmpty ?? false)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          image.description!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      'Uploaded: ${_formatDate(image.createdAt)}',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _errorSubscription?.cancel();
    _loadingSubscription?.cancel();
    _provider?.dispose();
    _isInitialized = false;
    _isLoading = false;
    _error = null;
    
    super.dispose();
  }
}
