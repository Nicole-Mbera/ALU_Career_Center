import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/startup_model.dart';
import '../models/opportunity_model.dart';
import '../models/application_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class StartupProvider extends ChangeNotifier {
  final FirestoreService _db = FirestoreService();
  final StorageService _storage = StorageService();

  StartupModel? _startup;
  List<OpportunityModel> _opportunities = [];
  List<ApplicationModel> _applications = [];

  StartupModel? get startup => _startup;
  List<OpportunityModel> get opportunities => _opportunities;
  List<ApplicationModel> get applications => _applications;

  void init(String founderUid) {
    _db.watchStartupByFounder(founderUid).listen((s) {
      _startup = s;
      if (s != null) {
        _listenToOpportunities(s.id);
        _listenToApplications(s.id);
      }
      notifyListeners();
    });
  }

  void _listenToOpportunities(String startupId) {
    _db.watchStartupOpportunities(startupId).listen((opps) {
      _opportunities = opps;
      notifyListeners();
    });
  }

  void _listenToApplications(String startupId) {
    _db.watchStartupApplications(startupId).listen((apps) {
      _applications = apps;
      notifyListeners();
    });
  }

  Future<void> createStartup({
  required String founderUid,
  required String name,
  required String description,
  required Uint8List certBytes, //  Updated parameter type
  required String certName,     //  Updated parameter type
}) async {
  final tempId = DateTime.now().millisecondsSinceEpoch.toString();

  // Upload bytes to Firebase Storage
  final certUrl = await _storage.uploadCertificate(
    id: tempId, 
    bytes: certBytes, 
    fileName: certName,
  );

  final startup = StartupModel(
    id: '',
    founderUid: founderUid,
    name: name,
    description: description,
    certUrl: certUrl,
    status: 'pending',
    createdAt: DateTime.now(),
  );
  await _db.createStartup(startup);
}


  Future<void> postOpportunity({
    required String title,
    required String category,
    required List<String> skills,
    required String commitment,
    required String location,
    required String description,
    required String benefits,
  }) async {
    if (_startup == null) return;
    final opp = OpportunityModel(
      id: '',
      startupId: _startup!.id,
      startupName: _startup!.name,
      title: title,
      category: category,
      skills: skills,
      commitment: commitment,
      location: location,
      description: description,
      benefits: benefits,
      status: _startup!.isVerified ? 'open' : 'draft',
      createdAt: DateTime.now(),
    );
    await _db.createOpportunity(opp);
  }

  Future<void> updateOpportunity({
    required String id,
    required String title,
    required String category,
    required List<String> skills,
    required String commitment,
    required String location,
    required String description,
    required String benefits,
  }) async {
    await _db.updateOpportunityFields(id, {
      'title': title,
      'category': category,
      'skills': skills,
      'commitment': commitment,
      'location': location,
      'description': description,
      'benefits': benefits,
    });
  }

  Future<void> toggleOpportunityStatus(OpportunityModel opp) async {
    final newStatus = opp.status == 'open' ? 'closed' : 'open';
    await _db.updateOpportunityStatus(opp.id, newStatus);
  }

  Future<void> deleteOpportunity(String oppId) =>
      _db.deleteOpportunity(oppId);

  Future<void> updateApplicationStatus(String appId, String status) =>
      _db.updateApplicationStatus(appId, status);

  List<ApplicationModel> applicantsFor(String opportunityId) =>
      _applications.where((a) => a.opportunityId == opportunityId).toList();
}
