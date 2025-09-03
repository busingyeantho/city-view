import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AcademicsBodyEditor extends StatefulWidget {
  final DocumentReference<Map<String, dynamic>> docRef;
  const AcademicsBodyEditor({required this.docRef});

  @override
  State<AcademicsBodyEditor> createState() => _AcademicsBodyEditorState();
}

class _AcademicsBodyEditorState extends State<AcademicsBodyEditor> {
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
            hintText: 'Describe academic programs, curriculum, facilities...',
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
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Academics draft saved')));
              }
            },
            child: const Text('Save Academics Draft'),
          ),
        )
      ],
    );
  }
}


