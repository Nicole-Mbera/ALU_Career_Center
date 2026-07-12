import 'package:flutter/material.dart';
import '../models/opportunity_model.dart';
import '../services/firestore_service.dart';

class OpportunityProvider extends ChangeNotifier {
  final FirestoreService _db = FirestoreService();

  List<OpportunityModel> _all = [];
  String _searchQuery = '';
  String _categoryFilter = 'All';
  String _campusFilter = 'All';
  List<String> _studentSkills = [];

  List<OpportunityModel> get all => _all;
  String get searchQuery => _searchQuery;
  String get categoryFilter => _categoryFilter;
  String get campusFilter => _campusFilter;

  List<OpportunityModel> get filtered {
    return _all.where((o) {
      final matchesSearch = _searchQuery.isEmpty ||
          o.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          o.skills.any((s) =>
              s.toLowerCase().contains(_searchQuery.toLowerCase()));
      final matchesCategory =
          _categoryFilter == 'All' || o.category == _categoryFilter;
      final matchesCampus =
          _campusFilter == 'All' || o.location.contains(_campusFilter);
      return matchesSearch && matchesCategory && matchesCampus;
    }).toList();
  }

  List<OpportunityModel> get recommended {
    final sorted = List<OpportunityModel>.from(_all);
    sorted.sort(
        (a, b) => matchScore(b.skills).compareTo(matchScore(a.skills)));
    return sorted.take(5).toList();
  }

  void init(List<String> studentSkills) {
    _studentSkills = studentSkills;
    _db.watchOpenOpportunities().listen((opps) {
      _all = opps;
      notifyListeners();
    });
  }

  void updateStudentSkills(List<String> skills) {
    _studentSkills = skills;
    notifyListeners();
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String category) {
    _categoryFilter = category;
    notifyListeners();
  }

  void setCampus(String campus) {
    _campusFilter = campus;
    notifyListeners();
  }

  double matchScore(List<String> requiredSkills) {
    if (requiredSkills.isEmpty) return 1.0;
    final matched = requiredSkills
        .where((s) => _studentSkills.contains(s))
        .length;
    return matched / requiredSkills.length;
  }

  List<String> matchedSkills(List<String> requiredSkills) =>
      requiredSkills.where((s) => _studentSkills.contains(s)).toList();

  List<String> missingSkills(List<String> requiredSkills) =>
      requiredSkills.where((s) => !_studentSkills.contains(s)).toList();
}
