import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration
class Env {
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static String get assemblyAiKey => dotenv.env['ASSEMBLY_AI_KEY'] ?? '';
  static String get razorpayKeyId => dotenv.env['RAZORPAY_KEY_ID'] ?? '';
  static String get razorpayKeySecret => dotenv.env['RAZORPAY_KEY_SECRET'] ?? '';

  static bool get hasGeminiKey => geminiApiKey.isNotEmpty && geminiApiKey != 'your_gemini_api_key_here';
  static bool get hasAssemblyAiKey => assemblyAiKey.isNotEmpty && assemblyAiKey != 'your_assembly_ai_key_here_optional';
  static bool get hasRazorpayKey => razorpayKeyId.isNotEmpty && razorpayKeyId != 'your_razorpay_key_id_here';

  /// Load environment variables
  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      print('Warning: Could not load .env file: $e');
    }
  }
}
