import 'package:cloud_firestore/cloud_firestore.dart';

class OpportunityModel {
  final String id;
  final String startupId;
  final String startupName;
  final String title;
  final String category;
  final List<String> skills;
  final String commitment;
  final String location;
  final String description;
  final String status; // 'draft' | 'open' | 'closed'
  final DateTime createdAt;

  OpportunityModel({
    required this.id,
    required this.startupId,
    required this.startupName,
    required this.title,
    required this.category,
    required this.skills,
    required this.commitment,
    required this.location,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  bool get isOpen => status == 'open';

  factory OpportunityModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OpportunityModel(
      id: doc.id,
      startupId: data['startupId'] ?? '',
      startupName: data['startupName'] ?? '',
      title: data['title'] ?? '',
      category: data['category'] ?? '',
      skills: List<String>.from(data['skills'] ?? []),
      commitment: data['commitment'] ?? '',
      location: data['location'] ?? '',
      description: data['description'] ?? '',
      status: data['status'] ?? 'draft',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'startupId': startupId,
        'startupName': startupName,
        'title': title,
        'category': category,
        'skills': skills,
        'commitment': commitment,
        'location': location,
        'description': description,
        'status': status,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}

const List<String> kCategories = [
  'All',
  'Engineering',
  'Design',
  'Marketing',
  'Data',
  'Operations',
  'Other',
];
