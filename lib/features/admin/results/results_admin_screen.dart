import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ResultsAdminScreen extends StatefulWidget {
  const ResultsAdminScreen({super.key});

  @override
  State<ResultsAdminScreen> createState() => _ResultsAdminScreenState();
}

class _ResultsAdminScreenState extends State<ResultsAdminScreen> {
  Future<void> _openEditor([DocumentSnapshot<Map<String, dynamic>>? doc]) async {
    await showDialog(context: context, builder: (_) => _ResultEditorDialog(doc: doc));
  }

  Query<Map<String, dynamic>> _query() => FirebaseFirestore.instance
      .collection('results')
      .orderBy('createdAt', descending: true)
      .limit(100);

  Future<void> _delete(String id) async {
    await FirebaseFirestore.instance.collection('results').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Results / Report Cards'),
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
          if (docs.isEmpty) return const Center(child: Text('No results yet'));
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final d = docs[i];
              final m = d.data();
              return Card(
                child: ListTile(
                  title: Text('${m['studentName'] ?? ''} — ${m['className'] ?? ''}'),
                  subtitle: Text('Term: ${m['term'] ?? ''} · Session: ${m['session'] ?? ''}'),
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

class _ResultEditorDialog extends StatefulWidget {
  final DocumentSnapshot<Map<String, dynamic>>? doc;
  const _ResultEditorDialog({this.doc});

  @override
  State<_ResultEditorDialog> createState() => _ResultEditorDialogState();
}

class _ResultEditorDialogState extends State<_ResultEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _studentUidCtrl = TextEditingController();
  final _studentNameCtrl = TextEditingController();
  final _classCtrl = TextEditingController();
  final _termCtrl = TextEditingController();
  final _sessionCtrl = TextEditingController();
  final _subjectsCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final m = widget.doc?.data();
    if (m != null) {
      _studentUidCtrl.text = (m['studentUid'] ?? '').toString();
      _studentNameCtrl.text = (m['studentName'] ?? '').toString();
      _classCtrl.text = (m['className'] ?? '').toString();
      _termCtrl.text = (m['term'] ?? '').toString();
      _sessionCtrl.text = (m['session'] ?? '').toString();
      final subjects = (m['subjects'] as Map<String, dynamic>? ?? {});
      _subjectsCtrl.text = subjects.entries.map((e) => '${e.key}: ${e.value}').join('\n');
    }
  }

  @override
  void dispose() {
    _studentUidCtrl.dispose();
    _studentNameCtrl.dispose();
    _classCtrl.dispose();
    _termCtrl.dispose();
    _sessionCtrl.dispose();
    _subjectsCtrl.dispose();
    super.dispose();
  }

  Map<String, dynamic> _parseSubjects(String input) {
    final Map<String, dynamic> res = {};
    for (final line in input.split('\n')) {
      final t = line.trim();
      if (t.isEmpty) continue;
      final parts = t.split(':');
      if (parts.length >= 2) {
        final subject = parts[0].trim();
        final scoreStr = parts.sublist(1).join(':').trim();
        final score = double.tryParse(scoreStr) ?? scoreStr;
        res[subject] = score;
      }
    }
    return res;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final data = {
      'studentUid': _studentUidCtrl.text.trim(),
      'studentName': _studentNameCtrl.text.trim(),
      'className': _classCtrl.text.trim(),
      'term': _termCtrl.text.trim(),
      'session': _sessionCtrl.text.trim(),
      'subjects': _parseSubjects(_subjectsCtrl.text),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    final col = FirebaseFirestore.instance.collection('results');
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
      title: Text(widget.doc == null ? 'New Result' : 'Edit Result'),
      content: SizedBox(
        width: 560,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _studentUidCtrl,
                  decoration: const InputDecoration(labelText: 'Student UID'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _studentNameCtrl,
                  decoration: const InputDecoration(labelText: 'Student Name'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _classCtrl,
                  decoration: const InputDecoration(labelText: 'Class'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _termCtrl,
                        decoration: const InputDecoration(labelText: 'Term (e.g., Term 1)'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _sessionCtrl,
                        decoration: const InputDecoration(labelText: 'Session (e.g., 2024/2025)'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _subjectsCtrl,
                  minLines: 6,
                  maxLines: 10,
                  decoration: const InputDecoration(
                    labelText: 'Subjects (one per line: Subject: Score)',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
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


