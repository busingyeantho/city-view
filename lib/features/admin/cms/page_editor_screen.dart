import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../shared/ui/responsive_scaffold.dart';
import '../../../shared/widgets/image_placeholder.dart';
import 'widgets/about_body_editor.dart';
import 'widgets/academics_body_editor.dart';

class PageEditorScreen extends StatefulWidget {
  const PageEditorScreen({super.key});

  @override
  State<PageEditorScreen> createState() => _PageEditorScreenState();
}

class _PageEditorScreenState extends State<PageEditorScreen>
    with SingleTickerProviderStateMixin {
  final _pages = FirebaseFirestore.instance.collection('pages');
  late final TabController _tabController;
  String _selectedPageId = 'home';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Helper method to get the appropriate editor widget based on page ID
  Widget _getEditorForPage(
    String pageId,
    DocumentReference<Map<String, dynamic>> docRef,
  ) {
    switch (pageId) {
      case 'about':
        return AboutBodyEditor(docRef: docRef);
      case 'academics':
        return AcademicsBodyEditor(docRef: docRef);
      default:
        return _SimpleBodyEditor(
          docRef: docRef,
          field: 'body',
          saveLabel: 'Save',
        );
    }
  }

  Future<void> _saveImagePath(
    DocumentReference<Map<String, dynamic>> docRef,
    String? imageUrl,
  ) async {
    try {
      await docRef.update({
        'draft.heroImageUrl': imageUrl,
        'draft.heroImagePath': 'images/$_selectedPageId/hero',
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save image: $e')));
      }
    }
  }

  Future<void> _saveDraft(
    DocumentReference<Map<String, dynamic>> docRef,
  ) async {
    try {
      final snap = await docRef.get();
      final draft = (snap.data() ?? {})['draft'] ?? {};

      await docRef.set({'draft': draft}, SetOptions(merge: true));

      final user = context.read<AuthController>().user;
      await docRef.collection('versions').add({
        'draft': draft,
        'authorId': user?.uid,
        'authorEmail': user?.email,
        'diff': 'Updated hero section',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Draft saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving draft: $e')));
      }
    }
  }

  Future<void> _publish(DocumentReference<Map<String, dynamic>> docRef) async {
    try {
      final snap = await docRef.get();
      final draft = (snap.data() ?? {})['draft'] ?? {};
      await docRef.set({'published': draft}, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Published successfully')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error publishing: $e')));
      }
    }
  }

  Future<void> _revertToVersion(
    QueryDocumentSnapshot<Map<String, dynamic>> version,
    DocumentReference<Map<String, dynamic>> docRef,
  ) async {
    try {
      final versionData = version.data();
      await docRef.set({
        'draft': versionData['draft'],
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reverted to this version')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error reverting version: $e')));
      }
    }
  }

  // Build page tile for sidebar navigation
  Widget _buildPageTile(String id, String label) {
    final selected = _selectedPageId == id;
    return ListTile(
      selected: selected,
      title: Text(label),
      onTap:
          () => setState(() {
            _selectedPageId = id;
          }),
    );
  }

  Widget _buildHeroImageEditor(
    DocumentReference<Map<String, dynamic>> docRef,
    String? heroImageUrl,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ImagePlaceholder(
              imageUrl: heroImageUrl,
              storagePathPrefix: 'images/$_selectedPageId/',
              onUploaded: (url) => _saveImagePath(docRef, url),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageSpecificContent(
    DocumentReference<Map<String, dynamic>> docRef,
  ) {
    switch (_selectedPageId) {
      case 'about':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About Content',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            AboutBodyEditor(docRef: docRef),
          ],
        );
      case 'academics':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Academics Content',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            AcademicsBodyEditor(docRef: docRef),
          ],
        );
      default:
        return _buildSimpleEditor(
          docRef: docRef,
          title: 'Page Content',
          field: 'body',
          saveLabel: 'Save',
        );
    }
  }

  Widget _buildSimpleEditor({
    required DocumentReference<Map<String, dynamic>> docRef,
    required String title,
    required String field,
    required String saveLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        _SimpleBodyEditor(docRef: docRef, field: field, saveLabel: saveLabel),
      ],
    );
  }

  Widget _buildVersionsSidebar(DocumentReference<Map<String, dynamic>> docRef) {
    return SizedBox(
      width: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Versions', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream:
                docRef
                    .collection('versions')
                    .orderBy('createdAt', descending: true)
                    .limit(10)
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final versions = snapshot.data?.docs ?? [];
              if (versions.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No versions available'),
                  ),
                );
              }

              return Expanded(
                child: ListView.separated(
                  itemCount: versions.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final version = versions[index];
                    final data = version.data();
                    final ts = data['createdAt'] as Timestamp?;
                    final when = ts?.toDate() ?? DateTime.now();
                    final author =
                        (data['authorEmail'] ?? data['authorId'] ?? '')
                            as String?;
                    final diff = data['diff'] as String?;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(when.toString().substring(0, 16)),
                        subtitle: Text(
                          [
                            author,
                            diff,
                          ].where((e) => e != null && e.isNotEmpty).join(' • '),
                        ),
                        trailing: TextButton(
                          onPressed: () => _revertToVersion(version, docRef),
                          child: const Text('Revert'),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final docRef = _pages.doc(_selectedPageId);

    return ResponsiveScaffold(
      title: 'Pages / CMS',
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sidebar
              Container(
                width: 260,
                color: Colors.grey.shade100,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Pages',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          _buildPageTile('home', 'Home'),
                          _buildPageTile('about', 'About'),
                          _buildPageTile('academics', 'Academics'),
                          _buildPageTile('sports', 'Sports'),
                          _buildPageTile('health-diet', 'Health & Diet'),
                          _buildPageTile('achievements', 'Achievements'),
                          _buildPageTile('contact', 'Contact'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: docRef.snapshots(),
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                    snapshot,
                  ) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final data = snapshot.data?.data() ?? {};
                    final draft = (data['draft'] ?? {}) as Map<String, dynamic>;
                    final heroImageUrl = draft['heroImageUrl'] as String?;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Action buttons
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () => _saveDraft(docRef),
                                      child: const Text('Save Draft'),
                                    ),
                                    const SizedBox(width: 16),
                                    ElevatedButton(
                                      onPressed: () => _publish(docRef),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Publish'),
                                    ),
                                    const Spacer(),
                                    ElevatedButton(
                                      onPressed:
                                          () => Navigator.of(context).pushNamed(
                                            '/preview/$_selectedPageId/draft',
                                          ),
                                      child: const Text('Preview Draft'),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed:
                                          () => Navigator.of(context).pushNamed(
                                            '/preview/$_selectedPageId/published',
                                          ),
                                      child: const Text('Preview Published'),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(height: 1),
                              // Content tabs
                              TabBar(
                                controller: _tabController,
                                tabs: const [
                                  Tab(text: 'Content'),
                                  Tab(text: 'Settings'),
                                ],
                              ),
                              // Tab content
                              Expanded(
                                child: TabBarView(
                                  controller: _tabController,
                                  children: [
                                    // Content tab
                                    SingleChildScrollView(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          // Hero section header
                                          Text(
                                            'Hero Section',
                                            style:
                                                Theme.of(
                                                  context,
                                                ).textTheme.titleLarge,
                                          ),
                                          const SizedBox(height: 8),

                                          // Hero image editor
                                          _buildHeroImageEditor(
                                            docRef,
                                            heroImageUrl,
                                          ),
                                          const SizedBox(height: 24),

                                          // Page-specific content
                                          _buildPageSpecificContent(docRef),
                                        ],
                                      ),
                                    ),
                                    // Settings tab
                                    const Center(child: Text('Settings')),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        _buildVersionsSidebar(docRef),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SimpleBodyEditor extends StatefulWidget {
  final DocumentReference<Map<String, dynamic>> docRef;
  final String field;
  final String saveLabel;

  const _SimpleBodyEditor({
    required this.docRef,
    required this.field,
    required this.saveLabel,
  });

  @override
  State<_SimpleBodyEditor> createState() => _SimpleBodyEditorState();
}

class _SimpleBodyEditorState extends State<_SimpleBodyEditor> {
  final _controller = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      final doc = await widget.docRef.get();
      if (!doc.exists) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      final data = doc.data() ?? {};
      final draft = (data['draft'] ?? {}) as Map<String, dynamic>;

      if (mounted) {
        setState(() {
          _controller.text = (draft[widget.field] ?? '') as String;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading content: $e')));
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveContent() async {
    try {
      await widget.docRef.set({
        'draft': {widget.field: _controller.text.trim()},
      }, SetOptions(merge: true));

      // The rest of the saving logic (like creating a new version) is handled
      // by the main _saveDraft method in the PageEditorScreen state.

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Content saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving content: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          maxLines: 10,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: 'Enter content here...',
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(onPressed: _saveContent, child: Text(widget.saveLabel)),
      ],
    );
  }
}
