import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/report.dart';
import '../models/doctor.dart';
import 'gemini_service.dart';
import 'auth_service.dart';

/// Medical report service using local storage (Firestore optional)
/// 
/// NOTE: For demo purposes, reports are stored in memory.
/// To enable Firestore storage, update Firebase security rules:
/// https://console.firebase.google.com/project/doctor-4dfc5/firestore/rules
/// 
/// Example rules:
/// ```
/// rules_version = '2';
/// service cloud.firestore {
///   match /databases/{database}/documents {
///     match /reports/{reportId} {
///       allow read, write: if request.auth != null;
///     }
///   }
/// }
/// ```
class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GeminiService _geminiService = GeminiService();
  final AuthService _authService = AuthService();
  final Uuid _uuid = const Uuid();
  
  static const String _reportsKey = 'medical_reports';
  
  /// Load reports from SharedPreferences
  Future<List<MedicalReport>> _loadLocalReports() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_reportsKey);
      if (jsonString == null) return [];
      
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => MedicalReport.fromJson(json)).toList();
    } catch (e) {
      print('Error loading local reports: $e');
      return [];
    }
  }
  
  /// Save reports to SharedPreferences
  Future<void> _saveLocalReports(List<MedicalReport> reports) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = reports.map((r) => r.toJson()).toList();
      await prefs.setString(_reportsKey, json.encode(jsonList));
    } catch (e) {
      print('Error saving local reports: $e');
    }
  }

  /// Generate and save report
  Future<MedicalReport> generateAndSaveReport({
    required Doctor doctor,
    required String fullTranscript,
  }) async {
    try {
      // Generate report using Gemini
      final reportData = await _geminiService.generateReport(
        doctor: doctor,
        fullTranscript: fullTranscript,
      );

      // Get current user ID
      final userId = _authService.currentUser?.uid ?? 'anonymous';

      // Create report object
      final report = MedicalReport(
        id: _uuid.v4(),
        userId: userId,
        doctorId: doctor.id,
        doctorName: doctor.name,
        timestamp: DateTime.now(),
        summary: reportData['summary'] as String,
        symptoms: List<String>.from(reportData['symptoms'] as List),
        possibleCauses: List<String>.from(reportData['possible_causes'] as List),
        advice: List<String>.from(reportData['advice'] as List),
        emergencyWarning: reportData['emergency_warning'] as String,
        fullTranscript: fullTranscript,
      );

      // Save to local persistent storage
      final localReports = await _loadLocalReports();
      localReports.add(report);
      await _saveLocalReports(localReports);
      print('✅ Report saved to persistent local storage. ID: ${report.id}');
      
      // Try to save to Firestore (optional, will fail gracefully if permissions denied)
      try {
        await _firestore.collection('reports').doc(report.id).set(report.toJson());
        print('✅ Report also saved to Firestore');
      } catch (firestoreError) {
        print('⚠️ Firestore save failed (local storage active): $firestoreError');
        // Continue anyway - local storage is sufficient
      }

      return report;
    } catch (e) {
      throw Exception('Failed to generate report: ${e.toString()}');
    }
  }

  /// Get user's reports
  Future<List<MedicalReport>> getUserReports() async {
    final userId = _authService.currentUser?.uid;
    
    // Load from local persistent storage
    final localReports = await _loadLocalReports();
    
    if (userId == null) {
      return localReports..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }

    // Filter by user and sort
    final userReports = localReports
        .where((report) => report.userId == userId)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Try to get from Firestore as well (if available)
    try {
      final querySnapshot = await _firestore
          .collection('reports')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      final firestoreReports = querySnapshot.docs
          .map((doc) => MedicalReport.fromJson(doc.data()))
          .toList();
      
      // Merge with local reports (avoid duplicates)
      final allReportsMap = {for (var r in userReports) r.id: r};
      for (var r in firestoreReports) {
        allReportsMap[r.id] = r;
      }
      
      return allReportsMap.values.toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      print('⚠️ Firestore fetch failed (using local storage): $e');
    }
    
    return userReports;
  }

  /// Get report by ID
  Future<MedicalReport?> getReportById(String reportId) async {
    // Check local persistent storage first
    final localReports = await _loadLocalReports();
    try {
      final localReport = localReports.firstWhere((r) => r.id == reportId);
      return localReport;
    } catch (e) {
      // Not found locally, try Firestore
    }

    // Try Firestore
    try {
      final docSnapshot = await _firestore.collection('reports').doc(reportId).get();
      if (!docSnapshot.exists) return null;
      return MedicalReport.fromJson(docSnapshot.data()!);
    } catch (e) {
      print('Error fetching report: $e');
      return null;
    }
  }

  /// Delete report
  Future<void> deleteReport(String reportId) async {
    // Remove from local persistent storage
    final localReports = await _loadLocalReports();
    localReports.removeWhere((r) => r.id == reportId);
    await _saveLocalReports(localReports);
    print('✅ Report deleted from local storage');
    
    // Try to delete from Firestore
    try {
      await _firestore.collection('reports').doc(reportId).delete();
      print('✅ Report also deleted from Firestore');
    } catch (e) {
      print('⚠️ Could not delete from Firestore: $e');
      // Local deletion still succeeded
    }
  }
}
