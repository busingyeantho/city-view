import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import '../../../../shared/ui/responsive_scaffold.dart';
import '../providers/users_provider.dart';

class UsersAdminScreen extends StatelessWidget {
  const UsersAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UsersProvider()..initialize(),
      child: const _UsersAdminScreenContent(),
    );
  }
}

class _UsersAdminScreenContent extends StatefulWidget {
  const _UsersAdminScreenContent();

  @override
  State<_UsersAdminScreenContent> createState() => _UsersAdminScreenContentState();
}

class _UsersAdminScreenContentState extends State<_UsersAdminScreenContent> {
  final _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _roleController = TextEditingController();
  final _scrollController = ScrollController();
  
  String _selectedRole = 'all';
  bool _showAddUserForm = false;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _roleController.dispose();
    _scrollController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.9) {
      context.read<UsersProvider>().loadMoreUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'User Management',
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            controller: _scrollController,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
                minWidth: constraints.maxWidth,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildFilterSection(),
                    if (_showAddUserForm) ..._buildAddUserForm(),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _buildUsersList(),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users by email...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<UsersProvider>().searchUsers('');
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                _searchDebounce?.cancel();
                _searchDebounce = Timer(const Duration(milliseconds: 300), () {
                  context.read<UsersProvider>().searchUsers(value);
                });
              },
            ),
          ),
          const SizedBox(width: 16),
          FilledButton.icon(
            onPressed: () {
              setState(() {
                _showAddUserForm = !_showAddUserForm;
                if (!_showAddUserForm) {
                  _emailController.clear();
                  _passwordController.clear();
                  _roleController.clear();
                  _selectedRole = 'all';
                }
              });
              if (_showAddUserForm) {
                FocusScope.of(context).unfocus();
              }
            },
            icon: Icon(_showAddUserForm ? Icons.close : Icons.person_add),
            label: Text(_showAddUserForm ? 'Cancel' : 'Add User'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Consumer<UsersProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              const Text('Filter by role: '),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _selectedRole,
                items: [
                  const DropdownMenuItem<String>(
                    value: 'all',
                    child: Text('All Roles'),
                  ),
                  ...UsersProvider.availableRoles.map<DropdownMenuItem<String>>((role) {
                    return DropdownMenuItem<String>(
                      value: role['value'] as String,
                      child: Text(role['label'] as String),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedRole = value);
                    provider.filterByRole(value == 'all' ? '' : value);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildAddUserForm() {
    return [
      Card(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Add New User',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedRole == 'all' ? null : _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                  ),
                  items: UsersProvider.availableRoles
                      .map<DropdownMenuItem<String>>((role) {
                    return DropdownMenuItem<String>(
                      value: role['value'] as String,
                      child: Text(role['label'] as String),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedRole = value);
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a role';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Consumer<UsersProvider>(
                  builder: (context, provider, _) {
                    return ElevatedButton(
                      onPressed: provider.isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState?.validate() ?? false) {
                                final success = await provider.createUser(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text,
                                  role: _selectedRole,
                                );

                                if (success && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('User created successfully'),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  setState(() {
                                    _showAddUserForm = false;
                                    _emailController.clear();
                                    _passwordController.clear();
                                    _selectedRole = 'all';
                                  });
                                }
                              }
                            },
                      child: provider.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Create User'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(height: 16),
    ];
  }

  Widget _buildUsersList() {
    return Consumer<UsersProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.users.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error: ${provider.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: provider.initialize,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (provider.users.isEmpty) {
          return const Center(
            child: Text('No users found'),
          );
        }

        return ListView.builder(
          itemCount: provider.users.length + (provider.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= provider.users.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final user = provider.users[index];
            return _buildUserTile(user, provider);
          },
        );
      },
    );
  }

  Widget _buildUserTile(Map<String, dynamic> user, UsersProvider provider) {
    final role = user['role'] ?? 'user';
    final email = user['email'] ?? 'No email';
    final userId = user['id'] as String?;
    final isCurrentUser = provider.currentUserId == userId;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        title: Text(email),
        subtitle: Text(role),
        trailing: isCurrentUser
            ? const Text('Current User')
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showEditRoleDialog(user, provider),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteConfirmation(user, provider),
                  ),
                ],
              ),
      ),
    );
  }

  void _showEditRoleDialog(Map<String, dynamic> user, UsersProvider provider) {
    final userId = user['id'] as String?;
    String? selectedRole = user['role'] as String?;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit User Role'),
        content: DropdownButtonFormField<String>(
          value: selectedRole,
          decoration: const InputDecoration(labelText: 'Role'),
          items: UsersProvider.availableRoles
              .map<DropdownMenuItem<String>>((role) {
            return DropdownMenuItem<String>(
              value: role['value'] as String,
              child: Text(role['label'] as String),
            );
          }).toList(),
          onChanged: (value) => selectedRole = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (selectedRole != null && userId != null) {
                await provider.updateUserRole(userId, selectedRole!);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('User role updated'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> user, UsersProvider provider) {
    final userId = user['id'] as String?;
    final email = user['email'] ?? 'this user';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete $email? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (userId != null) {
                final success = await provider.deleteUser(userId);
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('User deleted successfully'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
