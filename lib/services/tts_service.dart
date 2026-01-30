import 'package:flutter_tts/flutter_tts.dart';

/// Text-to-Speech service using Flutter TTS (FREE)
class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;

  /// Initialize TTS
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.5); // Natural speaking rate
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);

      // Set iOS-specific properties
      await _tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        ],
        IosTextToSpeechAudioMode.voicePrompt,
      );

      _isInitialized = true;
    } catch (e) {
      print('TTS initialization error: $e');
    }
  }

  /// Speak text
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await _tts.speak(text);
    } catch (e) {
      print('TTS speak error: $e');
    }
  }

  /// Stop speaking
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (e) {
      print('TTS stop error: $e');
    }
  }

  /// Check if currently speaking
  Future<bool> isSpeaking() async {
    try {
      final speaking = await _tts.awaitSpeakCompletion(true);
      return speaking;
    } catch (e) {
      return false;
    }
  }

  /// Set voice pitch (1.0 = default, higher = higher pitch)
  Future<void> setPitch(double pitch) async {
    try {
      await _tts.setPitch(pitch);
    } catch (e) {
      print('TTS setPitch error: $e');
    }
  }

  /// Set speech rate (0.5 = slow, 1.0 = normal, 2.0 = fast)
  Future<void> setRate(double rate) async {
    try {
      await _tts.setSpeechRate(rate);
    } catch (e) {
      print('TTS setRate error: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _tts.stop();
  }
}
