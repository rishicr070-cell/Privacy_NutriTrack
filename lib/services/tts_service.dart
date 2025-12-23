import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.5); // Slightly slower for clarity
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      // Set voice quality
      if (defaultTargetPlatform == TargetPlatform.android) {
        await _flutterTts.setEngine("com.google.android.tts");
      }

      _isInitialized = true;
      debugPrint('✅ TTS Service initialized');
    } catch (e) {
      debugPrint('❌ TTS initialization error: $e');
    }
  }

  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Stop any ongoing speech
      await _flutterTts.stop();
      
      // Speak the text
      await _flutterTts.speak(text);
      debugPrint('🔊 Speaking: ${text.substring(0, text.length > 50 ? 50 : text.length)}...');
    } catch (e) {
      debugPrint('❌ TTS speak error: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      debugPrint('❌ TTS stop error: $e');
    }
  }

  Future<void> dispose() async {
    await _flutterTts.stop();
  }
}
