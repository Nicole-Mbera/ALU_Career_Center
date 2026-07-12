import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/application_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class ApplicationProvider extends ChangeNotifier {
  final FirestoreService _db = FirestoreService();
  final StorageService _storage = StorageService();

  List<ApplicationModel> _applications = [];

  List<ApplicationModel> get all => _applications;

  List<ApplicationModel> byStatus(String status) =>
      _applications.where((a) => a.status == status).toList();

  void init(String studentUid) {
    _db.watchStudentApplications(studentUid).listen((apps) {
      _applications = apps;
      notifyListeners();
    });
  }

  Future<bool> apply({
    required String studentUid,
    required String opportunityId,
    required String startupId,
    required String opportunityTitle,
    required String startupName,
    required Uint8List cvBytes,
    required String cvName,
    required String coverLetter,
  }) async {
    final alreadyApplied = await _db.hasApplied(studentUid, opportunityId);
    if (alreadyApplied) return false;

    final cvUrl = await _storage.uploadCV(
      uid: studentUid,
      bytes: cvBytes,
      fileName: cvName,
    );

    final app = ApplicationModel(
      id: '',
      studentUid: studentUid,
      opportunityId: opportunityId,
      startupId: startupId,
      opportunityTitle: opportunityTitle,
      startupName: startupName,
      cvUrl: cvUrl,
      coverLetter: coverLetter,
      status: 'applied',
      appliedAt: DateTime.now(),
    );
    await _db.createApplication(app);
    return true;
  }

  bool hasAppliedLocally(String opportunityId) =>
      _applications.any((a) => a.opportunityId == opportunityId);
}
