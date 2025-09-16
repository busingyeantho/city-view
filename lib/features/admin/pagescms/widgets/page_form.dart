import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/page_data.dart';
import '../providers/page_provider.dart';

class PageForm extends StatefulWidget {
  final PageData? initialData;
  final Function(PageData) onSubmit;
  final bool isEditing;

  const PageForm({
    super.key,
    this.initialData,
    required this.onSubmit,
    this.isEditing = false,
  });

  @override
  State<PageForm> createState() => _PageFormState();
}

class _PageFormState extends State<PageForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _slugController;
  late TextEditingController _seoDescriptionController;
  late TextEditingController _contentController;
  late bool _isPublished;
  String? _heroImageUrl;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialData?.title ?? '');
    _slugController = TextEditingController(text: widget.initialData?.slug ?? '');
    _seoDescriptionController = TextEditingController(
      text: widget.initialData?.seoDescription ?? '',
    );
    _contentController = TextEditingController(
      text: widget.initialData?.content['content'] ?? '',
    );
    _isPublished = widget.initialData?.isPublished ?? false;
    _heroImageUrl = widget.initialData?.heroImageUrl;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _slugController.dispose();
    _seoDescriptionController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final pageData = PageData(
        id: widget.initialData?.id ?? '',
        title: _titleController.text,
        slug: _slugController.text,
        content: {'content': _contentController.text},
        seoDescription: _seoDescriptionController.text.isEmpty
            ? null
            : _seoDescriptionController.text,
        heroImageUrl: _heroImageUrl,
        isPublished: _isPublished,
        createdAt: widget.initialData?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: widget.initialData?.createdBy,
        updatedBy: 'current_user_id', // Replace with actual user ID
      );

      widget.onSubmit(pageData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _slugController,
              decoration: const InputDecoration(
                labelText: 'Slug',
                hintText: 'page-url-slug',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a URL slug';
                }
                if (value.contains(' ')) {
                  return 'Slug cannot contain spaces';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _seoDescriptionController,
              decoration: const InputDecoration(
                labelText: 'SEO Description (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 10,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some content';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Published'),
              value: _isPublished,
              onChanged: (value) {
                setState(() {
                  _isPublished = value;
                });
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                widget.isEditing ? 'Update Page' : 'Create Page',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
