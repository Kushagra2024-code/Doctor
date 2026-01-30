import 'package:google_generative_ai/google_generative_ai.dart';
import 'env.dart';

/// Gemini AI configuration
/// 
/// IMPORTANT: Model Name Fix
/// - OLD (deprecated): 'gemini-pro' or 'models/gemini-pro' - Not available in v1beta API
/// - NEW (current): 'gemini-1.5-flash' - Fast, efficient, free tier model
/// - Alternative: 'gemini-1.5-pro' - More capable but may have rate limits
/// 
/// The google_generative_ai package automatically adds 'models/' prefix,
/// so we only specify the model name without prefix.
class GeminiConfig {
  static GenerativeModel? _model;

  /// Get configured Gemini model instance
  static GenerativeModel get model {
    if (_model != null) return _model!;

    if (!Env.hasGeminiKey) {
      throw Exception(
        'Gemini API key not configured. Please add your API key to .env file.\n'
        'Get your free API key from: https://makersuite.google.com/app/apikey',
      );
    }

    // Using gemini-1.5-flash (latest stable model for v1beta API)
    // This model is:
    // - Available in API version v1beta
    // - Fast and efficient
    // - Free tier compatible
    // - Supports generateContent method
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: Env.geminiApiKey,
      generationConfig: GenerationConfig(
        temperature: 0.4,  // More focused responses for medical context
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 500,  // Reasonable length for medical advice
      ),
    );

    return _model!;
  }

  /// Reset model instance (useful for testing or API key changes)
  static void reset() {
    _model = null;
  }
}
