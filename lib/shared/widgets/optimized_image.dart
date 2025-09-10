import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class OptimizedImage extends StatefulWidget {
  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final String? storagePath; // if provided, fetch variants map from images collection

  const OptimizedImage({super.key, required this.url, this.fit = BoxFit.cover, this.width, this.height, this.storagePath});

  @override
  State<OptimizedImage> createState() => _OptimizedImageState();
}

class _OptimizedImageState extends State<OptimizedImage> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ValueKey('img-${widget.url.hashCode}'),
      onVisibilityChanged: (info) {
        if (!_visible && info.visibleFraction > 0) {
          setState(() => _visible = true);
        }
      },
      child: _visible
          ? _OptimizedNetwork(
              urlFallback: widget.url,
              fit: widget.fit,
              width: widget.width,
              height: widget.height,
              storagePath: widget.storagePath,
            )
          : Container(color: Theme.of(context).colorScheme.surfaceContainerHighest, width: widget.width, height: widget.height),
    );
  }
}

class _OptimizedNetwork extends StatelessWidget {
  final String urlFallback;
  final BoxFit fit;
  final double? width;
  final double? height;
  final String? storagePath;

  const _OptimizedNetwork({required this.urlFallback, required this.fit, this.width, this.height, this.storagePath});

  @override
  Widget build(BuildContext context) {
    if (storagePath == null || storagePath!.isEmpty) {
      return _image(urlFallback, context);
    }
    final q = FirebaseFirestore.instance.collection('images').where('path', isEqualTo: storagePath).limit(1);
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: q.snapshots(),
      builder: (context, snapshot) {
        final doc = (snapshot.data?.docs ?? []).isNotEmpty ? snapshot.data!.docs.first.data() : null;
        final variants = (doc?['variants'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(int.tryParse(k) ?? 0, v as String));
        final chosen = _chooseUrlForWidth(context, variants) ?? urlFallback;
        return _image(chosen, context);
      },
    );
  }

  String? _chooseUrlForWidth(BuildContext context, Map<int, String>? variants) {
    if (variants == null || variants.isEmpty) return null;
    final media = MediaQuery.of(context);
    final viewport = media.size.width;
    final dpr = media.devicePixelRatio.clamp(1.0, 3.0);
    final targetCssPx = (width ?? viewport).clamp(0, double.infinity);
    final targetPhysical = targetCssPx * dpr;
    final sorted = variants.keys.toList()..sort();
    for (final w in sorted) {
      if (w >= targetPhysical) return variants[w];
    }
    return variants[sorted.last];
  }

  Widget _image(String url, BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      width: width,
      height: height,
      placeholder: (c, _) => Container(color: Theme.of(context).colorScheme.surfaceContainerHighest),
      errorWidget: (c, _, __) => const Icon(Icons.broken_image),
    );
  }
}


