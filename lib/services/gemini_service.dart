import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/gemini_config.dart';
import '../models/doctor.dart';

/// Gemini AI service for medical conversations
class GeminiService {
  /// Emergency keywords that trigger immediate safety response
  static const List<String> emergencyKeywords = [
    'chest pain',
    'heart attack',
    'unconscious',
    'not breathing',
    'severe bleeding',
    'bleeding heavily',
    'suicidal',
    'kill myself',
    'end my life',
    'want to die',
    'hurt myself',
    'suicide',
    'overdose',
    'severe injury',
    'can\'t breathe',
    'difficulty breathing',
    'choking',
  ];

  /// Check if text contains emergency keywords
  static bool containsEmergencyKeyword(String text) {
    final lowerText = text.toLowerCase();
    return emergencyKeywords.any((keyword) => lowerText.contains(keyword));
  }

  /// Get emergency response based on context
  static String getEmergencyResponse(String text) {
    final lowerText = text.toLowerCase();

    if (lowerText.contains('chest pain') ||
        lowerText.contains('heart attack') ||
        lowerText.contains('chest pressure')) {
      return '⚠️ CARDIAC EMERGENCY ALERT ⚠️\n\n'
          'This may be a cardiac emergency. Please call 911 or your local '
          'emergency services IMMEDIATELY. Do not drive yourself to the hospital. '
          'If you have aspirin and are not allergic, chew one 325mg tablet while '
          'waiting for help.';
    }

    if (lowerText.contains('suicidal') ||
        lowerText.contains('kill myself') ||
        lowerText.contains('end my life') ||
        lowerText.contains('want to die') ||
        lowerText.contains('suicide')) {
      return '⚠️ MENTAL HEALTH CRISIS ALERT ⚠️\n\n'
          'I\'m very concerned about your safety. Please reach out for immediate help:\n\n'
          '🇺🇸 National Suicide Prevention Lifeline: 988\n'
          '🇺🇸 Crisis Text Line: Text "HELLO" to 741741\n'
          '🌍 International: Find your local crisis line at findahelpline.com\n'
          '🚨 Emergency: Call 911\n\n'
          'You matter, and help is available right now. Please don\'t face this alone.';
    }

    if (lowerText.contains('unconscious') ||
        lowerText.contains('not breathing') ||
        lowerText.contains('can\'t breathe') ||
        lowerText.contains('choking')) {
      return '⚠️ LIFE-THREATENING EMERGENCY ALERT ⚠️\n\n'
          'This is a medical emergency! Call 911 or your local emergency '
          'services IMMEDIATELY. Begin CPR if trained and the person is not '
          'breathing.';
    }

    // Generic emergency response
    return '⚠️ MEDICAL EMERGENCY ALERT ⚠️\n\n'
        'This may be a medical emergency. Please contact emergency services '
        'immediately:\n\n'
        '🇺🇸 Dial 911\n'
        '🇬🇧 Dial 999\n'
        '🇪🇺 Dial 112\n'
        'Or your local emergency number.\n\n'
        'Do not wait. Get immediate medical attention.';
  }

  /// Send message to Gemini with doctor's system prompt
  /// 
  /// Uses Gemini v1beta API with proper content structure:
  /// - Combines system prompt + conversation history + user message
  /// - Uses Content.text() format (NOT OpenAI-style messages)
  /// - Model automatically handles role and parts internally
  Future<String> sendMessage({
    required Doctor doctor,
    required String userMessage,
    List<String>? conversationHistory,
  }) async {
    try {
      // Check for emergency keywords first
      if (containsEmergencyKeyword(userMessage)) {
        return getEmergencyResponse(userMessage);
      }

      // Build the full prompt with system instructions and conversation history
      // Gemini API requires plain text input with context included
      final promptParts = <String>[];

      // Add system prompt (doctor's role and safety rules)
      promptParts.add('SYSTEM INSTRUCTIONS:\n${doctor.systemPrompt}\n');

      // Add conversation history if available
      if (conversationHistory != null && conversationHistory.isNotEmpty) {
        promptParts.add('\nCONVERSATION HISTORY:\n');
        promptParts.addAll(conversationHistory);
      }

      // Add current user message
      promptParts.add('\nUSER: $userMessage\n\nASSISTANT:');

      final prompt = promptParts.join('\n');

      // Generate response using Gemini v1beta API
      // The google_generative_ai package handles:
      // - REST endpoint: POST /v1beta/models/gemini-1.5-flash:generateContent
      // - Request body: { "contents": [{ "parts": [{ "text": "..." }] }] }
      final model = GeminiConfig.model;
      final response = await model.generateContent([Content.text(prompt)]);

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Empty response from Gemini');
      }

      return response.text!.trim();
    } on GenerativeAIException catch (e) {
      // Specific Gemini API errors with detailed logging
      print('Gemini API Error Details:');
      print('Message: ${e.message}');
      print('User input: $userMessage');
      
      // User-friendly error message
      if (e.message.contains('not found') || e.message.contains('not supported')) {
        throw Exception(
          'Gemini model unavailable. The API version or model may have changed. '
          'Please check for updates or try again later.'
        );
      }
      throw Exception('Gemini API error: ${e.message}');
    } catch (e) {
      if (e.toString().contains('API key')) {
        throw Exception(
          'Gemini API key error. Please check your .env file.\n'
          'Get your free API key from: https://makersuite.google.com/app/apikey',
        );
      }
      throw Exception('Failed to get AI response: ${e.toString()}');
    }
  }

  /// Generate medical report from conversation
  Future<Map<String, dynamic>> generateReport({
    required Doctor doctor,
    required String fullTranscript,
  }) async {
    try {
      final prompt = '''Based on this medical consultation conversation, generate a structured medical report.

CONVERSATION:
$fullTranscript

Generate a JSON report with the following structure:
{
  "summary": "Brief summary of the consultation (2-3 sentences)",
  "symptoms": ["list", "of", "mentioned", "symptoms"],
  "possible_causes": ["general", "possible", "causes", "mentioned"],
  "advice": ["list", "of", "advice", "given"],
  "emergency_warning": "Any emergency warning or empty string if none"
}

IMPORTANT: 
- Only include information actually discussed
- Do not add medical diagnoses
- Keep it factual and based on the conversation
- Return ONLY valid JSON, no additional text''';

      final model = GeminiConfig.model;
      final response = await model.generateContent([Content.text(prompt)]);

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Empty response from Gemini');
      }

      // Try to parse the JSON response
      String jsonText = response.text!.trim();

      // Remove markdown code blocks if present
      if (jsonText.startsWith('```json')) {
        jsonText = jsonText.replaceFirst('```json', '').replaceFirst('```', '').trim();
      } else if (jsonText.startsWith('```')) {
        jsonText = jsonText.replaceFirst('```', '').replaceFirst('```', '').trim();
      }

      // Parse JSON
      try {
        final json = parseJsonReport(jsonText);
        return json;
      } catch (e) {
        // If JSON parsing fails, return a default structure
        return {
          'summary': 'Consultation completed with ${doctor.name}',
          'symptoms': <String>[],
          'possible_causes': <String>[],
          'advice': ['Consult with a real healthcare provider for proper medical advice'],
          'emergency_warning': '',
        };
      }
    } catch (e) {
      throw Exception('Failed to generate report: ${e.toString()}');
    }
  }

  /// Parse JSON report with error handling
  Map<String, dynamic> parseJsonReport(String jsonText) {
    // Simple JSON parser for the report structure
    // This is a fallback in case the AI doesn't return perfect JSON

    final Map<String, dynamic> result = {
      'summary': '',
      'symptoms': <String>[],
      'possible_causes': <String>[],
      'advice': <String>[],
      'emergency_warning': '',
    };

    try {
      // Try to extract summary
      final summaryMatch = RegExp(r'"summary"\s*:\s*"([^"]*)"').firstMatch(jsonText);
      if (summaryMatch != null) {
        result['summary'] = summaryMatch.group(1) ?? '';
      }

      // Try to extract arrays
      result['symptoms'] = _extractArray(jsonText, 'symptoms');
      result['possible_causes'] = _extractArray(jsonText, 'possible_causes');
      result['advice'] = _extractArray(jsonText, 'advice');

      // Try to extract emergency warning
      final warningMatch = RegExp(r'"emergency_warning"\s*:\s*"([^"]*)"').firstMatch(jsonText);
      if (warningMatch != null) {
        result['emergency_warning'] = warningMatch.group(1) ?? '';
      }

      return result;
    } catch (e) {
      return result; // Return default structure on error
    }
  }

  /// Extract array from JSON text
  List<String> _extractArray(String jsonText, String fieldName) {
    final arrayMatch = RegExp('\"$fieldName\"\\s*:\\s*\\[([^\\]]*)\\]').firstMatch(jsonText);
    if (arrayMatch == null) return [];

    final arrayContent = arrayMatch.group(1) ?? '';
    final items = arrayContent.split(',').map((item) {
      return item.trim().replaceAll('"', '').replaceAll("'", '');
    }).where((item) => item.isNotEmpty).toList();

    return items;
  }
}
