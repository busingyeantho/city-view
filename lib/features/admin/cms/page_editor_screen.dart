import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/auth/auth_controller.dart';
import 'package:provider/provider.dart';
import '../../../shared/ui/responsive_scaffold.dart';
import '../../../shared/widgets/image_placeholder.dart';
import 'widgets/about_body_editor.dart';
import 'widgets/academics_body_editor.dart';

class PageEditorScreen extends StatefulWidget {
  const PageEditorScreen({super.key});

  @override
  State<PageEditorScreen> createState() => _PageEditorScreenState();
}

class _PageEditorScreenState extends State<PageEditorScreen> {
  final _pages = FirebaseFirestore.instance.collection('pages');
  String _selectedPageId = 'home';
  String? _heroUrl;
  String? _heroPath;

  @override
  Widget build(BuildContext context) {
    final docRef = _pages.doc(_selectedPageId);
    return ResponsiveScaffold(
      title: 'Pages / CMS',
      body: Row(
        children: [
          SizedBox(
            width: 260,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _pageTile('home', 'Home'),
                _pageTile('about', 'About'),
                _pageTile('academics', 'Academics'),
                _pageTile('sports', 'Sports'),
                _pageTile('health-diet', 'Health & Diet'),
                _pageTile('achievements', 'Achievements'),
                _pageTile('contact', 'Contact'),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      FilledButton(
                        onPressed: () async {
                          final draft = {
                            'heroImageUrl': _heroUrl,
                            'heroImagePath': _heroPath,
                          };
                          await docRef.set({'draft': draft}, SetOptions(merge: true));
                          final user = context.read<AuthController>().user;
                          await docRef.collection('versions').add({
                            'draft': draft,
                            'authorId': user?.uid,
                            'authorEmail': user?.email,
                            'diff': 'hero updated',
                            'createdAt': FieldValue.serverTimestamp(),
                          });
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Draft saved')));
                          }
                        },
                        child: const Text('Save Draft'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () async {
                          final snap = await docRef.get();
                          final draft = (snap.data() ?? {})['draft'] ?? {};
                          await docRef.set({'published': draft}, SetOptions(merge: true));
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Published')));
                          }
                        },
                        child: const Text('Publish'),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/preview/${_selectedPageId}/draft');
                        },
                        child: const Text('Preview Draft'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/preview/${_selectedPageId}/published');
                        },
                        child: const Text('Preview Published'),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream: docRef.snapshots(),
                      builder: (context, snapshot) {
                        final data = snapshot.data?.data() ?? {};
                        final draft = (data['draft'] ?? {}) as Map<String, dynamic>;
                        _heroUrl ??= draft['heroImageUrl'] as String?;
                        _heroPath ??= draft['heroImagePath'] as String?;
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ListView(
                                children: [
                                  Text('Hero Section', style: Theme.of(context).textTheme.titleLarge),
                                  const SizedBox(height: 8),
                                  ImagePlaceholder(
                                    imageUrl: _heroUrl,
                                    storagePathPrefix: 'images/${_selectedPageId}/',
                                    onUploaded: (url) => setState(() => _heroUrl = url),
                                    onUploadedPath: (path) async {
                                      _heroPath = path;
                                      await FirebaseFirestore.instance.collection('images').add({
                                        'path': path,
                                        'pageId': _selectedPageId,
                                        'createdAt': FieldValue.serverTimestamp(),
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  if (_selectedPageId == 'about') ...[
                                    Text('About Body', style: Theme.of(context).textTheme.titleLarge),
                                    const SizedBox(height: 8),
                                    AboutBodyEditor(docRef: docRef),
                                    const SizedBox(height: 16),
                                  ],
                                  if (_selectedPageId == 'academics') ...[
                                    Text('Academics Body', style: Theme.of(context).textTheme.titleLarge),
                                    const SizedBox(height: 8),
                                    AcademicsBodyEditor(docRef: docRef),
                                    const SizedBox(height: 16),
                                  ],
                                  if (_selectedPageId == 'sports') ...[
                                    Text('Sports Body', style: Theme.of(context).textTheme.titleLarge),
                                    const SizedBox(height: 8),
                                    _SimpleBodyEditor(docRef: docRef, field: 'body', saveLabel: 'Save Sports Draft'),
                                    const SizedBox(height: 16),
                                  ],
                                  if (_selectedPageId == 'health-diet') ...[
                                    Text('Health & Diet Body', style: Theme.of(context).textTheme.titleLarge),
                                    const SizedBox(height: 8),
                                    _SimpleBodyEditor(docRef: docRef, field: 'body', saveLabel: 'Save Health Draft'),
                                    const SizedBox(height: 16),
                                  ],
                                  if (_selectedPageId == 'achievements') ...[
                                    Text('Achievements Body', style: Theme.of(context).textTheme.titleLarge),
                                    const SizedBox(height: 8),
                                    _SimpleBodyEditor(docRef: docRef, field: 'body', saveLabel: 'Save Achievements Draft'),
                                    const SizedBox(height: 16),
                                  ],
                                  const Text('Add more sections and fields here...'),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            SizedBox(
                              width: 300,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Versions', style: Theme.of(context).textTheme.titleMedium),
                                  const SizedBox(height: 8),
                                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                                    stream: docRef.collection('versions').orderBy('createdAt', descending: true).limit(10).snapshots(),
                                    builder: (context, snap) {
                                      final versions = snap.data?.docs ?? [];
                                      return ListView.separated(
                                        shrinkWrap: true,
                                        itemCount: versions.length,
                                        separatorBuilder: (_, __) => const Divider(height: 1),
                                        itemBuilder: (context, i) {
                                          final v = versions[i];
                                          final ts = v.data()['createdAt'] as Timestamp?;
                                          final when = ts != null ? DateTime.fromMillisecondsSinceEpoch(ts.millisecondsSinceEpoch) : null;
                                          final author = (v.data()['authorEmail'] ?? v.data()['authorId'] ?? '') as String?;
                                          final diff = v.data()['diff'] as String?;
                                          return ListTile(
                                            dense: true,
                                            title: Text(when?.toLocal().toString() ?? 'Version'),
                                            subtitle: Text([author, diff].where((e) => e != null && e.isNotEmpty).join(' • ')),
                                            trailing: TextButton(
                                              onPressed: () async {
                                                final vd = v.data();
                                                await docRef.set({'draft': vd['draft']}, SetOptions(merge: true));
                                                if (mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reverted draft')));
                                                }
                                              },
                                              child: const Text('Revert'),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _pageTile(String id, String label) {
    final selected = _selectedPageId == id;
    return ListTile(
      selected: selected,
      title: Text(label),
      onTap: () => setState(() {
        _selectedPageId = id;
        _heroUrl = null;
        _heroPath = null;
      }),
    );
  }
}

class _SimpleBodyEditor extends StatefulWidget {
  final DocumentReference<Map<String, dynamic>> docRef;
  final String field;
  final String saveLabel;
  const _SimpleBodyEditor({required this.docRef, required this.field, required this.saveLabel});

  @override
  State<_SimpleBodyEditor> createState() => _SimpleBodyEditorState();
}

class _SimpleBodyEditorState extends State<_SimpleBodyEditor> {
  final ctl = TextEditingController();

  @override
  void dispose() {
    ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: ctl,
          maxLines: 8,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton(
            onPressed: () async {
              await widget.docRef.set({'draft': {widget.field: ctl.text.trim()}}, SetOptions(merge: true));
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.saveLabel)));
            },
            child: Text(widget.saveLabel),
          ),
        ),
      ],
    );
  }
}


