import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class FoodDetectorServiceImpl {
  Future<void> loadModel() async {
    debugPrint('⚠️ TFLite is not supported on web platform');
  }

  Future<Map<String, dynamic>> detectFood(
    Uint8List imageBytes,
    List<String> labels,
  ) async {
    throw UnsupportedError(
      'Food detection is not available on web. Please use the mobile app.',
    );
  }

  void dispose() {
    debugPrint('🗑️ Food detector disposed (web stub)');
  }
}
