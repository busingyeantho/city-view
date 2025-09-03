import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../shared/ui/responsive_scaffold.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final doc = FirebaseFirestore.instance.collection('pages').doc('achievements');
    return ResponsiveScaffold(
      title: 'Achievements',
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: doc.snapshots(),
        builder: (context, snapshot) {
          final data = snapshot.data?.data() ?? {};
          final publishedRaw = data['published'] ?? {};
          final published = Map<String, dynamic>.from(publishedRaw as Map);
          final body = (published['body'] ?? 'Our student and school achievements.') as String;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: SelectableText(body),
            ),
          );
        },
      ),
    );
  }
}


