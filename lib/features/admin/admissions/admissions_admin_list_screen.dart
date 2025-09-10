import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdmissionsAdminListScreen extends StatefulWidget {
  const AdmissionsAdminListScreen({super.key});

  @override
  State<AdmissionsAdminListScreen> createState() => _AdmissionsAdminListScreenState();
}

class _AdmissionsAdminListScreenState extends State<AdmissionsAdminListScreen> {
  final _searchCtrl = TextEditingController();
  String _statusFilter = 'all';

  Query<Map<String, dynamic>> _baseQuery() {
    Query<Map<String, dynamic>> q = FirebaseFirestore.instance
        .collection('admissions')
        .orderBy('createdAt', descending: true);
    if (_statusFilter != 'all') {
      q = q.where('status', isEqualTo: _statusFilter);
    }
    return q;
  }

  Future<void> _updateStatus(String docId, String status) async {
    await FirebaseFirestore.instance.collection('admissions').doc(docId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated to $status')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admissions Applications'),
        actions: [
          SizedBox(
            width: 280,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: TextField(
                controller: _searchCtrl,
                decoration: const InputDecoration(
                  hintText: 'Search name, parent, email, phone',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),
          DropdownButtonHideUnderline(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: DropdownButton<String>(
                value: _statusFilter,
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All')),
                  DropdownMenuItem(value: 'submitted', child: Text('Submitted')),
                  DropdownMenuItem(value: 'reviewing', child: Text('Reviewing')),
                  DropdownMenuItem(value: 'accepted', child: Text('Accepted')),
                  DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                ],
                onChanged: (v) => setState(() => _statusFilter = v ?? 'all'),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _baseQuery().snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(height: 8),
                  const Text('Failed to load applications'),
                  const SizedBox(height: 8),
                  Text('${snapshot.error}', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            );
          }
          final docs = snapshot.data?.docs ?? [];
          final query = _searchCtrl.text.trim().toLowerCase();
          final filtered = docs.where((d) {
            if (query.isEmpty) return true;
            final m = d.data();
            final hay = [
              (m['studentName'] ?? '').toString().toLowerCase(),
              (m['parentName'] ?? '').toString().toLowerCase(),
              (m['email'] ?? '').toString().toLowerCase(),
              (m['phone'] ?? '').toString().toLowerCase(),
            ].join(' ');
            return hay.contains(query);
          }).toList();

          if (filtered.isEmpty) {
            return const Center(child: Text('No applications found'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final doc = filtered[index];
              final data = doc.data();
              final status = (data['status'] ?? 'submitted') as String;
              return Card(
                child: ListTile(
                  title: Text('${data['studentName'] ?? ''} — ${data['gradeApplied'] ?? ''}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Parent/Guardian: ${data['parentName'] ?? ''}'),
                      Text('Email: ${data['email'] ?? ''}  |  Phone: ${data['phone'] ?? ''}'),
                      if ((data['message'] ?? '').toString().isNotEmpty) Text('Note: ${data['message']}'),
                      Text('Status: $status'),
                      Text('Payment: ${(data['paymentStatus'] ?? 'unpaid')}  |  Amount: ${(data['amount'] ?? 0)}'),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) => _updateStatus(doc.id, v),
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'submitted', child: Text('Mark Submitted')),
                      PopupMenuItem(value: 'reviewing', child: Text('Mark Reviewing')),
                      PopupMenuItem(value: 'accepted', child: Text('Mark Accepted')),
                      PopupMenuItem(value: 'rejected', child: Text('Mark Rejected')),
                    ],
                    child: const Icon(Icons.more_vert),
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


