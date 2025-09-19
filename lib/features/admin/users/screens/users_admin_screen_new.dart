import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter/widgets.dart';
import '../../../../shared/ui/responsive_scaffold.dart';
import '../providers/users_provider.dart';

// Add these constants for form validation
const _kMinPasswordLength = 8;
const _kEmailRegex = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}\$';

// Add this extension for string capitalization
extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}

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
  State<_UsersAdminScreenContent> createState() =>
      _UsersAdminScreenContentState();
}

class _UsersAdminScreenContentState extends State<_UsersAdminScreenContent> {
  final _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _roleController = TextEditingController();
  final _scrollController = ScrollController();

  String _selectedRole = 'user';
  bool _showAddUserForm = false;
  bool _isSubmitting = false;
  bool _obscurePassword = true;
  Timer? _searchDebounce;

  // Bulk selection state
  final Set<String> _selectedUserIds = <String>{};
  bool _isBulkSelectMode = false;

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

  // Toggle bulk selection mode
  void _toggleBulkSelectMode() {
    setState(() {
      _isBulkSelectMode = !_isBulkSelectMode;
      if (!_isBulkSelectMode) {
        _selectedUserIds.clear();
      }
    });
  }

  // Clear selected users
  void _clearSelection() {
    setState(() {
      _selectedUserIds.clear();
    });
  }

  // Delete selected users
  Future<void> _deleteSelectedUsers() async {
    if (_selectedUserIds.isEmpty) return;

    final confirmed =
        await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Delete Selected Users'),
                content: Text(
                  'Are you sure you want to delete ${_selectedUserIds.length} selected user(s)? This action cannot be undone.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                    child: const Text('Delete'),
                  ),
                ],
              ),
        ) ??
        false;

    if (confirmed && mounted) {
      final provider = context.read<UsersProvider>();
      try {
        for (final userId in _selectedUserIds) {
          await provider.deleteUser(userId);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Deleted ${_selectedUserIds.length} user(s)'),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () {
                  // TODO: Implement undo functionality if needed
                },
              ),
            ),
          );
          setState(() {
            _selectedUserIds.clear();
            _isBulkSelectMode = false;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete users: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  // Build filter section
  Widget _buildFilterSection() {
    return Consumer<UsersProvider>(
      builder: (context, provider, _) {
        // Get the current role filter from the search query
        final currentFilter =
            provider.searchQuery?.split('role:').last.split(' ').firstOrNull ??
            'all';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              DropdownButton<String>(
                value: currentFilter == 'all' ? null : currentFilter,
                hint: const Text('Filter by role'),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All Roles')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(value: 'manager', child: Text('Manager')),
                  DropdownMenuItem(value: 'user', child: Text('User')),
                ],
                onChanged: (value) {
                  final roleFilter = value == 'all' ? '' : 'role:$value ';
                  final searchText =
                      provider.searchQuery?.replaceAll(
                        RegExp(r'role:\w+\s?'),
                        roleFilter,
                      ) ??
                      roleFilter;

                  provider.searchUsers(searchText.trim());
                },
              ),
              const SizedBox(width: 16),
              // Add more filter options here if needed
            ],
          ),
        );
      },
    );
  }

  // Handle user creation
  Future<void> _handleCreateUser() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSubmitting = true);
      try {
        final result = await context.read<UsersProvider>().createUser(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          role: _selectedRole,
        );

        if (mounted) {
          if (result['success'] == true) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('User created successfully'),
                behavior: SnackBarBehavior.floating,
              ),
            );
            setState(() {
              _emailController.clear();
              _passwordController.clear();
              _selectedRole = 'user';
              _formKey.currentState?.reset();
              _showAddUserForm = false;
            });
          } else {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  result['error']?.toString() ?? 'Failed to create user',
                ),
                backgroundColor: Theme.of(context).colorScheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSubmitting = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'User Management',
      body: Consumer<UsersProvider>(
        builder: (context, provider, _) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final screenH = MediaQuery.of(context).size.height;
              final maxH = constraints.hasBoundedHeight ? constraints.maxHeight : screenH;

              // Rough estimates for static sections; adjust as needed
              const headerAndFiltersEstimate = 200.0; // header + filters + spacing
              final addUserFormEstimate = _showAddUserForm ? 360.0 : 0.0;
              final errorBannerEstimate = (provider.error != null) ? 72.0 : 0.0;

              final availableListHeight = (maxH
                      - headerAndFiltersEstimate
                      - addUserFormEstimate
                      - errorBannerEstimate)
                  .clamp(240.0, double.infinity);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildFilterSection(),
                  if (_showAddUserForm) _buildAddUserForm(),
                  const SizedBox(height: 16),
                  if (provider.error != null)
                    Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            provider.error!,
                            style: TextStyle(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () {
                            provider.clearError();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                  const SizedBox(height: 8),
                  if (provider.isLoading && provider.users.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  SizedBox(
                    height: availableListHeight,
                    child: _buildUsersList(),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Padding(
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
                    suffixIcon:
                        _searchController.text.isNotEmpty
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
                    _searchDebounce = Timer(
                      const Duration(milliseconds: 300),
                      () => context.read<UsersProvider>().searchUsers(value),
                    );
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
                    } else {
                      _selectedRole = 'user';
                    }
                  });
                },
                icon: const Icon(Icons.person_add),
                label: Text(_showAddUserForm ? 'Cancel' : 'Add User'),
              ),
              const SizedBox(width: 8),
              if (_selectedUserIds.isNotEmpty)
                Row(
                  children: [
                    Text('${_selectedUserIds.length} selected'),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _clearSelection,
                      tooltip: 'Clear selection',
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed:
                          _isBulkSelectMode ? _deleteSelectedUsers : null,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Theme.of(context).colorScheme.onError,
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed:
                          _isBulkSelectMode ? _toggleBulkSelectMode : null,
                      icon: const Icon(Icons.cancel),
                      label: const Text('Cancel'),
                    ),
                  ],
                )
              else
                IconButton(
                  icon: const Icon(Icons.select_all),
                  onPressed: _toggleBulkSelectMode,
                  tooltip: 'Select multiple users',
                ),
            ],
          ),
        ),
        if (_isBulkSelectMode && _selectedUserIds.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: Row(
              children: [
                Text(
                  'Tap to select users for bulk actions',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Spacer(),
                TextButton(
                  onPressed: _toggleBulkSelectMode,
                  child: const Text('CANCEL'),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildAddUserForm() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.person_add, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Add New User',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'user@example.com',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                  filled: true,
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email address';
                  }
                  final emailRegex = RegExp(_kEmailRegex);
                  if (!emailRegex.hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setState) {
                  return TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'At least $_kMinPasswordLength characters',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      filled: true,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < _kMinPasswordLength) {
                        return 'Password must be at least $_kMinPasswordLength characters';
                      }
                      if (!value.contains(RegExp(r'[A-Z]'))) {
                        return 'Include at least one uppercase letter';
                      }
                      if (!value.contains(RegExp(r'[0-9]'))) {
                        return 'Include at least one number';
                      }
                      if (!value.contains(
                        RegExp(r'[!@#\$%^&*(),.?\":{}|<>]'),
                      )) {
                        return 'Include at least one special character';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'User Role',
                  prefixIcon: Icon(Icons.people_outline),
                  border: OutlineInputBorder(),
                  filled: true,
                ),
                items:
                    UsersProvider.availableRoles.map<DropdownMenuItem<String>>((
                      role,
                    ) {
                      return DropdownMenuItem<String>(
                        value: role['value'] as String,
                        child: Text((role['label'] as String).capitalize()),
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
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: _isSubmitting ? null : _handleCreateUser,
                      child:
                          _isSubmitting
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text('Create User'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed:
                        _isSubmitting
                            ? null
                            : () {
                              _formKey.currentState?.reset();
                              setState(() => _showAddUserForm = false);
                            },
                    child: const Text('Cancel'),
                  ),
                ],
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
        if (provider.isLoading && provider.users.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (provider.users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: Theme.of(context).disabledColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'No users found',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (provider.searchQuery?.isNotEmpty == true) ...{
                  const SizedBox(height: 8),
                  Text(
                    'Try adjusting your search or filter',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      provider.searchUsers('');
                      _searchController.clear();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Clear Search'),
                  ),
                },
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.initialize(),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: provider.users.length + (provider.hasMoreUsers ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= provider.users.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final user = provider.users[index];
              return _buildUserTile(user, provider);
            },
          ),
        );
      },
    );
  }

  Widget _buildUserTile(Map<String, dynamic> user, UsersProvider provider) {
    final email = user['email'] ?? 'No email';
    final userId = user['id'] as String?;
    final currentUser = FirebaseAuth.instance.currentUser;
    final isCurrentUser = currentUser?.uid == userId;
    final bool isActive = (user['isActive'] ?? true) as bool;
    final String roleLabel = user['roleLabel']?.toString() ?? 'User';
    final createdAt =
        user['createdAt'] is DateTime
            ? user['createdAt'] as DateTime
            : (user['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  email.isNotEmpty ? email[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        decoration:
                            !isActive ? TextDecoration.lineThrough : null,
                        fontWeight: isCurrentUser ? FontWeight.bold : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      roleLabel,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      'Joined: ${DateFormat('MMM d, y').format(createdAt)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall?.color?.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (isCurrentUser)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Chip(
                    label: const Text('You'),
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontSize: 12,
                    ),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                )
              else
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  itemBuilder:
                      (BuildContext context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: const Text('Edit Role'),
                          onTap: () => _showEditRoleDialog(user, provider),
                        ),
                        PopupMenuItem(
                          value: 'toggle',
                          onTap: () async {
                            await Future.delayed(Duration.zero);
                            final success = await provider.toggleUserStatus(
                              userId!,
                              isActive,
                            );
                            if (success && mounted) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isActive
                                          ? 'User deactivated successfully'
                                          : 'User activated successfully',
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            } else if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    provider.error ??
                                        'Failed to update user status',
                                  ),
                                  backgroundColor:
                                      Theme.of(context).colorScheme.error,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isActive ? Icons.person_off : Icons.person_add,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(isActive ? 'Deactivate' : 'Activate'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Delete User',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                  onSelected: (String value) {
                    if (value == 'delete') {
                      _showDeleteConfirmation(user, provider);
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditRoleDialog(Map<String, dynamic> user, UsersProvider provider) {
    final userId = user['id'] as String?;
    String? selectedRole = user['role'] as String?;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit User Role'),
            content: DropdownButtonFormField<String>(
              value: selectedRole,
              decoration: const InputDecoration(labelText: 'Role'),
              items:
                  UsersProvider.availableRoles.map<DropdownMenuItem<String>>((
                    role,
                  ) {
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

  Future<void> _showDeleteConfirmation(
    Map<String, dynamic> user,
    UsersProvider provider,
  ) async {
    final userId = user['id'] as String?;
    final email = user['email'] ?? 'this user';

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Deletion'),
            content: Text(
              'Are you sure you want to delete $email? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (shouldDelete == true && userId != null && mounted) {
      try {
        await provider.deleteUser(userId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User deleted successfully'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete user: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
}
