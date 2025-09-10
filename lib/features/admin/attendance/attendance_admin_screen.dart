import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AttendanceAdminScreen extends StatefulWidget {
  const AttendanceAdminScreen({super.key});

  @override
  State<AttendanceAdminScreen> createState() => _AttendanceAdminScreenState();
}

class _AttendanceAdminScreenState extends State<AttendanceAdminScreen> {
  final _classCtrl = TextEditingController();
  final _studentCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  String _status = 'present';

  Query<Map<String, dynamic>> _query() => FirebaseFirestore.instance
      .collection('attendance')
      .orderBy('date', descending: true)
      .limit(100);

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(context: context, firstDate: DateTime(now.year - 1), lastDate: DateTime(now.year + 1), initialDate: _date);
    if (d != null) setState(() => _date = d);
  }

  Future<void> _add() async {
    if (_classCtrl.text.trim().isEmpty || _studentCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Class and student are required')));
      return;
    }
    await FirebaseFirestore.instance.collection('attendance').add({
      'className': _classCtrl.text.trim(),
      'studentName': _studentCtrl.text.trim(),
      'status': _status,
      'date': Timestamp.fromDate(_date),
      'createdAt': FieldValue.serverTimestamp(),
    });
    _studentCtrl.clear();
  }

  @override
  void dispose() {
    _classCtrl.dispose();
    _studentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Attendance')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 220,
                  child: TextField(
                    controller: _classCtrl,
                    decoration: const InputDecoration(labelText: 'Class', border: OutlineInputBorder()),
                  ),
                ),
                SizedBox(
                  width: 260,
                  child: TextField(
                    controller: _studentCtrl,
                    decoration: const InputDecoration(labelText: 'Student Name', border: OutlineInputBorder()),
                  ),
                ),
                DropdownButton<String>(
                  value: _status,
                  items: const [
                    DropdownMenuItem(value: 'present', child: Text('Present')),
                    DropdownMenuItem(value: 'absent', child: Text('Absent')),
                    DropdownMenuItem(value: 'late', child: Text('Late')),
                  ],
                  onChanged: (v) => setState(() => _status = v ?? 'present'),
                ),
                OutlinedButton.icon(onPressed: _pickDate, icon: const Icon(Icons.event), label: Text('Date: ${_date.toLocal().toString().split(' ').first}')),
                ElevatedButton.icon(onPressed: _add, icon: const Icon(Icons.add), label: const Text('Add')),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _query().snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) return const Center(child: Text('No records yet'));
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final m = docs[i].data();
                    return Card(
                      child: ListTile(
                        title: Text('${m['studentName'] ?? ''} — ${m['className'] ?? ''}'),
                        subtitle: Text('Date: ${(m['date'] as Timestamp?)?.toDate().toLocal().toString().split(' ').first} · ${m['status'] ?? ''}'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


