import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_display.dart';
import '../../providers/gallery_provider.dart';
import '../../models/gallery_image.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedCategoryId;
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  final int _itemsPerPage = 20;
  final Map<String, List<GalleryImage>> _loadedImages = {};
  final Map<String, bool> _hasMoreImages = {};
  final Map<String, DocumentSnapshot?> _lastDocuments = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _tabController.addListener(_handleTabChange);

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<GalleryProvider>();

      // Add a listener to handle category updates
      void handleCategoriesUpdate() {
        if (provider.categories.isNotEmpty) {
          setState(() {
            _selectedCategoryId = provider.categories.first.id;
            // Only recreate the tab controller if the number of categories has changed
            if (_tabController.length != provider.categories.length) {
              _tabController.removeListener(_handleTabChange);
              _tabController.dispose();
              _tabController = TabController(
                length: provider.categories.length,
                vsync: this,
                initialIndex: 0,
              )..addListener(_handleTabChange);
            }
          });
          _loadMoreImages();
        }
      }

      // Add the provider update listener
      provider.addListener(_handleProviderUpdate);

      // Initialize the provider
      provider.initialize().then((_) {
        // If categories are already loaded, handle them
        if (provider.categories.isNotEmpty) {
          handleCategoriesUpdate();
        }
      });
    });

    // Setup scroll listener for infinite scroll
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _scrollController.dispose();

    // Remove the provider listener if it exists
    final provider = context.read<GalleryProvider>();
    provider.removeListener(_handleProviderUpdate);

    super.dispose();
  }

  void _handleProviderUpdate() {
    if (!mounted) return;

    final provider = context.read<GalleryProvider>();
    setState(() {
      // Update the selected category if needed
      if (_selectedCategoryId == null && provider.categories.isNotEmpty) {
        _selectedCategoryId = provider.categories.first.id;
      }
    });
  }

  Future<void> _loadMoreImages({bool reset = false}) async {
    if (_selectedCategoryId == null || _isLoadingMore) {
      return;
    }

    setState(() => _isLoadingMore = true);

    try {
      final provider = context.read<GalleryProvider>();
      final categoryId = _selectedCategoryId!;

      if (reset) {
        _loadedImages[categoryId] = [];
        _lastDocuments[categoryId] = null;
        _hasMoreImages[categoryId] = true;
      }

      if (_hasMoreImages[categoryId] != false) {
        await provider.loadCategoryImages(
          categoryId,
          startAfter: _lastDocuments[categoryId],
          limit: _itemsPerPage,
        );

        final images = provider.getImagesByCategory(categoryId);
        _loadedImages[categoryId] = [
          ..._loadedImages[categoryId] ?? [],
          ...images,
        ];

        // Update pagination state
        _hasMoreImages[categoryId] = images.length >= _itemsPerPage;
        if (images.isNotEmpty) {
          _lastDocuments[categoryId] = provider.getLastDocument(categoryId);
        }
      }
    } catch (e) {
      debugPrint('Error loading more images: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load more images')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _loadMoreImages();
    }
  }

  // Handle tab changes
  void _handleTabChange() {
    if (!_tabController.indexIsChanging && mounted) {
      final provider = context.read<GalleryProvider>();
      if (_tabController.index < provider.categories.length) {
        final newCategoryId = provider.categories[_tabController.index].id;
        final isNewCategory = _selectedCategoryId != newCategoryId;

        setState(() {
          _selectedCategoryId = newCategoryId;
        });

        if (isNewCategory) {
          _loadMoreImages(reset: true);
        }
      }
    }
  }

  void _showImageFullScreen(GalleryImage image) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog.fullscreen(
            child: Stack(
              children: [
                // Main image
                InteractiveViewer(
                  minScale: 0.1,
                  maxScale: 4.0,
                  child: Center(
                    child: CachedNetworkImage(
                      imageUrl: image.imageUrl,
                      fit: BoxFit.contain,
                      placeholder:
                          (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                      errorWidget:
                          (context, url, error) => const Icon(Icons.error),
                    ),
                  ),
                ),
                // App bar
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AppBar(
                    backgroundColor: Colors.black54,
                    iconTheme: const IconThemeData(color: Colors.white),
                    title: Text(
                      image.title ?? 'Image',
                      style: const TextStyle(color: Colors.white),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.download),
                        onPressed: () {
                          // TODO: Implement download
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Download functionality coming soon',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // Image info
                if (image.description != null)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.black54,
                      child: Text(
                        image.description!,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GalleryProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.categories.isEmpty) {
          return const Center(child: LoadingIndicator());
        }

        if (provider.error != null && provider.categories.isEmpty) {
          return Center(
            child: ErrorDisplay(
              message: provider.error!,
              onRetry: provider.initialize,
            ),
          );
        }

        if (provider.categories.isEmpty) {
          return const Center(child: Text('No gallery categories available'));
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Category tabs
                Container(
                  color: Theme.of(context).appBarTheme.backgroundColor,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: Theme.of(context).colorScheme.primary,
                    indicatorColor: Theme.of(context).colorScheme.primary,
                    tabs:
                        provider.categories
                            .map((category) => Tab(text: category.name))
                            .toList(),
                  ),
                ),

                // Gallery grid
                SizedBox(
                  height: constraints.maxHeight - kToolbarHeight,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification is ScrollEndNotification) {
                        _onScroll();
                      }
                      return true;
                    },
                    child: _buildGalleryGrid(provider),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildGalleryGrid(GalleryProvider provider) {
    if (_selectedCategoryId == null) {
      return const Center(child: Text('Select a category'));
    }

    final categoryId = _selectedCategoryId!;
    final images = _loadedImages[categoryId] ?? [];
    final isLoading = _isLoadingMore || (images.isEmpty && provider.isLoading);

    if (isLoading && images.isEmpty) {
      return const Center(child: LoadingIndicator());
    }

    if (images.isEmpty) {
      return const Center(child: Text('No images in this category'));
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _calculateCrossAxisCount(),
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: images.length + (_hasMoreImages[categoryId] == true ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= images.length) {
          return const Center(child: CircularProgressIndicator());
        }

        final image = images[index];
        return GestureDetector(
          onTap: () => _showImageFullScreen(image),
          child: Hero(
            tag: 'image_${image.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image
                  CachedNetworkImage(
                    imageUrl: image.imageUrl,
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    errorWidget:
                        (context, url, error) => const Icon(Icons.error),
                  ),

                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.1),
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),

                  // Featured badge
                  if (image.isFeatured)
                    const Positioned(
                      top: 8,
                      right: 8,
                      child: Icon(Icons.star, color: Colors.amber, size: 24),
                    ),

                  // Title
                  if (image.title != null)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        color: Colors.black45,
                        child: Text(
                          image.title!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  int _calculateCrossAxisCount() {
    // Use MediaQuery to get the screen width
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth > 1200) return 5;
    if (screenWidth > 900) return 4;
    if (screenWidth > 600) return 3;
    return 2;
  }
}
