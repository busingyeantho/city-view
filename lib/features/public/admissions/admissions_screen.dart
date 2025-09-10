import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../shared/ui/responsive_scaffold.dart';

class AdmissionsScreen extends StatefulWidget {
  const AdmissionsScreen({super.key});

  @override
  State<AdmissionsScreen> createState() => _AdmissionsScreenState();
}

class _AdmissionsScreenState extends State<AdmissionsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _studentNameCtrl = TextEditingController();
  final _parentNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _gradeCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  bool _submitting = false;
  String? _submittedId;

  @override
  void dispose() {
    _studentNameCtrl.dispose();
    _parentNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _gradeCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final data = {
        'studentName': _studentNameCtrl.text.trim(),
        'parentName': _parentNameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'gradeApplied': _gradeCtrl.text.trim(),
        'message': _messageCtrl.text.trim(),
        'status': 'submitted',
        'paymentStatus': 'unpaid',
        'amount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      };
      final doc = await FirebaseFirestore.instance.collection('admissions').add(data);
      setState(() => _submittedId = doc.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application submitted successfully')),
        );
        _formKey.currentState!.reset();
        _studentNameCtrl.clear();
        _parentNameCtrl.clear();
        _emailCtrl.clear();
        _phoneCtrl.clear();
        _gradeCtrl.clear();
        _messageCtrl.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Admissions',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Card(
              margin: const EdgeInsets.all(8),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Apply for Admission',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          SizedBox(
                            width: 380,
                            child: TextFormField(
                              controller: _studentNameCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Student Full Name',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                            ),
                          ),
                          SizedBox(
                            width: 380,
                            child: TextFormField(
                              controller: _parentNameCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Parent/Guardian Name',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                            ),
                          ),
                          SizedBox(
                            width: 380,
                            child: TextFormField(
                              controller: _emailCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Required';
                                final ok = RegExp(r'^.+@.+\..+$').hasMatch(v.trim());
                                return ok ? null : 'Enter a valid email';
                              },
                            ),
                          ),
                          SizedBox(
                            width: 380,
                            child: TextFormField(
                              controller: _phoneCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Phone Number',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.phone,
                              validator: (v) => (v == null || v.trim().length < 7) ? 'Enter a valid phone' : null,
                            ),
                          ),
                          SizedBox(
                            width: 380,
                            child: TextFormField(
                              controller: _gradeCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Class Applying To',
                                hintText: 'e.g., Nursery 1, Primary 3',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                            ),
                          ),
                          SizedBox(
                            width: 780,
                            child: TextFormField(
                              controller: _messageCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Additional Information (optional)',
                                border: OutlineInputBorder(),
                              ),
                              minLines: 3,
                              maxLines: 6,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _submitting ? null : _submit,
                          icon: _submitting
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.send),
                          label: Text(_submitting ? 'Submitting…' : 'Submit Application'),
                        ),
                      ),
                      if (_submittedId != null) ...[
                        const SizedBox(height: 12),
                        Text('Reference ID: $_submittedId', style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => Navigator.of(context).pushNamed('/admissions/pay/$_submittedId'),
                              icon: const Icon(Icons.payment),
                              label: const Text('Proceed to Payment'),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


