import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../models/page_data.dart';
import '../providers/page_provider.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/error_display.dart';

class PageEditorScreen extends StatefulWidget {
  final String? pageId;

  const PageEditorScreen({super.key, this.pageId});

  @override
  State<PageEditorScreen> createState() => _PageEditorScreenState();
}

class _PageEditorScreenState extends State<PageEditorScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  late PageData _page;
  bool _isNewPage = true;
  bool _isSaving = false;
  bool _hasChanges = false;

  // Form controllers
  final _titleController = TextEditingController();
  final _slugController = TextEditingController();
  final _seoDescriptionController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _isNewPage = widget.pageId == null;
    _initializePage();
  }

  Future<void> _initializePage() async {
    if (!_isNewPage) {
      try {
        final page = await context.read<PageProvider>().getPage(widget.pageId!);
        if (mounted) {
          setState(() {
            _page = page;
            _updateControllers();
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to load page: $e')));
        }
      }
    } else {
      setState(() {
        _page = PageData(
          id: '',
          title: '',
          slug: '',
          content: {},
          isPublished: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      });
    }
  }

  void _updateControllers() {
    _titleController.text = _page.title;
    _slugController.text = _page.slug;
    _seoDescriptionController.text = _page.seoDescription ?? '';
    _contentController.text = _page.content['text'] ?? '';
  }

  Future<void> _savePage({bool publish = false}) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final updatedPage = _page.copyWith(
        title: _titleController.text.trim(),
        slug: _slugController.text.trim().toLowerCase().replaceAll(' ', '-'),
        seoDescription: _seoDescriptionController.text.trim(),
        content: {..._page.content, 'text': _contentController.text.trim()},
        isPublished: publish ? true : _page.isPublished,
        updatedAt: DateTime.now(),
      );

      await context.read<PageProvider>().savePage(
        updatedPage,
        publish: publish,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isNewPage ? 'Page created!' : 'Page updated!'),
          ),
        );

        if (_isNewPage) {
          context.go('/admin/pages');
        } else {
          setState(() {
            _page = updatedPage;
            _hasChanges = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save page: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final shouldPop = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Discard changes?'),
            content: const Text(
              'You have unsaved changes. Are you sure you want to discard them?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'DISCARD',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    return shouldPop ?? false;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _slugController.dispose();
    _seoDescriptionController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isNewPage ? 'New Page' : 'Edit Page'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.article), text: 'Content'),
              Tab(icon: Icon(Icons.image), text: 'Hero Image'),
              Tab(icon: Icon(Icons.settings), text: 'Settings'),
            ],
          ),
        ),
        body: Form(
          key: _formKey,
          onChanged: _onFieldChanged,
          child: TabBarView(
            controller: _tabController,
            children: [
              // Content Tab
              _buildContentTab(),
              // Hero Image Tab
              _buildHeroImageTab(),
              // Settings Tab
              _buildSettingsTab(),
            ],
          ),
        ),
        floatingActionButton:
            _isSaving
                ? const FloatingActionButton(
                  onPressed: null,
                  child: CircularProgressIndicator(),
                )
                : FloatingActionButton.extended(
                  onPressed: _savePage,
                  icon: const Icon(Icons.save),
                  label: const Text('SAVE DRAFT'),
                ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        bottomNavigationBar: _buildBottomAppBar(),
      ),
    );
  }

  Widget _buildContentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Page Title',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a title';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _contentController,
            maxLines: 20,
            decoration: const InputDecoration(
              labelText: 'Content',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          // TODO: Add rich text editor integration
        ],
      ),
    );
  }

  Widget _buildHeroImageTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_page.heroImageUrl != null)
            Image.network(_page.heroImageUrl!, height: 200, fit: BoxFit.cover)
          else
            const Icon(Icons.image, size: 100, color: Colors.grey),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement image picker
            },
            icon: const Icon(Icons.upload),
            label: const Text('Upload Hero Image'),
          ),
          if (_page.heroImageUrl != null) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                // TODO: Implement remove image
              },
              child: const Text(
                'Remove Image',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _slugController,
            decoration: const InputDecoration(
              labelText: 'URL Slug',
              helperText: 'The URL-friendly version of the title',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a slug';
              }
              if (!RegExp(r'^[a-z0-9-]+$').hasMatch(value)) {
                return 'Slug can only contain lowercase letters, numbers, and hyphens';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _seoDescriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'SEO Description',
              helperText: 'A brief description for search engines',
              border: OutlineInputBorder(),
            ),
            maxLength: 160,
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Published'),
            subtitle: Text(
              _page.isPublished
                  ? 'This page is visible to the public'
                  : 'This page is only visible to admins',
            ),
            value: _page.isPublished,
            onChanged: (value) {
              setState(() {
                _page = _page.copyWith(isPublished: value);
                _hasChanges = true;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAppBar() {
    return BottomAppBar(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed:
                  _isSaving
                      ? null
                      : () {
                        if (_formKey.currentState!.validate()) {
                          _savePage(publish: true);
                        }
                      },
              icon: const Icon(Icons.publish),
              label: const Text('PUBLISH'),
            ),
            if (!_isNewPage) ...[
              TextButton.icon(
                onPressed:
                    _isSaving
                        ? null
                        : () {
                          // TODO: Show page preview
                        },
                icon: const Icon(Icons.remove_red_eye),
                label: const Text('PREVIEW'),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed:
                    _isSaving
                        ? null
                        : () {
                          // TODO: Show delete confirmation
                        },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
