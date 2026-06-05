import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Upload profile picture to Firebase Storage
  Future<String> uploadProfilePicture(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      // Create a reference to the location where we want to upload
      final String fileName = 'profile_pictures/${user.uid}.jpg';
      final Reference storageRef = _storage.ref().child(fileName);

      // Upload the file
      final UploadTask uploadTask = storageRef.putFile(imageFile);

      // Wait for the upload to complete and get the download URL
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } on FirebaseException catch (e) {
      throw _handleStorageException(e);
    }
  }

  // Delete profile picture from Firebase Storage
  Future<void> deleteProfilePicture() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      final String fileName = 'profile_pictures/${user.uid}.jpg';
      final Reference storageRef = _storage.ref().child(fileName);

      await storageRef.delete();
    } on FirebaseException catch (e) {
      // Ignore if file doesn't exist
      if (e.code != 'object-not-found') {
        throw _handleStorageException(e);
      }
    }
  }

  // Handle Firebase Storage exceptions
  String _handleStorageException(FirebaseException e) {
    switch (e.code) {
      case 'unauthorized':
        return 'You do not have permission to access this resource.';
      case 'canceled':
        return 'Upload was canceled.';
      case 'unknown':
        return 'An unknown error occurred.';
      case 'object-not-found':
        return 'No file found at this location.';
      case 'quota-exceeded':
        return 'Storage quota exceeded.';
      case 'unauthenticated':
        return 'User is not authenticated.';
      default:
        return 'Storage error: ${e.message}';
    }
  }
}
