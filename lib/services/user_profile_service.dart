import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class UserProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference
  CollectionReference get _usersCollection => _firestore.collection('users');

  // Create or update user profile
  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      await _usersCollection.doc(profile.uid).set(profile.toMap());
    } catch (e) {
      throw Exception('Failed to save user profile: $e');
    }
  }

  // Get user profile
  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (doc.exists) {
        return UserProfile.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  // Stream user profile changes
  Stream<UserProfile?> getUserProfileStream(String uid) {
    return _usersCollection.doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserProfile.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  // Update specific fields
  Future<void> updateUserProfile(
    String uid,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _usersCollection.doc(uid).update(updates);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // Check if user has completed onboarding
  Future<bool> hasCompletedOnboarding(String uid) async {
    try {
      final profile = await getUserProfile(uid);
      return profile?.onboardingCompleted ?? false;
    } catch (e) {
      return false;
    }
  }

  // Mark onboarding as completed
  Future<void> completeOnboarding(String uid) async {
    try {
      await _usersCollection.doc(uid).update({'onboardingCompleted': true});
    } catch (e) {
      throw Exception('Failed to complete onboarding: $e');
    }
  }
}
