import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../shared/ui/responsive_scaffold.dart';

class UsersAdminScreen extends StatefulWidget {
  const UsersAdminScreen({super.key});

  @override
  State<UsersAdminScreen> createState() => _UsersAdminScreenState();
}

class _UsersAdminScreenState extends State<UsersAdminScreen> {
  final _emailCtl = TextEditingController();
  String _role = 'blogger';

  @override
  void dispose() {
    _emailCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final users = FirebaseFirestore.instance.collection('users').orderBy('email');
    return ResponsiveScaffold(
      title: 'Users',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 280,
                  child: TextField(
                    controller: _emailCtl,
                    decoration: const InputDecoration(hintText: 'user@example.com', labelText: 'Email'),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _role,
                  items: const [
                    DropdownMenuItem(value: 'super_admin', child: Text('Super Admin')),
                    DropdownMenuItem(value: 'content_manager', child: Text('Content Manager')),
                    DropdownMenuItem(value: 'blogger', child: Text('Blogger')),
                  ],
                  onChanged: (v) => setState(() => _role = v ?? 'blogger'),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: () async {
                    final email = _emailCtl.text.trim();
                    if (email.isEmpty) return;
                    // Stub: create or update user doc with role. Actual account creation via Firebase Console or Function.
                    final doc = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: email).limit(1).get();
                    if (doc.docs.isNotEmpty) {
                      await doc.docs.first.reference.update({'role': _role});
                    } else {
                      await FirebaseFirestore.instance.collection('users').add({'email': email, 'role': _role});
                    }
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User saved')));
                      _emailCtl.clear();
                      setState(() => _role = 'blogger');
                    }
                  },
                  child: const Text('Save'),
                )
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: users.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data?.docs ?? [];
                  return ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final d = docs[i].data();
                      return ListTile(
                        title: Text(d['email'] ?? ''),
                        subtitle: Text(d['role'] ?? ''),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}


