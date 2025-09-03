import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../../shared/ui/responsive_scaffold.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameCtl = TextEditingController();
    final emailCtl = TextEditingController();
    final subjectCtl = TextEditingController();
    final messageCtl = TextEditingController();
    return ResponsiveScaffold(
      title: 'Contact',
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(controller: nameCtl, decoration: const InputDecoration(labelText: 'Name'), validator: (v) => (v==null||v.isEmpty)?'Required':null),
            TextFormField(controller: emailCtl, decoration: const InputDecoration(labelText: 'Email'), validator: (v){
              if (v==null||v.isEmpty) return 'Required';
              final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v);
              return ok?null:'Invalid email';
            }),
            TextFormField(controller: subjectCtl, decoration: const InputDecoration(labelText: 'Subject'), validator: (v)=> (v==null||v.isEmpty)?'Required':null),
            TextFormField(controller: messageCtl, decoration: const InputDecoration(labelText: 'Message'), maxLines: 6, validator: (v)=> (v==null||v.isEmpty)?'Required':null),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final callable = FirebaseFunctions.instance.httpsCallable('sendContactEmail');
                  callable.call({
                    'name': nameCtl.text.trim(),
                    'email': emailCtl.text.trim(),
                    'subject': subjectCtl.text.trim(),
                    'message': messageCtl.text.trim(),
                  }).then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Message sent')));
                    nameCtl.clear(); emailCtl.clear(); subjectCtl.clear(); messageCtl.clear();
                  }).catchError((e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
                  });
                }
              },
              child: const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }
}


