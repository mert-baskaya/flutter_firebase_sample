class UserProfile {
  final String uid;
  final int? age;
  final double? height;
  final double? weight;
  final String? gender;
  final bool onboardingCompleted;

  UserProfile({
    required this.uid,
    this.age,
    this.height,
    this.weight,
    this.gender,
    this.onboardingCompleted = false,
  });

  // Convert UserProfile to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'age': age,
      'height': height,
      'weight': weight,
      'gender': gender,
      'onboardingCompleted': onboardingCompleted,
    };
  }

  // Create UserProfile from Firestore document
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] as String,
      age: map['age'] as int?,
      height: map['height'] != null ? (map['height'] as num).toDouble() : null,
      weight: map['weight'] != null ? (map['weight'] as num).toDouble() : null,
      gender: map['gender'] as String?,
      onboardingCompleted: map['onboardingCompleted'] as bool? ?? false,
    );
  }

  // Create a copy with updated fields
  UserProfile copyWith({
    String? uid,
    int? age,
    double? height,
    double? weight,
    String? gender,
    bool? onboardingCompleted,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      gender: gender ?? this.gender,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }
}
