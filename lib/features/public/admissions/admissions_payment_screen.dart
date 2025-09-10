import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AdmissionsPaymentScreen extends StatefulWidget {
  final String admissionId;
  const AdmissionsPaymentScreen({super.key, required this.admissionId});

  @override
  State<AdmissionsPaymentScreen> createState() => _AdmissionsPaymentScreenState();
}

class _AdmissionsPaymentScreenState extends State<AdmissionsPaymentScreen> {
  bool _loading = true;
  Map<String, dynamic>? _admission;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final doc = await FirebaseFirestore.instance.collection('admissions').doc(widget.admissionId).get();
    if (mounted) {
      setState(() {
        _admission = doc.data();
        _loading = false;
      });
    }
  }

  Future<void> _markPaid() async {
    await FirebaseFirestore.instance.collection('admissions').doc(widget.admissionId).update({
      'paymentStatus': 'paid',
      'amount': 0,
      'paidAt': FieldValue.serverTimestamp(),
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment recorded (demo).')));
  }

  Future<void> _startPayment() async {
    try {
      final fn = FirebaseFunctions.instance.httpsCallable('initiateAdmissionPayment');
      final resp = await fn.call({
        'admissionId': widget.admissionId,
        'email': (_admission?['email'] ?? '').toString(),
        'amount': (_admission?['amount'] ?? 0) as num,
      });
      final data = (resp.data as Map).cast<String, dynamic>();
      final url = data['authorization_url']?.toString();
      if (url != null && url.isNotEmpty) {
        final uri = Uri.parse(url);
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment init failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final a = _admission ?? {};
    return Scaffold(
      appBar: AppBar(title: const Text('Admissions Payment')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Applicant: ${a['studentName'] ?? ''}'),
                  Text('Parent: ${a['parentName'] ?? ''}'),
                  Text('Class: ${a['gradeApplied'] ?? ''}'),
                  const SizedBox(height: 12),
                  Text('Payment Status: ${a['paymentStatus'] ?? 'unpaid'}'),
                  const SizedBox(height: 16),
                  Wrap(spacing: 12, children: [
                    ElevatedButton.icon(onPressed: _startPayment, icon: const Icon(Icons.payment), label: const Text('Pay with Paystack')),
                    OutlinedButton.icon(onPressed: _markPaid, icon: const Icon(Icons.check), label: const Text('Mark as Paid (Demo)')),
                    OutlinedButton.icon(onPressed: _load, icon: const Icon(Icons.refresh), label: const Text('Refresh')),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


