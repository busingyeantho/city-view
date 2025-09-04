import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import '../../../shared/ui/responsive_scaffold.dart';
import '../../../shared/widgets/image_placeholder.dart';

class BlogEditorScreen extends StatefulWidget {
  const BlogEditorScreen({super.key});

  @override
  State<BlogEditorScreen> createState() => _BlogEditorScreenState();
}

class _BlogEditorScreenState extends State<BlogEditorScreen> {
  late QuillController _controller;
  final titleCtl = TextEditingController();
  final excerptCtl = TextEditingController();
  final metaTitleCtl = TextEditingController();
  final metaDescCtl = TextEditingController();
  final tagsCtl = TextEditingController();
  String? _coverUrl;
  String? _coverPath;
  bool _saving = false;
  bool _loading = true;
  bool _isEditing = false;
  String? _originalSlug;

  @override
  void initState() {
    super.initState();
    _controller = QuillController.basic();
    _loadIfEditing();
  }

  @override
  void dispose() {
    _controller.dispose();
    titleCtl.dispose();
    excerptCtl.dispose();
    metaTitleCtl.dispose();
    metaDescCtl.dispose();
    tagsCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Blog Editor',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                FilledButton(
                  onPressed: _saving ? null : () async {
                    setState(() => _saving = true);
                    try {
                      final delta = _controller.document.toDelta().toJson();
                      final slug = _isEditing ? (_originalSlug ?? _slugify(titleCtl.text)) : _slugify(titleCtl.text);
                      if (!_isEditing) {
                        final exists = await FirebaseFirestore.instance.collection('blogPosts').doc(slug).get();
                        if (exists.exists) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Slug already exists. Change the title.')));
                          }
                          return;
                        }
                      }
                      final now = FieldValue.serverTimestamp();
                      final doc = FirebaseFirestore.instance.collection('blogPosts').doc(slug);
                      await doc.set({
                        'title': titleCtl.text.trim(),
                        'slug': slug,
                        'excerpt': excerptCtl.text.trim(),
                        'contentDelta': delta,
                        'coverImage': _coverUrl,
                        'coverPath': _coverPath,
                        'tags': tagsCtl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
                        'metaTitle': metaTitleCtl.text.trim().isEmpty ? null : metaTitleCtl.text.trim(),
                        'metaDescription': metaDescCtl.text.trim().isEmpty ? null : metaDescCtl.text.trim(),
                        'status': 'draft',
                        'updatedAt': now,
                        'createdAt': now,
                      }, SetOptions(merge: true));
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Draft saved')));
                    } catch (e) {
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
                    } finally {
                      if (mounted) setState(() => _saving = false);
                    }
                  },
                  child: _saving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save Draft'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () async {
                    final slug = _slugify(titleCtl.text);
                    await FirebaseFirestore.instance.collection('blogPosts').doc(slug).set({
                      'status': 'published',
                      'publishedAt': FieldValue.serverTimestamp(),
                    }, SetOptions(merge: true));
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Published')));
                  },
                  child: const Text('Publish'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                if (_loading) const LinearProgressIndicator(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          TextField(controller: titleCtl, decoration: const InputDecoration(labelText: 'Title')),
                          const SizedBox(height: 8),
                          TextField(controller: excerptCtl, decoration: const InputDecoration(labelText: 'Excerpt')),
                          const SizedBox(height: 8),
                          ImagePlaceholder(
                            imageUrl: _coverUrl,
                            storagePathPrefix: 'images/blog/',
                            onUploaded: (url) => setState(() => _coverUrl = url),
                            onUploadedPath: (p) => setState(() => _coverPath = p),
                          ),
                          const SizedBox(height: 8),
                          QuillToolbar.simple(controller: _controller),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Theme.of(context).dividerColor),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: QuillEditor.basic(controller: _controller, configurations: const QuillEditorConfigurations()),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          TextField(controller: tagsCtl, decoration: const InputDecoration(labelText: 'Tags (comma-separated)')),
                          const SizedBox(height: 8),
                          TextField(controller: metaTitleCtl, decoration: const InputDecoration(labelText: 'Meta Title')),
                          const SizedBox(height: 8),
                          TextField(controller: metaDescCtl, decoration: const InputDecoration(labelText: 'Meta Description')),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _slugify(String input) {
    final lower = input.trim().toLowerCase();
    final dashed = lower.replaceAll(RegExp("[^a-z0-9]+"), '-');
    final collapsed = dashed.replaceAll(RegExp(r'-+'), '-');
    return collapsed.replaceAll(RegExp(r'^-+'), '').replaceAll(RegExp(r'-+$'), '');
  }

  Future<void> _loadIfEditing() async {
    try {
      final slugParam = Uri.base.queryParameters['slug'];
      if (slugParam == null || slugParam.isEmpty) {
        setState(() => _loading = false);
        return;
      }
      _isEditing = true;
      _originalSlug = slugParam;
      final doc = await FirebaseFirestore.instance.collection('blogPosts').doc(slugParam).get();
      if (!doc.exists) {
        setState(() => _loading = false);
        return;
      }
      final data = doc.data() as Map<String, dynamic>;
      titleCtl.text = (data['title'] ?? '').toString();
      excerptCtl.text = (data['excerpt'] ?? '').toString();
      metaTitleCtl.text = (data['metaTitle'] ?? '').toString();
      metaDescCtl.text = (data['metaDescription'] ?? '').toString();
      final tags = (data['tags'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();
      tagsCtl.text = tags.join(', ');
      _coverUrl = (data['coverImage'] ?? '').toString().isEmpty ? null : data['coverImage'] as String?;
      _coverPath = (data['coverPath'] ?? '').toString().isEmpty ? null : data['coverPath'] as String?;
      final delta = data['contentDelta'];
      if (delta != null) {
        try {
          final newDoc = Document.fromJson(List<Map<String, dynamic>>.from(delta as List));
          _controller.dispose();
          _controller = QuillController(document: newDoc, selection: const TextSelection.collapsed(offset: 0));
          if (mounted) setState(() {});
        } catch (_) {
          // ignore invalid delta, keep basic controller
        }
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}


