import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

/// Supported languages for Text-to-Speech health alerts
class TtsLanguage {
  final String code;
  final String name;
  final String nativeName;

  const TtsLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
  });

  static const List<TtsLanguage> supportedLanguages = [
    TtsLanguage(code: 'en-US', name: 'English (US)', nativeName: 'English'),
    TtsLanguage(code: 'en-IN', name: 'English (India)', nativeName: 'English'),
    TtsLanguage(code: 'hi-IN', name: 'Hindi', nativeName: 'हिन्दी'),
    TtsLanguage(code: 'ta-IN', name: 'Tamil', nativeName: 'தமிழ்'),
    TtsLanguage(code: 'te-IN', name: 'Telugu', nativeName: 'తెలుగు'),
    TtsLanguage(code: 'kn-IN', name: 'Kannada', nativeName: 'ಕನ್ನಡ'),
    TtsLanguage(code: 'ml-IN', name: 'Malayalam', nativeName: 'മലയാളം'),
    TtsLanguage(code: 'mr-IN', name: 'Marathi', nativeName: 'मराठी'),
    TtsLanguage(code: 'gu-IN', name: 'Gujarati', nativeName: 'ગુજરાતી'),
    TtsLanguage(code: 'bn-IN', name: 'Bengali', nativeName: 'বাংলা'),
    TtsLanguage(code: 'pa-IN', name: 'Punjabi', nativeName: 'ਪੰਜਾਬੀ'),
  ];

  static TtsLanguage? getByCode(String code) {
    try {
      return supportedLanguages.firstWhere((lang) => lang.code == code);
    } catch (_) {
      return supportedLanguages.first;
    }
  }
}

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  String _currentLanguage = 'en-US';

  String get currentLanguage => _currentLanguage;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _flutterTts.setLanguage(_currentLanguage);
      await _flutterTts.setSpeechRate(0.5); // Slightly slower for clarity
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      // Set voice quality
      if (defaultTargetPlatform == TargetPlatform.android) {
        await _flutterTts.setEngine("com.google.android.tts");
      }

      _isInitialized = true;
      debugPrint('✅ TTS Service initialized with language: $_currentLanguage');
    } catch (e) {
      debugPrint('❌ TTS initialization error: $e');
    }
  }

  /// Set the language for TTS
  Future<void> setLanguage(String languageCode) async {
    try {
      _currentLanguage = languageCode;
      await _flutterTts.setLanguage(languageCode);
      debugPrint('🌐 TTS language set to: $languageCode');
    } catch (e) {
      debugPrint('❌ TTS setLanguage error: $e');
    }
  }

  /// Get list of available languages on device
  Future<List<String>> getAvailableLanguages() async {
    try {
      final languages = await _flutterTts.getLanguages;
      return List<String>.from(languages);
    } catch (e) {
      debugPrint('❌ Error getting languages: $e');
      return ['en-US'];
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
      debugPrint(
        '🔊 Speaking [$_currentLanguage]: ${text.substring(0, text.length > 50 ? 50 : text.length)}...',
      );
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
