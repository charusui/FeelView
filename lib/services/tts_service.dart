import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';
import 'piper_web_stub.dart' if (dart.library.html) 'piper_web_real.dart' as piper_web;

class TtsService {
  static final FlutterTts _tts = FlutterTts();
  static final AudioPlayer _player = AudioPlayer();
  static bool _initialized = false;
  static bool useNeuralCloudVoice = true;

  static Future<void> _init() async {
    if (_initialized) return;
    await _tts.setLanguage('en-US');

    try {
      final voices = await _tts.getVoices;
      if (voices != null && voices is List) {
        Map<String, String>? bestVoice;
        int highestScore = -1;

        for (final v in voices) {
          if (v is Map || v is Map<Object?, Object?>) {
            final name = (v['name'] ?? '').toString().toLowerCase();
            final locale = (v['locale'] ?? '').toString().toLowerCase();

            if (locale.contains('en') || name.contains('english') || name.contains('en-')) {
              int score = 0;
              if (name.contains('amy')) score += 150;
              if (name.contains('en_us-amy')) score += 200;
              if (name.contains('piper')) score += 100;
              if (name.contains('natural')) score += 50;
              if (name.contains('neural')) score += 50;
              if (name.contains('online')) score += 40;
              if (name.contains('premium')) score += 40;
              if (name.contains('enhanced')) score += 35;
              if (name.contains('aria') || name.contains('guy') || name.contains('jenny')) score += 30;
              if (name.contains('google')) score += 25;
              if (name.contains('siri') || name.contains('samantha')) score += 25;
              if (name.contains('david') || name.contains('zira') || name.contains('mark')) score -= 20;

              if (score > highestScore) {
                highestScore = score;
                bestVoice = {
                  'name': v['name'].toString(),
                  'locale': v['locale'].toString(),
                };
              }
            }
          }
        }

        if (bestVoice != null && highestScore > 0) {
          await _tts.setVoice(bestVoice);
        }
      }
    } catch (_) {}

    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.02);
    _initialized = true;
  }

  static Future<void> speak(String text) async {
    await _init();
    await stop();

    if (useNeuralCloudVoice) {
      if (kIsWeb) {
        final success = await piper_web.speakPiperInBrowser(text);
        if (success) return;
      } else {
        try {
          final url = 'https://translate.google.com/translate_tts?ie=UTF-8&client=tw-ob&q=${Uri.encodeComponent(text)}&tl=en';
          await _player.setUrl(url).timeout(const Duration(seconds: 2));
          await _player.play().timeout(const Duration(seconds: 5));
          return;
        } catch (e) {
          debugPrint('Cloud TTS failed or timed out, falling back to local/native TTS: $e');
        }
      }
    }

    await _tts.speak(text);
  }

  static Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}
    try {
      await _tts.stop();
    } catch (_) {}
  }

  static Future<void> setRate(double rate) => _tts.setSpeechRate(rate);
  static Future<void> setVolume(double vol) => _tts.setVolume(vol);
}
