import 'package:flutter/material.dart';
import '../models/startup_model.dart';
import '../services/firestore_service.dart';

class AdminProvider extends ChangeNotifier {
  final FirestoreService _db = FirestoreService();

  List<StartupModel> _pending = [];

  List<StartupModel> get pending => _pending;

  void init() {
    _db.watchPendingStartups().listen((startups) {
      _pending = startups;
      notifyListeners();
    });
  }

  Future<void> approveStartup(String startupId) =>
      _db.updateStartupStatus(startupId, 'verified');

  Future<void> rejectStartup(String startupId, {String? reason}) =>
      _db.updateStartupStatus(startupId, 'rejected', reason: reason);
}
