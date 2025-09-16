import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Base class for admin screens with common functionality
abstract class BaseAdminScreen extends StatefulWidget {
  final String title;
  final String collectionName;
  final String? documentId;
  
  const BaseAdminScreen({
    Key? key,
    required this.title,
    required this.collectionName,
    this.documentId,
  }) : super(key: key);

  @override
  State<BaseAdminScreen> createState();
}

/// State class for [BaseAdminScreen]
abstract class BaseAdminScreenState<T extends BaseAdminScreen> extends State<T> {
  bool _isLoading = false;
  String? _errorMessage;

  /// Get Firestore collection reference
  CollectionReference<Map<String, dynamic>> get collectionRef =>
      FirebaseFirestore.instance.collection(widget.collectionName);

  /// Get document reference if documentId is provided
  DocumentReference<Map<String, dynamic>>? get documentRef =>
      widget.documentId != null 
          ? collectionRef.doc(widget.documentId)
          : null;

  /// Build the main content of the screen
  Widget buildContent(BuildContext context);

  /// Build loading state
  Widget buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  /// Build error state
  Widget buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          message,
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// Execute an async operation with loading and error handling
  Future<void> executeWithLoader(Future<void> Function() operation) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await operation();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      rethrow;
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Show a message to the user
  void showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _isLoading
          ? buildLoading()
          : _errorMessage != null
              ? buildError(_errorMessage!)
              : buildContent(context),
    );
  }
}

/// Base class for list screens
class BaseListAdminScreen extends BaseAdminScreen {
  final Widget Function(
    BuildContext context, 
    DocumentSnapshot<Map<String, dynamic>> doc, 
    int index
  ) itemBuilder;
  
  final Query<Map<String, dynamic>>? initialQuery;
  final String collectionName;

  const BaseListAdminScreen({
    Key? key,
    required String title,
    required this.collectionName,
    required this.itemBuilder,
    this.initialQuery,
  }) : super(
          key: key, 
          title: title, 
          collectionName: collectionName,
        );

  @override
  State<BaseListAdminScreen> createState() => _BaseListAdminScreenState();
}

class _BaseListAdminScreenState extends BaseAdminScreenState<BaseListAdminScreen> {
  late Query<Map<String, dynamic>> _query;

  late final CollectionReference<Map<String, dynamic>> _collectionRef;
  
  @override
  void initState() {
    super.initState();
    _collectionRef = FirebaseFirestore.instance.collection(widget.collectionName);
    _query = widget.initialQuery ?? _collectionRef;
  }

  @override
  Widget buildContent(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return buildLoading();
        }

        if (snapshot.hasError) {
          return buildError('Failed to load items: ${snapshot.error}');
        }

        final docs = snapshot.data?.docs ?? [];
        
        if (docs.isEmpty) {
          return const Center(child: Text('No items found'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) => 
              widget.itemBuilder(context, docs[index], index),
        );
      },
    );
  }
}
