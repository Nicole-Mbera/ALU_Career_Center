import 'package:cloud_firestore/cloud_firestore.dart';

class ApplicationModel {
  final String id;
  final String studentUid;
  final String opportunityId;
  final String startupId;
  final String opportunityTitle;
  final String startupName;
  final String cvUrl;
  final String status; // 'applied' | 'under_review' | 'shortlisted' | 'accepted' | 'closed'
  final DateTime appliedAt;

  ApplicationModel({
    required this.id,
    required this.studentUid,
    required this.opportunityId,
    required this.startupId,
    required this.opportunityTitle,
    required this.startupName,
    required this.cvUrl,
    required this.status,
    required this.appliedAt,
  });

  factory ApplicationModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ApplicationModel(
      id: doc.id,
      studentUid: data['studentUid'] ?? '',
      opportunityId: data['opportunityId'] ?? '',
      startupId: data['startupId'] ?? '',
      opportunityTitle: data['opportunityTitle'] ?? '',
      startupName: data['startupName'] ?? '',
      cvUrl: data['cvUrl'] ?? '',
      status: data['status'] ?? 'applied',
      appliedAt: (data['appliedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'studentUid': studentUid,
        'opportunityId': opportunityId,
        'startupId': startupId,
        'opportunityTitle': opportunityTitle,
        'startupName': startupName,
        'cvUrl': cvUrl,
        'status': status,
        'appliedAt': Timestamp.fromDate(appliedAt),
      };

  String get statusLabel {
    switch (status) {
      case 'applied':
        return 'Applied';
      case 'under_review':
        return 'Under Review';
      case 'shortlisted':
        return 'Shortlisted';
      case 'accepted':
        return 'Accepted';
      case 'closed':
        return 'Closed';
      default:
        return status;
    }
  }
}
