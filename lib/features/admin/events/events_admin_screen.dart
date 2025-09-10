import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventsAdminScreen extends StatefulWidget {
  const EventsAdminScreen({super.key});

  @override
  State<EventsAdminScreen> createState() => _EventsAdminScreenState();
}

class _EventsAdminScreenState extends State<EventsAdminScreen> {
  Future<void> _openEditor([DocumentSnapshot<Map<String, dynamic>>? doc]) async {
    await showDialog(
      context: context,
      builder: (context) => _EventEditorDialog(doc: doc),
    );
  }

  Query<Map<String, dynamic>> _query() {
    return FirebaseFirestore.instance
        .collection('events')
        .orderBy('startDate', descending: true);
  }

  Future<void> _delete(String id) async {
    await FirebaseFirestore.instance.collection('events').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Events'),
        actions: [
          TextButton.icon(
            onPressed: () => _openEditor(),
            icon: const Icon(Icons.add),
            label: const Text('New Event'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _query().snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load events: ${snapshot.error}'));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) return const Center(child: Text('No events yet'));
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final d = docs[index];
              final data = d.data();
              final title = (data['title'] ?? '') as String;
              final start = (data['startDate'] as Timestamp?)?.toDate();
              final location = (data['location'] ?? '') as String;
              return Card(
                child: ListTile(
                  title: Text(title),
                  subtitle: Text('${start?.toLocal() ?? ''}${location.isNotEmpty ? ' · $location' : ''}'),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      IconButton(onPressed: () => _openEditor(d), icon: const Icon(Icons.edit)),
                      IconButton(onPressed: () => _delete(d.id), icon: const Icon(Icons.delete), color: Colors.red),
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

class _EventEditorDialog extends StatefulWidget {
  final DocumentSnapshot<Map<String, dynamic>>? doc;
  const _EventEditorDialog({this.doc});

  @override
  State<_EventEditorDialog> createState() => _EventEditorDialogState();
}

class _EventEditorDialogState extends State<_EventEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    final data = widget.doc?.data();
    if (data != null) {
      _titleCtrl.text = (data['title'] ?? '').toString();
      _descCtrl.text = (data['description'] ?? '').toString();
      _locationCtrl.text = (data['location'] ?? '').toString();
      _startDate = (data['startDate'] as Timestamp?)?.toDate();
      _endDate = (data['endDate'] as Timestamp?)?.toDate();
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final base = isStart ? (_startDate ?? now) : (_endDate ?? _startDate ?? now);
    final picked = await showDatePicker(context: context, firstDate: DateTime(now.year - 1), lastDate: DateTime(now.year + 5), initialDate: base);
    if (picked == null) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(base));
    final dt = DateTime(picked.year, picked.month, picked.day, time?.hour ?? 0, time?.minute ?? 0);
    setState(() {
      if (isStart) {
        _startDate = dt;
      } else {
        _endDate = dt;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final data = {
      'title': _titleCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'location': _locationCtrl.text.trim(),
      'startDate': _startDate != null ? Timestamp.fromDate(_startDate!) : null,
      'endDate': _endDate != null ? Timestamp.fromDate(_endDate!) : null,
      'updatedAt': FieldValue.serverTimestamp(),
    }..removeWhere((key, value) => value == null);
    final col = FirebaseFirestore.instance.collection('events');
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
      title: Text(widget.doc == null ? 'New Event' : 'Edit Event'),
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
                controller: _locationCtrl,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickDate(isStart: true),
                      icon: const Icon(Icons.event),
                      label: Text(_startDate == null ? 'Pick start' : 'Start: ${_startDate!.toLocal()}'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickDate(isStart: false),
                      icon: const Icon(Icons.event),
                      label: Text(_endDate == null ? 'Pick end' : 'End: ${_endDate!.toLocal()}'),
                    ),
                  ),
                ],
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


