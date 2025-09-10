import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SimpleBodyEditor extends StatefulWidget {
  final DocumentReference<Map<String, dynamic>> docRef;
  final String field;
  final String saveLabel;

  const SimpleBodyEditor({
    super.key,
    required this.docRef,
    required this.field,
    required this.saveLabel,
  });

  @override
  State<SimpleBodyEditor> createState() => _SimpleBodyEditorState();
}

class _SimpleBodyEditorState extends State<SimpleBodyEditor> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      final doc = await widget.docRef.get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          final draft = data['draft'] as Map<String, dynamic>? ?? {};
          setState(() {
            _controller.text = draft[widget.field]?.toString() ?? '';
            _isLoading = false;
          });
          return;
        }
      }
      setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load content: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveContent() async {
    try {
      await widget.docRef.update({
        'draft.${widget.field}': _controller.text,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Content saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save content: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          maxLines: 10,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Content',
            hintText: 'Enter your content here...',
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _saveContent,
          child: Text(widget.saveLabel),
        ),
      ],
    );
  }
}
