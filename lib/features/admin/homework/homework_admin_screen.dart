import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeworkAdminScreen extends StatefulWidget {
  const HomeworkAdminScreen({super.key});

  @override
  State<HomeworkAdminScreen> createState() => _HomeworkAdminScreenState();
}

class _HomeworkAdminScreenState extends State<HomeworkAdminScreen> {
  Future<void> _openEditor([DocumentSnapshot<Map<String, dynamic>>? doc]) async {
    await showDialog(context: context, builder: (_) => _HomeworkEditorDialog(doc: doc));
  }

  Query<Map<String, dynamic>> _query() => FirebaseFirestore.instance.collection('homework').orderBy('dueDate', descending: true);

  Future<void> _delete(String id) async {
    await FirebaseFirestore.instance.collection('homework').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Homework'),
        actions: [
          TextButton.icon(onPressed: () => _openEditor(), icon: const Icon(Icons.add), label: const Text('New')),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _query().snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) return const Center(child: Text('No homework yet'));
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final d = docs[i];
              final m = d.data();
              return Card(
                child: ListTile(
                  title: Text(m['title'] ?? ''),
                  subtitle: Text('Class: ${m['className'] ?? ''} · Due: ${(m['dueDate'] as Timestamp?)?.toDate().toLocal()}'),
                  trailing: Wrap(spacing: 8, children: [
                    IconButton(onPressed: () => _openEditor(d), icon: const Icon(Icons.edit)),
                    IconButton(onPressed: () => _delete(d.id), icon: const Icon(Icons.delete), color: Colors.red),
                  ]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _HomeworkEditorDialog extends StatefulWidget {
  final DocumentSnapshot<Map<String, dynamic>>? doc;
  const _HomeworkEditorDialog({this.doc});

  @override
  State<_HomeworkEditorDialog> createState() => _HomeworkEditorDialogState();
}

class _HomeworkEditorDialogState extends State<_HomeworkEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _classCtrl = TextEditingController();
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    final m = widget.doc?.data();
    if (m != null) {
      _titleCtrl.text = (m['title'] ?? '').toString();
      _descCtrl.text = (m['description'] ?? '').toString();
      _classCtrl.text = (m['className'] ?? '').toString();
      _dueDate = (m['dueDate'] as Timestamp?)?.toDate();
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _classCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDue() async {
    final now = DateTime.now();
    final base = _dueDate ?? now.add(const Duration(days: 1));
    final d = await showDatePicker(context: context, firstDate: now, lastDate: DateTime(now.year + 5), initialDate: base);
    if (d == null) return;
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(base));
    setState(() => _dueDate = DateTime(d.year, d.month, d.day, t?.hour ?? 0, t?.minute ?? 0));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final data = {
      'title': _titleCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'className': _classCtrl.text.trim(),
      'dueDate': _dueDate != null ? Timestamp.fromDate(_dueDate!) : null,
      'updatedAt': FieldValue.serverTimestamp(),
    }..removeWhere((k, v) => v == null);
    final col = FirebaseFirestore.instance.collection('homework');
    if (widget.doc == null) {
      await col.add({...data, 'createdAt': FieldValue.serverTimestamp()});
    } else {
      await col.doc(widget.doc!.id).update(data);
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.doc == null ? 'New Homework' : 'Edit Homework'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
                minLines: 2,
                maxLines: 4,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _classCtrl,
                decoration: const InputDecoration(labelText: 'Class (e.g., Primary 3)'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: _pickDue,
                  icon: const Icon(Icons.event),
                  label: Text(_dueDate == null ? 'Pick due date' : 'Due: ${_dueDate!.toLocal()}'),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}


