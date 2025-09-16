import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import '../providers/gallery_admin_provider.dart';
import '../../models/gallery_category.dart';
import '../../../shared/widgets/loading_indicator.dart';

class ImageUploadDialog extends StatefulWidget {
  final String categoryId;

  const ImageUploadDialog({
    Key? key,
    required this.categoryId,
  }) : super(key: key);

  @override
  State<ImageUploadDialog> createState() => _ImageUploadDialogState();
}

class _ImageUploadDialogState extends State<ImageUploadDialog> {
  final List<PlatformFile> _selectedFiles = [];
  final Map<String, TextEditingController> _descriptionControllers = {};
  final Map<String, TextEditingController> _titleControllers = {};
  bool _isFeatured = false;
  bool _isUploading = false;
  String? _error;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.categoryId;
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (final controller in _descriptionControllers.values) {
      controller.dispose();
    }
    for (final controller in _titleControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: true, // Load file data for preview
      );

      if (result != null) {
        setState(() {
          // Add new files that aren't already selected
          for (final file in result.files) {
            if (!_selectedFiles.any((f) => f.name == file.name)) {
              _selectedFiles.add(file);
              _descriptionControllers[file.name] = TextEditingController();
              _titleControllers[file.name] = TextEditingController(
                text: file.name.split('.').first.replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), ' ').trim(),
              );
            }
          }
          _error = null;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to select images: $e';
      });
    }
  }

  void _removeFile(PlatformFile file) {
    setState(() {
      _selectedFiles.removeWhere((f) => f.name == file.name);
      _descriptionControllers[file.name]?.dispose();
      _descriptionControllers.remove(file.name);
      _titleControllers[file.name]?.dispose();
      _titleControllers.remove(file.name);
    });
  }

  Future<void> _uploadImages() async {
    if (_selectedFiles.isEmpty) {
      setState(() {
        _error = 'Please select at least one image to upload';
      });
      return;
    }

    if (_selectedCategoryId == null) {
      setState(() {
        _error = 'Please select a category';
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _error = null;
    });

    try {
      final provider = context.read<GalleryAdminProvider>();
      
      // Convert to format expected by the provider
      final files = _selectedFiles.map((file) => file).toList();
      
      // Add titles and descriptions to files if available
      final filesWithMetadata = files.map((file) {
        final title = _titleControllers[file.name]?.text.trim();
        final description = _descriptionControllers[file.name]?.text.trim();
        
        // Create a copy of the file with metadata in the name
        // This is a simple way to pass metadata, but you might want to use a different approach
        final newFile = file;
        newFile.name = '${title ?? ''}|||${description ?? ''}|||${file.name}';
        return newFile;
      }).toList();
      
      await provider.uploadImages(
        categoryId: _selectedCategoryId!,
        files: filesWithMetadata,
        isFeatured: _isFeatured,
      );
      
      if (mounted) {
        Navigator.of(context).pop({
          'files': files,
          'isFeatured': _isFeatured,
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to upload images: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Widget _buildImagePreview(PlatformFile file) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image preview with remove button
          Stack(
            children: [
              // Image preview
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: colors.surfaceVariant.withOpacity(0.3),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  image: file.bytes != null
                      ? DecorationImage(
                          image: MemoryImage(file.bytes!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: file.bytes == null
                    ? const Center(child: Icon(Icons.broken_image, size: 48))
                    : null,
              ),
              
              // Remove button
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.errorContainer.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    color: colors.onErrorContainer,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: _isUploading ? null : () => _removeFile(file),
                    tooltip: 'Remove',
                  ),
                ),
              ),
            ],
          ),
          
          // Image title and description
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                TextFormField(
                  controller: _titleControllers[file.name],
                  decoration: const InputDecoration(
                    labelText: 'Image Title',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    isDense: true,
                  ),
                  style: theme.textTheme.bodyMedium,
                  enabled: !_isUploading,
                ),
                const SizedBox(height: 8),
                
                // Description
                TextFormField(
                  controller: _descriptionControllers[file.name],
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    isDense: true,
                  ),
                  maxLines: 2,
                  style: theme.textTheme.bodySmall,
                  enabled: !_isUploading,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final provider = context.watch<GalleryAdminProvider>();
    
    return AlertDialog(
      title: const Text('Upload Images'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Category Selection
            if (widget.categoryId.isEmpty) ...[  // Only show category selector if not pre-selected
              const Text('Select Category:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: colors.outline),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategoryId,
                    isExpanded: true,
                    hint: const Text('Select a category'),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('Select a category'),
                      ),
                      ...provider.categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category.id,
                          child: Text(category.name),
                        );
                      }).toList(),
                    ],
                    onChanged: _isUploading
                        ? null
                        : (value) {
                            setState(() {
                              _selectedCategoryId = value;
                            });
                          },
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Featured Toggle
            Row(
              children: [
                Checkbox(
                  value: _isFeatured,
                  onChanged: _isUploading
                      ? null
                      : (value) {
                          setState(() {
                            _isFeatured = value ?? false;
                          });
                        },
                  activeColor: colors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Mark as featured',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: 'Featured images will be highlighted in the gallery',
                  child: Icon(
                    Icons.help_outline,
                    size: 18,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            
            // Selected Files
            if (_selectedFiles.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Selected Images (${_selectedFiles.length}):',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._selectedFiles.map((file) => _buildImagePreview(file)).toList(),
            ],
            
            // Error Message
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.errorContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: colors.onErrorContainer),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Add More Button
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _isUploading ? null : _pickImages,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: Text(_selectedFiles.isEmpty ? 'Select Images' : 'Add More Images'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isUploading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isUploading || _selectedFiles.isEmpty ? null : _uploadImages,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
          ),
          child: _isUploading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Upload Images'),
        ),
      ],
    );
  }
}
