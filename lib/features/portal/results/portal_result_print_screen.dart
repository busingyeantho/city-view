import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;

class PortalResultPrintScreen extends StatelessWidget {
  final String resultId;
  const PortalResultPrintScreen({super.key, required this.resultId});

  Future<DocumentSnapshot<Map<String, dynamic>>> _load() {
    return FirebaseFirestore.instance.collection('results').doc(resultId).get();
  }

  void _print() {
    if (kIsWeb) {
      try {
        html.window.print();
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: _load(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(body: Center(child: Text('Result not found')));
        }
        final m = snapshot.data!.data()!;
        final rawSubjects = m['subjects'];
        final Map<String, dynamic> subjects = rawSubjects is Map
            ? Map<String, dynamic>.from(rawSubjects)
            : <String, dynamic>{};
        return Scaffold(
          appBar: AppBar(
            title: const Text('Print Result'),
            actions: [
              TextButton.icon(onPressed: _print, icon: const Icon(Icons.print), label: const Text('Print')),
              const SizedBox(width: 8),
            ],
          ),
          body: Center(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('City View Nursery and Primary School', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text('Report Card', style: Theme.of(context).textTheme.titleMedium),
                  const Divider(height: 24),
                  Wrap(spacing: 24, runSpacing: 8, children: [
                    Text('Student: ${m['studentName'] ?? ''}'),
                    Text('Class: ${m['className'] ?? ''}'),
                    Text('Term: ${m['term'] ?? ''}'),
                    Text('Session: ${m['session'] ?? ''}'),
                  ]),
                  const SizedBox(height: 16),
                  Table(
                    border: TableBorder.all(color: Colors.grey.shade300),
                    columnWidths: const {
                      0: FlexColumnWidth(3),
                      1: FlexColumnWidth(1),
                    },
                    children: [
                      const TableRow(children: [
                        Padding(padding: EdgeInsets.all(8), child: Text('Subject', style: TextStyle(fontWeight: FontWeight.bold))),
                        Padding(padding: EdgeInsets.all(8), child: Text('Score', style: TextStyle(fontWeight: FontWeight.bold))),
                      ]),
                      ...subjects.entries.map((e) => TableRow(children: [
                            Padding(padding: const EdgeInsets.all(8), child: Text(e.key)),
                            Padding(padding: const EdgeInsets.all(8), child: Text('${e.value}')),
                          ])),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(onPressed: _print, icon: const Icon(Icons.print), label: const Text('Print')),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}


