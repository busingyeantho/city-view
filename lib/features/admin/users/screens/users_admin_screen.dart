import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import '../../../shared/ui/responsive_scaffold.dart';
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
  final _scrollController = ScrollController();
  String _selectedRole = 'blogger';
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
    _scrollController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
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
                    const SizedBox(height: 16),
                    if (_showAddUserForm) _buildAddUserForm(),
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
                // Debounce search to avoid too many requests
                _searchDebounce?.cancel();
                _searchDebounce = Timer(const Duration(milliseconds: 500), () {
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
                  _selectedRole = 'blogger';
                }
              });
              // Close keyboard when showing form
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
                    setState(() {
                      _selectedRole = value;
                    });
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

  Widget _buildAddUserForm() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  if (!RegExp(r'^[^@]+@[^\s]+\.[^\s]+$').hasMatch(value)) {
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
                  prefixIcon: Icon(Icons.lock),
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
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.people),
                ),
                items: UsersProvider.availableRoles.map((role) {
                  return DropdownMenuItem(
                    value: role['value'],
                    child: Text(role['label']),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedRole = value;
                    });
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
                  return SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: provider.isLoading
                          ? null
                          : () => _handleAddUser(provider),
                      child: provider.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Create User'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsersList() {
    return Consumer<UsersProvider>(
      builder: (context, provider, _) {
        if (provider.error != null) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${provider.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.refreshUsers(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (provider.isLoading && provider.users.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.users.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No users found. Try adjusting your search or filters.'),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.refreshUsers(),
          child: NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification is ScrollEndNotification &&
                  _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
                provider.loadMoreUsers();
              }
              return true;
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: _scrollController,
              shrinkWrap: true,
              itemCount: provider.hasMoreUsers 
                  ? provider.users.length + 1 
                  : provider.users.length,
              itemBuilder: (context, index) {
                if (index >= provider.users.length) {
                  return provider.isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : const SizedBox.shrink();
                }
                final user = provider.users[index];
                return _buildUserCard(user);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            user['email']?.toString().substring(0, 1).toUpperCase() ?? '?',
            style: TextStyle(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          user['email'] ?? 'No email',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          user['roleLabel'] ?? user['role'] ?? 'No role',
          style: TextStyle(
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleUserAction(value, user),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit Role'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'copy_email',
              child: const Row(
                children: [
                  Icon(Icons.copy, size: 20),
                  SizedBox(width: 8),
                  Text('Copy Email'),
                ],
              ),
              onTap: () {
                final email = user['email']?.toString() ?? '';
                if (email.isNotEmpty) {
                  Clipboard.setData(ClipboardData(text: email));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Email copied to clipboard')),
                  );
                }
              },
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Delete User',
                    style: TextStyle(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleUserAction(String action, Map<String, dynamic> user) async {
    switch (action) {
      case 'edit':
        _showEditRoleDialog(user);
        break;
      case 'delete':
        _showDeleteConfirmation(context, user);
        break;
      case 'copy_email':
        // Handled in the onTap of the PopupMenuItem
        break;
    }
  }

  Future<void> _showEditRoleDialog(Map<String, dynamic> user) async {
    String newRole = user['role'] ?? 'user';
    final currentRoleLabel = user['roleLabel'] ?? user['role'] ?? 'User';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit User Role'),
          icon: const Icon(Icons.admin_panel_settings, size: 36),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current role: $currentRoleLabel',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              const Text('Select a new role:'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: newRole,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                isExpanded: true,
                items: UsersProvider.availableRoles
                    .map((role) => DropdownMenuItem(
                          value: role['value'],
                          child: Text(role['label']),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => newRole = value);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Update Role'),
            ),
          ],
        ),
      ),
    );

    if (result != true || newRole == user['role']) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final provider = context.read<UsersProvider>();
    
    try {
      await provider.updateUserRole(user['id'], newRole);
      if (mounted) {
        final newRoleLabel = UsersProvider.getRoleLabel(newRole);
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Updated role to $newRoleLabel'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                provider.updateUserRole(user['id'], user['role']);
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _showDeleteConfirmation(
      BuildContext context, Map<String, dynamic> user) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete User'),
            icon: const Icon(Icons.warning_amber_rounded, size: 40, color: Colors.orange),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are you sure you want to delete ${user['email']}?',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This will permanently delete the user account and cannot be undone.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                  foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete User'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final provider = context.read<UsersProvider>();
    
    try {
      await provider.deleteUser(user['id']);
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('User ${user['email']} deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                // TODO: Implement undo functionality if needed
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Failed to delete user: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _handleAddUser(UsersProvider provider) async {
    if (_formKey.currentState?.validate() != true) return;
    
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      await provider.createUser(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole,
      );
      
      if (mounted) {
        setState(() {
          _showAddUserForm = false;
          _emailController.clear();
          _passwordController.clear();
          _selectedRole = 'blogger';
        });
        
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('User created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Failed to create user: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Unknown date';
    
    DateTime date;
    if (timestamp is Timestamp) {
      date = timestamp.toDate();
    } else if (timestamp is DateTime) {
      date = timestamp;
    } else {
      return 'Invalid date';
    }
    
    return '${date.day}/${date.month}/${date.year}';
  }
}
