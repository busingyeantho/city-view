import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class FileUploader {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads a file to Firebase Storage and returns the download URL
  static Future<String?> uploadFile({
    required File file,
    required String folder,
    String? fileName,
  }) async {
    try {
      final String name = fileName ?? '${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}';
      final Reference storageRef = _storage.ref().child('$folder/$name');
      final UploadTask uploadTask = storageRef.putFile(file);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  /// Deletes a file from Firebase Storage
  static Future<bool> deleteFile(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
      return true;
    } catch (e) {
      print('Error deleting file: $e');
      return false;
    }
  }
}

/// A service for handling image picking and uploading
class ImageUploadService {
  /// Picks an image from the device and uploads it to Firebase Storage
  static Future<String?> pickAndUploadImage({
    required String folder,
  }) async {
    // TODO: Implement image picking
    // For now, we'll just return a placeholder
    return null;
  }
}
