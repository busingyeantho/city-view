import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LiveStreamPlayer extends StatefulWidget {
  final String urlOrEmbed;
  const LiveStreamPlayer({super.key, required this.urlOrEmbed});

  @override
  State<LiveStreamPlayer> createState() => _LiveStreamPlayerState();
}

class _LiveStreamPlayerState extends State<LiveStreamPlayer> {
  late final String _viewType;

  @override
  void initState() {
    super.initState();
    _viewType = 'iframe-${DateTime.now().microsecondsSinceEpoch}-${widget.urlOrEmbed.hashCode}';
    if (kIsWeb) {
      // Register an iframe factory
      // ignore: undefined_prefixed_name
      ui.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
        final element = html.DivElement();

        if (_looksLikeEmbed(widget.urlOrEmbed)) {
          element.setInnerHtml(
            widget.urlOrEmbed,
            validator: _TrustedNodeValidator(),
          );
        } else {
          final iframe = html.IFrameElement()
            ..src = widget.urlOrEmbed
            ..style.border = '0'
            ..allow = 'autoplay; encrypted-media; picture-in-picture'
            ..allowFullscreen = true;
          element.children = [iframe];
        }
        return element;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return const Center(child: Text('Live stream is only supported on web in this build'));
    }
    return HtmlElementView(viewType: _viewType);
  }

  bool _looksLikeEmbed(String s) {
    return s.contains('<iframe');
  }
}

class _TrustedNodeValidator implements html.NodeValidator {
  @override
  bool allowsAttribute(html.Element element, String attributeName, String value) => true;

  @override
  bool allowsElement(html.Element element) => true;
}


