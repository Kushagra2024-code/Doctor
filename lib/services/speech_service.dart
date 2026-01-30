import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

/// Speech-to-Text service using Google Speech-to-Text (FREE quota)
class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;

  /// Check if speech recognition is available
  bool get isAvailable => _isInitialized;

  /// Check if currently listening
  bool get isListening => _speech.isListening;

  /// Initialize speech recognition
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    // Request microphone permission
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      throw Exception('Microphone permission denied');
    }

    // Initialize speech recognition
    _isInitialized = await _speech.initialize(
      onError: (error) => print('Speech recognition error: $error'),
      onStatus: (status) => print('Speech recognition status: $status'),
    );

    return _isInitialized;
  }

  /// Start listening for speech
  Future<void> startListening({
    required Function(String) onResult,
    required Function(String) onPartialResult,
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        throw Exception('Failed to initialize speech recognition');
      }
    }

    if (_speech.isListening) {
      return; // Already listening
    }

    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          onResult(result.recognizedWords);
        } else {
          onPartialResult(result.recognizedWords);
        }
      },
      listenFor: const Duration(minutes: 5), // Max listen duration
      pauseFor: const Duration(seconds: 3), // Pause detection
      partialResults: true,
      cancelOnError: true,
      listenMode: stt.ListenMode.confirmation,
    );
  }

  /// Stop listening
  Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
  }

  /// Cancel listening
  Future<void> cancel() async {
    if (_speech.isListening) {
      await _speech.cancel();
    }
  }

  /// Dispose resources
  void dispose() {
    _speech.stop();
  }
}
