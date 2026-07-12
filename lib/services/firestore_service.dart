import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/startup_model.dart';
import '../models/opportunity_model.dart';
import '../models/application_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Users ────────────────────────────────────────────────────────────────

  Future<void> createUser(UserModel user) =>
      _db.collection('users').doc(user.uid).set(user.toMap());

  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromDoc(doc);
  }

  Future<void> updateUserSkills(String uid, List<String> skills) =>
      _db.collection('users').doc(uid).update({'skills': skills});

  Future<void> updateUserProfile(String uid, {String? bio, List<String>? skills}) {
    final data = <String, dynamic>{};
    if (bio != null) data['bio'] = bio;
    if (skills != null) data['skills'] = skills;
    return _db.collection('users').doc(uid).update(data);
  }

  Future<void> toggleBookmark(String uid, String oppId, bool isBookmarked) =>
      _db.collection('users').doc(uid).update({
        'bookmarkedOppIds': isBookmarked
            ? FieldValue.arrayRemove([oppId])
            : FieldValue.arrayUnion([oppId])
      });

  // ── Startups ─────────────────────────────────────────────────────────────

  Future<String> createStartup(StartupModel startup) async {
    final ref = await _db.collection('startups').add(startup.toMap());
    return ref.id;
  }

  Stream<StartupModel?> watchStartupByFounder(String founderUid) {
    return _db
        .collection('startups')
        .where('founderUid', isEqualTo: founderUid)
        .limit(1)
        .snapshots()
        .map((snap) =>
            snap.docs.isEmpty ? null : StartupModel.fromDoc(snap.docs.first));
  }

  Stream<List<StartupModel>> watchPendingStartups() {
    return _db
        .collection('startups')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snap) => snap.docs.map(StartupModel.fromDoc).toList());
  }

  Future<void> updateStartupStatus(String startupId, String status,
      {String? reason}) {
    final data = <String, dynamic>{'status': status};
    if (reason != null) data['rejectionReason'] = reason;
    return _db.collection('startups').doc(startupId).update(data);
  }

  // ── Opportunities ─────────────────────────────────────────────────────────

  Future<void> createOpportunity(OpportunityModel opp) =>
      _db.collection('opportunities').add(opp.toMap());

  Stream<List<OpportunityModel>> watchOpenOpportunities() {
    return _db
        .collection('opportunities')
        .where('status', isEqualTo: 'open')
        .snapshots()
        .map((snap) {
          final list = snap.docs.map(OpportunityModel.fromDoc).toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  Stream<List<OpportunityModel>> watchStartupOpportunities(String startupId) {
    return _db
        .collection('opportunities')
        .where('startupId', isEqualTo: startupId)
        .snapshots()
        .map((snap) {
          final list = snap.docs.map(OpportunityModel.fromDoc).toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  Future<void> updateOpportunityStatus(String oppId, String status) =>
      _db.collection('opportunities').doc(oppId).update({'status': status});

  Future<void> updateOpportunityFields(String oppId, Map<String, dynamic> data) =>
      _db.collection('opportunities').doc(oppId).update(data);

  Future<void> deleteOpportunity(String oppId) =>
      _db.collection('opportunities').doc(oppId).delete();

  // ── Applications ──────────────────────────────────────────────────────────

  Future<void> createApplication(ApplicationModel app) =>
      _db.collection('applications').add(app.toMap());

  Stream<List<ApplicationModel>> watchStudentApplications(String studentUid) {
    return _db
        .collection('applications')
        .where('studentUid', isEqualTo: studentUid)
        .snapshots()
        .map((snap) {
          final list = snap.docs.map(ApplicationModel.fromDoc).toList();
          list.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
          return list;
        });
  }

  Stream<List<ApplicationModel>> watchOpportunityApplications(
      String opportunityId) {
    return _db
        .collection('applications')
        .where('opportunityId', isEqualTo: opportunityId)
        .snapshots()
        .map((snap) => snap.docs.map(ApplicationModel.fromDoc).toList());
  }

  Stream<List<ApplicationModel>> watchStartupApplications(String startupId) {
    return _db
        .collection('applications')
        .where('startupId', isEqualTo: startupId)
        .snapshots()
        .map((snap) => snap.docs.map(ApplicationModel.fromDoc).toList());
  }

  Future<void> updateApplicationStatus(String appId, String status) =>
      _db.collection('applications').doc(appId).update({'status': status});

  Future<bool> hasApplied(String studentUid, String opportunityId) async {
    final snap = await _db
        .collection('applications')
        .where('studentUid', isEqualTo: studentUid)
        .where('opportunityId', isEqualTo: opportunityId)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }
}
