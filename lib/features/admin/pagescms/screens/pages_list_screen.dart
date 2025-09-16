import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../models/page_data.dart';
import '../providers/page_provider.dart';
import 'package:city_view_website/shared/widgets/error_display.dart';
import 'package:city_view_website/shared/widgets/loading_indicator.dart';

class PagesListScreen extends StatelessWidget {
  const PagesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<PageProvider>().refreshPages(),
          ),
        ],
      ),
      body: const _PagesListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/admin/pages/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _PagesListView extends StatelessWidget {
  const _PagesListView();

  @override
  Widget build(BuildContext context) {
    final pageProvider = context.watch<PageProvider>();

    if (pageProvider.isLoading) {
      return const Center(child: LoadingIndicator());
    }

    if (pageProvider.error != null) {
      return ErrorDisplay(message: pageProvider.error!);
    }

    return StreamBuilder<List<PageData>>(
      stream: pageProvider.watchPages(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ErrorDisplay(
            message: 'Failed to load pages: ${snapshot.error}',
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No pages found. Create your first page!'),
          );
        }

        final pages = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pages.length,
          itemBuilder: (context, index) {
            final page = pages[index];
            return _PageCard(page: page);
          },
        );
      },
    );
  }
}

class _PageCard extends StatelessWidget {
  final PageData page;

  const _PageCard({required this.page});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPublished = page.isPublished;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Row(
          children: [
            Expanded(
              child: Text(
                page.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (isPublished) ...[
              const Icon(Icons.visibility, size: 16, color: Colors.green),
              const SizedBox(width: 4),
              Text(
                'Published',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.green),
              ),
            ] else ...[
              const Icon(Icons.visibility_off, size: 16, color: Colors.orange),
              const SizedBox(width: 4),
              Text(
                'Draft',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.orange,
                ),
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('/${page.slug}', style: theme.textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              'Last updated: ${_formatDate(page.updatedAt)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          itemBuilder:
              (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(
                  value: 'view',
                  enabled: isPublished,
                  child: Text(
                    'View Live',
                    style:
                        isPublished
                            ? null
                            : TextStyle(color: theme.disabledColor),
                  ),
                ),
                const PopupMenuItem(
                  value: 'duplicate',
                  child: Text('Duplicate'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
          onSelected: (value) => _handleMenuAction(context, value, page.id),
        ),
        onTap: () => context.push('/admin/pages/${page.id}'),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action, String pageId) {
    switch (action) {
      case 'edit':
        context.push('/admin/pages/$pageId');
        break;
      case 'view':
        // TODO: Implement view live functionality
        break;
      case 'duplicate':
        // TODO: Implement duplicate functionality
        break;
      case 'delete':
        _showDeleteDialog(context, pageId);
        break;
    }
  }

  void _showDeleteDialog(BuildContext context, String pageId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Page'),
            content: const Text('Are you sure you want to delete this page?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  try {
                    await context.read<PageProvider>().deletePage(pageId);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Page deleted successfully'),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to delete page: $e')),
                      );
                    }
                  }
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
