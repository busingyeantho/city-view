import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../models/gallery_category.dart';

class CategoryFormDialog extends StatefulWidget {
  final GalleryCategory? category;

  const CategoryFormDialog({
    Key? key,
    this.category,
  }) : super(key: key);

  @override
  State<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late int _order;
  bool _isActive = true;
  String? _coverImageUrl;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.category?.description ?? '',
    );
    _order = widget.category?.order ?? 0;
    _isActive = widget.category?.isActive ?? true;
    _coverImageUrl = widget.category?.coverImageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() => _isLoading = true);
        
        // Upload the image to Firebase Storage
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('gallery_categories')
            .child('${const Uuid().v4()}.jpg');
        
        final uploadTask = await storageRef.putData(
          await image.readAsBytes(),
          SettableMetadata(contentType: 'image/jpeg'),
        );
        
        final downloadUrl = await uploadTask.ref.getDownloadURL();
        
        if (mounted) {
          setState(() {
            _coverImageUrl = downloadUrl;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to upload image: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final category = GalleryCategory(
        id: widget.category?.id ?? '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        coverImageUrl: _coverImageUrl,
        order: _order,
        isActive: _isActive,
        createdAt: widget.category?.createdAt,
        updatedAt: DateTime.now(),
      );
      
      Navigator.of(context).pop(category);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = Theme.of(context).colorScheme;
    
    return AlertDialog(
      title: Text(
        widget.category == null ? 'Add Category' : 'Edit Category',
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cover Image
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: colors.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colors.outline.withOpacity(0.3),
                      width: 1,
                    ),
                    image: _coverImageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(_coverImageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _coverImageUrl == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: 40,
                                  color: colors.onSurfaceVariant,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Add Cover Image',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            )
                          : null,
                ),
              ),
              const SizedBox(height: 16),
              
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a category name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              
              // Order Field
              TextFormField(
                initialValue: _order.toString(),
                decoration: const InputDecoration(
                  labelText: 'Display Order',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.sort),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _order = int.tryParse(value) ?? 0;
                },
              ),
              const SizedBox(height: 8),
              
              // Active Toggle
              Row(
                children: [
                  Switch(
                    value: _isActive,
                    onChanged: (value) {
                      setState(() {
                        _isActive = value;
                      });
                    },
                    activeColor: colors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Active',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              
              // Error Message
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.error,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
