import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/auth/auth_controller.dart';
import 'package:go_router/go_router.dart';

class PortalResultsScreen extends StatelessWidget {
  const PortalResultsScreen({super.key});

  Query<Map<String, dynamic>> _query(String uid) {
    return FirebaseFirestore.instance
        .collection('results')
        .where('studentUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(50);
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthController>().user?.uid;
    return Scaffold(
      appBar: AppBar(title: const Text('Results / Report Cards')),
      body: uid == null
          ? const Center(child: Text('Please sign in'))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _query(uid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) return const Center(child: Text('No results available'));
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final m = docs[i].data();
                    final rawSubjects = m['subjects'];
                    final Map<String, dynamic> subjects = rawSubjects is Map
                        ? Map<String, dynamic>.from(rawSubjects)
                        : <String, dynamic>{};
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${m['className'] ?? ''} — ${m['term'] ?? ''} (${m['session'] ?? ''})', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            ...subjects.entries.map((e) => Text('${e.key}: ${e.value}')),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: OutlinedButton.icon(
                                onPressed: () => context.go('/portal/results/${docs[i].id}/print'),
                                icon: const Icon(Icons.print),
                                label: const Text('Print'),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}


