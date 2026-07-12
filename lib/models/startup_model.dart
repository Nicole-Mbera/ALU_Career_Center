import 'package:cloud_firestore/cloud_firestore.dart';

class StartupModel {
  final String id;
  final String founderUid;
  final String name;
  final String description;
  final String certUrl;
  final String status; // 'pending' | 'verified' | 'rejected'
  final String? rejectionReason;
  final DateTime createdAt;

  StartupModel({
    required this.id,
    required this.founderUid,
    required this.name,
    required this.description,
    required this.certUrl,
    required this.status,
    this.rejectionReason,
    required this.createdAt,
  });

  bool get isPending => status == 'pending';
  bool get isVerified => status == 'verified';
  bool get isRejected => status == 'rejected';

  factory StartupModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StartupModel(
      id: doc.id,
      founderUid: data['founderUid'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      certUrl: data['certUrl'] ?? '',
      status: data['status'] ?? 'pending',
      rejectionReason: data['rejectionReason'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'founderUid': founderUid,
        'name': name,
        'description': description,
        'certUrl': certUrl,
        'status': status,
        if (rejectionReason != null) 'rejectionReason': rejectionReason,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
