import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/blog_provider.dart';
import '../models/blog_post.dart';

class BlogAdminListScreen extends StatelessWidget {
  const BlogAdminListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BlogProvider(),
      child: const _BlogAdminListScreenContent(),
    );
  }
}

class _BlogAdminListScreenContent extends StatefulWidget {
  const _BlogAdminListScreenContent();

  @override
  State<_BlogAdminListScreenContent> createState() => _BlogAdminListScreenContentState();
}

class _BlogAdminListScreenContentState extends State<_BlogAdminListScreenContent> {
  String _filter = 'all';
  final _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    if (!mounted) return;
    try {
      final provider = context.read<BlogProvider>();
      await provider.initialize(filter: _filter);
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error initializing blog: $e');
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      _loadMorePosts();
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoadingMore) return;
    
    final provider = context.read<BlogProvider>();
    if (!provider.hasMore || provider.isLoading) return;
    
    try {
      setState(() => _isLoadingMore = true);
      await provider.loadMorePosts();
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to load more posts: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: 'Retry',
          onPressed: () async {
            try {
              final provider = context.read<BlogProvider>();
              await provider.refreshPosts();
            } catch (e) {
              if (mounted) {
                _showErrorSnackBar('Error retrying: $e');
              }
            }
          },
        ),
      ),
    );
  }

  Widget _buildFilterChipsWidget() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChipItem('All', 'all'),
          const SizedBox(width: 8),
          _buildFilterChipItem('Published', 'published'),
          const SizedBox(width: 8),
          _buildFilterChipItem('Drafts', 'draft'),
        ],
      ),
    );
  }

  Widget _buildFilterChipItem(String label, String value) {
    return FilterChip(
      label: Text(label),
      selected: _filter == value,
      onSelected: (selected) {
        if (selected) {
          setState(() => _filter = value);
          _initialize();
        }
      },
    );
  }

  Widget _buildPostCardItem(BlogPost post) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: ListTile(
        title: Text(post.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.excerpt.isNotEmpty) Text(post.excerpt),
            const SizedBox(height: 4),
            Text(
              'Status: ${post.status}',
              style: TextStyle(
                color: post.status == 'published' ? Colors.green : null,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            final provider = context.read<BlogProvider>();
            switch (value) {
              case 'edit':
                context.push('/admin/blog/editor', extra: post);
                break;
              case 'delete':
                await _showDeleteConfirmationDialog(post);
                break;
              case 'toggle':
                await provider.togglePostStatus(
                  post.id,
                  post.status,
                );
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Text('Edit'),
            ),
            PopupMenuItem(
              value: 'toggle',
              child: Text(
                post.status == 'draft' ? 'Publish' : 'Unpublish',
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(BlogPost post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: Text('Are you sure you want to delete "${post.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await context.read<BlogProvider>().deletePost(post.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          _showErrorSnackBar('Failed to delete post: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BlogProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.posts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(provider.error!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _initialize,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Blog Posts'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => context.push('/admin/blog/editor'),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search posts...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    // TODO: Implement search
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildFilterChipsWidget(),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => provider.refreshPosts(),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.posts.length + (provider.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= provider.posts.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return _buildPostCardItem(provider.posts[index]);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }




  
  Future<void> _refreshPosts(BlogProvider provider) async {
    final filter = _filter == 'all' ? null : _filter;
    await provider.initialize(filter: filter);
  }
}
