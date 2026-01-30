import 'package:intl/intl.dart';

/// Medical consultation report model
class MedicalReport {
  final String id;
  final String userId;
  final String doctorId;
  final String doctorName;
  final DateTime timestamp;
  final String summary;
  final List<String> symptoms;
  final List<String> possibleCauses;
  final List<String> advice;
  final String emergencyWarning;
  final String fullTranscript;

  const MedicalReport({
    required this.id,
    required this.userId,
    required this.doctorId,
    required this.doctorName,
    required this.timestamp,
    required this.summary,
    required this.symptoms,
    required this.possibleCauses,
    required this.advice,
    required this.emergencyWarning,
    required this.fullTranscript,
  });

  String get formattedDate => DateFormat('MMM dd, yyyy - hh:mm a').format(timestamp);

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'doctorId': doctorId,
        'doctorName': doctorName,
        'timestamp': timestamp.toIso8601String(),
        'summary': summary,
        'symptoms': symptoms,
        'possibleCauses': possibleCauses,
        'advice': advice,
        'emergencyWarning': emergencyWarning,
        'fullTranscript': fullTranscript,
      };

  factory MedicalReport.fromJson(Map<String, dynamic> json) => MedicalReport(
        id: json['id'] as String,
        userId: json['userId'] as String,
        doctorId: json['doctorId'] as String,
        doctorName: json['doctorName'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        summary: json['summary'] as String,
        symptoms: List<String>.from(json['symptoms'] as List),
        possibleCauses: List<String>.from(json['possibleCauses'] as List),
        advice: List<String>.from(json['advice'] as List),
        emergencyWarning: json['emergencyWarning'] as String,
        fullTranscript: json['fullTranscript'] as String,
      );
}
