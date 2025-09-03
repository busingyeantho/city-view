import 'dart:html' as html show FileUploadInputElement, document, File; // Web-only
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ImagePlaceholder extends StatefulWidget {
  final String? imageUrl;
  final String storagePathPrefix; // e.g., images/home/
  final ValueChanged<String>? onUploaded; // returns download URL
  final ValueChanged<String>? onUploadedPath; // returns storage path

  const ImagePlaceholder({super.key, this.imageUrl, required this.storagePathPrefix, this.onUploaded, this.onUploadedPath});

  @override
  State<ImagePlaceholder> createState() => _ImagePlaceholderState();
}

class _ImagePlaceholderState extends State<ImagePlaceholder> {
  bool _uploading = false;

  @override
  Widget build(BuildContext context) {
    final hasImage = widget.imageUrl != null && widget.imageUrl!.isNotEmpty;
    return InkWell(
      onTap: _uploading ? null : _pickAndUpload,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: _uploading
                ? const CircularProgressIndicator()
                : hasImage
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(widget.imageUrl!, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.add_a_photo_outlined, size: 40),
                          SizedBox(height: 8),
                          Text('Click to upload'),
                        ],
                      ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndUpload() async {
    if (!kIsWeb) return; // current stub supports web upload only
    final input = html.FileUploadInputElement()..accept = 'image/*';
    input.click();
    await input.onChange.first;
    final file = input.files?.first;
    if (file == null) return;
    setState(() => _uploading = true);
    try {
      final path = '${widget.storagePathPrefix}${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      final ref = FirebaseStorage.instance.ref().child(path);
      final task = ref.putBlob(file);
      await task.whenComplete(() {});
      final url = await ref.getDownloadURL();
      widget.onUploaded?.call(url);
      widget.onUploadedPath?.call(path);
      if (mounted) setState(() => _uploading = false);
    } catch (e) {
      if (mounted) {
        setState(() => _uploading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    }
  }
}


