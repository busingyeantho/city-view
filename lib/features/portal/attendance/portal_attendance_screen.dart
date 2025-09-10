import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/auth/auth_controller.dart';

class PortalAttendanceScreen extends StatefulWidget {
  final String? classFilter;
  const PortalAttendanceScreen({super.key, this.classFilter});

  @override
  State<PortalAttendanceScreen> createState() => _PortalAttendanceScreenState();
}

class _PortalAttendanceScreenState extends State<PortalAttendanceScreen> {
  DateTime _from = DateTime.now().subtract(const Duration(days: 30));
  DateTime _to = DateTime.now();

  Query<Map<String, dynamic>> _query(String? className) {
    var q = FirebaseFirestore.instance.collection('attendance').orderBy('date', descending: true);
    q = q.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(_from));
    q = q.where('date', isLessThanOrEqualTo: Timestamp.fromDate(_to));
    final effectiveClass = widget.classFilter;
    if ((effectiveClass != null && effectiveClass.isNotEmpty) || (className != null && className.isNotEmpty)) {
      q = q.where('className', isEqualTo: effectiveClass?.isNotEmpty == true ? effectiveClass : className);
    }
    return q.limit(200);
  }

  Future<void> _pickRange() async {
    final r = await showDateRangePicker(context: context, firstDate: DateTime(2020), lastDate: DateTime.now().add(const Duration(days: 365)), initialDateRange: DateTimeRange(start: _from, end: _to));
    if (r != null) setState(() { _from = r.start; _to = r.end; });
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthController>().user?.uid;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        actions: [
          TextButton.icon(onPressed: _pickRange, icon: const Icon(Icons.date_range), label: const Text('Date Range')),
          const SizedBox(width: 8),
        ],
      ),
      body: uid == null
          ? const Center(child: Text('Please sign in'))
          : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          final className = snapshot.data?.data()?['className'] as String?;
          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _query(className).snapshots(),
            builder: (context, attSnap) {
              if (attSnap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (attSnap.hasError) return Center(child: Text('Error: ${attSnap.error}'));
              final docs = attSnap.data?.docs ?? [];
              if (docs.isEmpty) return const Center(child: Text('No attendance records for selected range'));
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
          );
        },
      ),
    );
  }
}


