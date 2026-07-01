import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceService {
  static final SpeechToText _speech = SpeechToText();
  static bool _available = false;

  static Future<bool> initialize() async {
    _available = await _speech.initialize(
      onError: (e) => debugPrint('STT error: $e'),
    );
    return _available;
  }

  static bool get isAvailable => _available;
  static bool get isListening => _speech.isListening;

  static Future<void> startListening({
    required void Function(String words) onResult,
    void Function()? onDone,
  }) async {
    if (!_available) return;
    await _speech.listen(
      onResult: (r) => onResult(r.recognizedWords),
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      partialResults: false,
    );
  }

  static Future<void> stopListening() => _speech.stop();
}
