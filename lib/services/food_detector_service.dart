import 'dart:typed_data';
import 'package:flutter/foundation.dart';

// Conditional import based on platform
import 'food_detector_service_stub.dart'
    if (dart.library.io) 'food_detector_service_mobile.dart'
    as detector;

class FoodDetectorService {
  final detector.FoodDetectorServiceImpl _impl = detector.FoodDetectorServiceImpl();
  
  // Indian food classes - must match your training order
  static const List<String> labels = [
    'Aloo_matar',
    'Besan_cheela',
    'Biryani',
    'Chapathi',
    'Chole_bature',
    'Dahl',
    'Dhokla',
    'Dosa',
    'Gulab_jamun',
    'Idli',
    'Jalebi',
    'Kadai_paneer',
    'Naan',
    'Paani_puri',
    'Pakoda',
    'Pav_bhaji',
    'Poha',
    'Rolls',
    'Samosa',
    'Vada_pav',
  ];

  Future<void> loadModel() async {
    await _impl.loadModel();
  }

  Future<Map<String, dynamic>> detectFood(Uint8List imageBytes) async {
    return await _impl.detectFood(imageBytes, labels);
  }

  void dispose() {
    _impl.dispose();
  }
}
