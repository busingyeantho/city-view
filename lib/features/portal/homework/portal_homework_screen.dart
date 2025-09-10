import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/auth/auth_controller.dart';

class PortalHomeworkScreen extends StatelessWidget {
  final String? classFilter;
  const PortalHomeworkScreen({super.key, this.classFilter});

  Query<Map<String, dynamic>> _query(String? className) {
    var q = FirebaseFirestore.instance.collection('homework').orderBy('dueDate', descending: false);
    if (className != null && className.isNotEmpty) {
      q = q.where('className', isEqualTo: className);
    }
    return q;
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthController>().user?.uid;
    return Scaffold(
      appBar: AppBar(title: const Text('Homework')),
      body: uid == null
          ? const Center(child: Text('Please sign in'))
          : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          final className = classFilter ?? snapshot.data?.data()?['className'] as String?;
          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _query(className).snapshots(),
            builder: (context, hwSnap) {
              if (hwSnap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (hwSnap.hasError) return Center(child: Text('Error: ${hwSnap.error}'));
              final docs = hwSnap.data?.docs ?? [];
              if (docs.isEmpty) return const Center(child: Text('No homework'));
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final m = docs[i].data();
                  return Card(
                    child: ListTile(
                      title: Text(m['title'] ?? ''),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Class: ${m['className'] ?? ''}'),
                          Text('Due: ${(m['dueDate'] as Timestamp?)?.toDate().toLocal()}'),
                          if ((m['description'] ?? '').toString().isNotEmpty) Text(m['description']),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}


