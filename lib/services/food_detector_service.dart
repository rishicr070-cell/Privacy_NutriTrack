import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class FoodDetectorService {
  Interpreter? _interpreter;
  
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
    if (_interpreter != null) return;
    
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/models/best_int8.tflite',
      );
      debugPrint('✅ Food detection model loaded successfully');
    } catch (e) {
      debugPrint('❌ Error loading model: $e');
      rethrow;
    }
  }

  /// Detects food from image bytes and returns label with confidence
  Future<Map<String, dynamic>> detectFood(Uint8List imageBytes) async {
    await loadModel();
    
    if (_interpreter == null) {
      throw Exception('Model not loaded');
    }

    // Decode image
    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('Unable to decode image');
    }

    // Resize to model input size (224x224 is common for classification)
    const int inputSize = 224;
    final resized = img.copyResize(
      image, 
      width: inputSize, 
      height: inputSize,
      interpolation: img.Interpolation.linear,
    );

    // Prepare input tensor [1, 224, 224, 3] with float32 values 0-1
    final input = _imageToByteListFloat32(resized, inputSize);

    // Prepare output tensor [1, 20] for 20 classes
    final output = List.filled(labels.length, 0.0).reshape([1, labels.length]);

    // Run inference
    _interpreter!.run(input, output);

    // Find best prediction
    double maxConfidence = -1.0;
    int bestIndex = 0;
    
    for (int i = 0; i < labels.length; i++) {
      final confidence = output[0][i] as double;
      if (confidence > maxConfidence) {
        maxConfidence = confidence;
        bestIndex = i;
      }
    }

    final detectedLabel = labels[bestIndex];
    debugPrint('🍽️ Detected: $detectedLabel with confidence: ${(maxConfidence * 100).toStringAsFixed(1)}%');

    return {
      'label': detectedLabel,
      'confidence': maxConfidence,
      'all_predictions': List.generate(
        labels.length, 
        (i) => {
          'label': labels[i],
          'confidence': output[0][i] as double,
        },
      )..sort((a, b) => (b['confidence'] as double).compareTo(a['confidence'] as double)),
    };
  }

  /// Convert image to Float32List for model input
  List<List<List<List<double>>>> _imageToByteListFloat32(
    img.Image image, 
    int inputSize,
  ) {
    return List.generate(
      1,
      (_) => List.generate(
        inputSize,
        (y) => List.generate(
          inputSize,
          (x) {
            final pixel = image.getPixel(x, y);
            // Normalize to 0-1 range
            final r = img.getRed(pixel) / 255.0;
            final g = img.getGreen(pixel) / 255.0;
            final b = img.getBlue(pixel) / 255.0;
            return [r, g, b];
          },
        ),
      ),
    );
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    debugPrint('🗑️ Food detector model disposed');
  }
}
