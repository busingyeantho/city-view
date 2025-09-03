import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AboutBodyEditor extends StatefulWidget {
  final DocumentReference<Map<String, dynamic>> docRef;
  const AboutBodyEditor({required this.docRef});

  @override
  State<AboutBodyEditor> createState() => _AboutBodyEditorState();
}

class _AboutBodyEditorState extends State<AboutBodyEditor> {
  final ctl = TextEditingController();

  @override
  void dispose() {
    ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: ctl,
          maxLines: 10,
          decoration: const InputDecoration(
            hintText: 'Write the About page body here...',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton(
            onPressed: () async {
              await widget.docRef.set({
                'draft': {
                  'body': ctl.text.trim(),
                }
              }, SetOptions(merge: true));
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('About draft saved')));
              }
            },
            child: const Text('Save About Draft'),
          ),
        )
      ],
    );
  }
}


