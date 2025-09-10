import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../shared/ui/responsive_scaffold.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  Query<Map<String, dynamic>> _query() {
    return FirebaseFirestore.instance
        .collection('events')
        .where('startDate', isGreaterThan: DateTime.now().subtract(const Duration(days: 1)))
        .orderBy('startDate', descending: false);
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Events',
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
          if (docs.isEmpty) {
            return const Center(child: Text('No upcoming events'));
          }
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  ...docs.map((doc) {
                    final data = doc.data();
                    final title = (data['title'] ?? '') as String;
                    final description = (data['description'] ?? '') as String;
                    final start = (data['startDate'] as Timestamp?)?.toDate();
                    final end = (data['endDate'] as Timestamp?)?.toDate();
                    final location = (data['location'] ?? '') as String;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 8),
                            if (start != null)
                              Text('${start.toLocal()}${end != null ? ' - ${end.toLocal()}' : ''}'),
                            if (location.isNotEmpty) Text(location),
                            if (description.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(description),
                            ],
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('RSVP coming soon')),
                                    );
                                  },
                                  icon: const Icon(Icons.event_available),
                                  label: const Text('RSVP'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


