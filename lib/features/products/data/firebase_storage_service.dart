import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class FirebaseStorageService {
  static const String _productImagesPath = 'products/images';
  static const String _userProfilesPath = 'users/profiles';
  static const String _reviewsPath = 'reviews/images';

  final FirebaseStorage _storage;

  FirebaseStorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  Future<String> uploadProductImage({
    required String productId,
    required File imageFile,
    required String fileName,
  }) async {
    try {
      final ref = _storage
          .ref()
          .child(_productImagesPath)
          .child(productId)
          .child(fileName);
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      throw FirebaseStorageException('Failed to upload product image: $e');
    }
  }

  Future<String> uploadUserProfileImage({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final ref = _storage
          .ref()
          .child(_userProfilesPath)
          .child(userId)
          .child('profile.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      throw FirebaseStorageException('Failed to upload profile image: $e');
    }
  }

  Future<String> uploadReviewImage({
    required String reviewId,
    required File imageFile,
  }) async {
    try {
      final ref = _storage
          .ref()
          .child(_reviewsPath)
          .child(reviewId)
          .child('image.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      throw FirebaseStorageException('Failed to upload review image: $e');
    }
  }

  Future<void> deleteFile(String filePath) async {
    try {
      final ref = _storage.ref().child(filePath);
      await ref.delete();
    } catch (e) {
      throw FirebaseStorageException('Failed to delete file: $e');
    }
  }

  Future<String> getDownloadURL(String filePath) async {
    try {
      return await _storage.ref().child(filePath).getDownloadURL();
    } catch (e) {
      throw FirebaseStorageException('Failed to get download URL: $e');
    }
  }

  Future<void> deleteProductImages(String productId) async {
    try {
      final ref = _storage.ref().child(_productImagesPath).child(productId);
      final items = await ref.listAll();
      for (var item in items.items) {
        await item.delete();
      }
    } catch (e) {
      throw FirebaseStorageException('Failed to delete product images: $e');
    }
  }
}

class FirebaseStorageException implements Exception {
  final String message;
  FirebaseStorageException(this.message);

  @override
  String toString() => message;
}
