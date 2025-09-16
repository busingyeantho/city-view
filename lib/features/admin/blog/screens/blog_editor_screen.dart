import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';

class BlogEditorScreen extends StatefulWidget {
  const BlogEditorScreen({super.key});

  @override
  State<BlogEditorScreen> createState() => _BlogEditorScreenState();
}

class _BlogEditorScreenState extends State<BlogEditorScreen> {
  late final QuillController _quillController;
  final titleCtl = TextEditingController();
  final excerptCtl = TextEditingController();
  final metaTitleCtl = TextEditingController();
  final metaDescCtl = TextEditingController();
  final tagsCtl = TextEditingController();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _quillController = QuillController.basic();
  }
  

  // Convert Quill document to plain text for excerpt if empty
  String _getPlainText() {
    return _quillController.document.toPlainText();
  }

  // Image upload functionality will be added later

  @override
  void dispose() {
    _quillController.dispose();
    titleCtl.dispose();
    excerptCtl.dispose();
    metaTitleCtl.dispose();
    metaDescCtl.dispose();
    tagsCtl.dispose();
    super.dispose();
  }

  Future<void> _savePost({required String status}) async {
    if (titleCtl.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please enter a title')));
      }
      return;
    }

    try {
      // If excerpt is empty, use first 200 chars of content
      final excerpt =
          excerptCtl.text.isNotEmpty
              ? excerptCtl.text
              : _getPlainText().substring(
                0,
                _getPlainText().length > 200 ? 200 : _getPlainText().length,
              );

      await FirebaseFirestore.instance.collection('blogPosts').add({
        'title': titleCtl.text,
        'excerpt': excerpt,
        'content': jsonEncode(_quillController.document.toDelta().toJson()),
        'contentPlain': _getPlainText(),
        'status': status,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        if (context.mounted) {
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving post: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Blog Editor')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: titleCtl,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: excerptCtl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Excerpt',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Content',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Divider(),
                  if (_isUploading) const LinearProgressIndicator(),
                  Container(
                    height: 300,
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: QuillEditor(
                      controller: _quillController,
                      scrollController: ScrollController(),
                      focusNode: FocusNode(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _savePost(status: 'draft'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Save as Draft'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _savePost(status: 'published'),
                    child: const Text('Publish'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
