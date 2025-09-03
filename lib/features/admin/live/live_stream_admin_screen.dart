import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/ui/responsive_scaffold.dart';

class LiveStreamAdminScreen extends StatefulWidget {
  const LiveStreamAdminScreen({super.key});

  @override
  State<LiveStreamAdminScreen> createState() => _LiveStreamAdminScreenState();
}

class _LiveStreamAdminScreenState extends State<LiveStreamAdminScreen> {
  final urlCtl = TextEditingController();
  bool isActive = false;

  @override
  void dispose() {
    urlCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doc = FirebaseFirestore.instance.collection('settings').doc('live');
    return ResponsiveScaffold(
      title: 'Live Stream Admin',
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: doc.snapshots(),
          builder: (context, snapshot) {
            final data = snapshot.data?.data() ?? {};
            if (!snapshot.hasError && snapshot.hasData) {
              urlCtl.text = data['url'] ?? urlCtl.text;
              isActive = (data['isActive'] ?? false) as bool;
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: urlCtl,
                  decoration: const InputDecoration(labelText: 'Stream URL or Embed Code'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Switch(value: isActive, onChanged: (v) => setState(() => isActive = v)),
                    const SizedBox(width: 8),
                    const Text('Active'),
                  ],
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () async {
                    await doc.set({'url': urlCtl.text.trim(), 'isActive': isActive, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}


