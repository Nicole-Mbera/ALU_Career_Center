import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // 'student' | 'founder'
  final String campus; // 'Kigali' | 'Mauritius'
  final String bio;
  final List<String> skills;
  final List<String> bookmarkedOppIds;
  final bool isAdmin;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.campus,
    this.bio = '',
    required this.skills,
    this.bookmarkedOppIds = const [],
    this.isAdmin = false,
    required this.createdAt,
  });

  bool get isStudent => role == 'student';
  bool get isFounder => role == 'founder';

  factory UserModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'student',
      campus: data['campus'] ?? 'Kigali',
      bio: data['bio'] ?? '',
      skills: List<String>.from(data['skills'] ?? []),
      bookmarkedOppIds: List<String>.from(data['bookmarkedOppIds'] ?? []),
      isAdmin: data['isAdmin'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'email': email,
        'role': role,
        'campus': campus,
        'bio': bio,
        'skills': skills,
        'bookmarkedOppIds': bookmarkedOppIds,
        'isAdmin': isAdmin,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  UserModel copyWith({String? bio, List<String>? skills}) {
    return UserModel(
      uid: uid,
      name: name,
      email: email,
      role: role,
      campus: campus,
      bio: bio ?? this.bio,
      skills: skills ?? this.skills,
      bookmarkedOppIds: bookmarkedOppIds,
      isAdmin: isAdmin,
      createdAt: createdAt,
    );
  }
}
