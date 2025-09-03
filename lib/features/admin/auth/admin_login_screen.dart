import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/auth/auth_controller.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtl = TextEditingController();
  final _passwordCtl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtl.dispose();
    _passwordCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    if (auth.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/admin'));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Login')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _emailCtl,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (v) => (v==null||v.isEmpty)?'Required':null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordCtl,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (v) => (v==null||v.isEmpty)?'Required':null,
                  ),
                  const SizedBox(height: 12),
                  if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _loading ? null : () async {
                      if (!_formKey.currentState!.validate()) return;
                      setState(() { _loading = true; _error = null; });
                      try {
                        await auth.signIn(_emailCtl.text.trim(), _passwordCtl.text);
                        if (mounted) context.go('/admin');
                      } catch (e) {
                        setState(() { _error = 'Login failed: $e'; });
                      } finally {
                        if (mounted) setState(() { _loading = false; });
                      }
                    },
                    child: _loading ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Sign In'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


