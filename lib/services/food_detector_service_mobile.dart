import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class FoodDetectorServiceImpl {
  Interpreter? _interpreter;
  bool _isModelLoaded = false;

  Future<void> loadModel() async {
    if (_isModelLoaded) return;
    
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/models/Fooddetector.tflite',
      );
      _isModelLoaded = true;
      debugPrint('✅ Fooddetector.tflite loaded');
      debugPrint('   Input: [1,640,640,3] float32');
      debugPrint('   Output: [1,24,8400] float32');
    } catch (e) {
      debugPrint('❌ Model loading error: $e');
      _isModelLoaded = false;
      rethrow;
    }
  }

  Future<Map<String, dynamic>> detectFood(
    Uint8List imageBytes,
    List<String> labels,
  ) async {
    if (!_isModelLoaded || _interpreter == null) {
      await loadModel();
    }

    try {
      // 1. PREPROCESS: Decode and resize to 640x640
      final decoded = img.decodeImage(imageBytes);
      if (decoded == null) {
        return _errorResult('Invalid image');
      }

      final resized = img.copyResize(
        decoded,
        width: 640,
        height: 640,
        interpolation: img.Interpolation.linear,
      );

      // Convert to float32 [1,640,640,3] with 0-1 normalization
      final input = _imageToByteListFloat32(resized);

      // 2. ALLOCATE OUTPUT: [1, 24, 8400]
      final output = List.generate(
        1,
        (_) => List.generate(
          24,
          (_) => List<double>.filled(8400, 0.0),
        ),
      );

      // 3. RUN INFERENCE
      debugPrint('Running inference...');
      _interpreter!.run(input, output);
      debugPrint('✅ Inference complete');

      // 4. PARSE DETECTIONS
      return _parseDetections(output, labels);

    } catch (e, stackTrace) {
      debugPrint('❌ Detection error: $e');
      debugPrint('Stack: $stackTrace');
      return _errorResult('Error: $e');
    }
  }

  /// Convert image to Float32 tensor [1,640,640,3] normalized to 0-1
  Uint8List _imageToByteListFloat32(img.Image image) {
    const inputSize = 640;
    final convertedBytes = Float32List(1 * inputSize * inputSize * 3);
    int pixelIndex = 0;

    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = image.getPixelSafe(x, y);
        convertedBytes[pixelIndex++] = pixel.r / 255.0;
        convertedBytes[pixelIndex++] = pixel.g / 255.0;
        convertedBytes[pixelIndex++] = pixel.b / 255.0;
      }
    }

    return convertedBytes.buffer.asUint8List();
  }

  /// Parse YOLO output [1, 24, 8400]
  /// Channels 0-3: x, y, w, h (bbox)
  /// Channels 4-23: 20 class scores
  Map<String, dynamic> _parseDetections(
    List<List<List<double>>> output,
    List<String> labels,
  ) {
    const numBoxes = 8400;
    const numClasses = 20;
    const scoreThreshold = 0.5;

    double bestScore = 0.0;
    String bestLabel = 'Unknown';
    List<double>? bestBbox;
    int bestClassIndex = -1;

    List<Map<String, dynamic>> allDetections = [];

    // Iterate through all 8400 detection boxes
    for (int i = 0; i < numBoxes; i++) {
      // Read bounding box from channels 0-3
      final double x = output[0][0][i];
      final double y = output[0][1][i];
      final double w = output[0][2][i];
      final double h = output[0][3][i];

      // Read class scores from channels 4-23
      int bestClass = -1;
      double maxClassScore = 0.0;

      for (int c = 0; c < numClasses; c++) {
        final score = output[0][4 + c][i];
        if (score > maxClassScore) {
          maxClassScore = score;
          bestClass = c;
        }
      }

      // Keep detections above threshold
      if (maxClassScore > scoreThreshold && 
          bestClass >= 0 && 
          bestClass < labels.length) {
        
        allDetections.add({
          'label': labels[bestClass],
          'confidence': maxClassScore,
          'bbox': [x, y, w, h],
          'class_index': bestClass,
        });

        // Track best detection
        if (maxClassScore > bestScore) {
          bestScore = maxClassScore;
          bestLabel = labels[bestClass];
          bestBbox = [x, y, w, h];
          bestClassIndex = bestClass;
        }
      }
    }

    // Sort all detections by confidence
    allDetections.sort((a, b) => 
      (b['confidence'] as double).compareTo(a['confidence'] as double)
    );

    // Create all_predictions for UI compatibility
    List<Map<String, dynamic>> allPredictions = [];
    for (int c = 0; c < labels.length && c < numClasses; c++) {
      // Find best score for this class
      double maxForClass = 0.0;
      for (var det in allDetections) {
        if (det['class_index'] == c) {
          maxForClass = det['confidence'] as double;
          break;
        }
      }
      allPredictions.add({
        'label': labels[c],
        'confidence': maxForClass,
      });
    }
    allPredictions.sort((a, b) => 
      (b['confidence'] as double).compareTo(a['confidence'] as double)
    );

    debugPrint('Fooddetector → $bestLabel (${(bestScore * 100).toStringAsFixed(1)}%)');
    debugPrint('Total detections above threshold: ${allDetections.length}');
    if (bestBbox != null) {
      debugPrint('BBox: [${bestBbox.map((v) => v.toStringAsFixed(1)).join(", ")}]');
    }

    if (bestScore < 0.25) {
      return {
        'label': 'Unknown (${(bestScore * 100).toStringAsFixed(1)}%)',
        'confidence': bestScore,
        'bbox': bestBbox,
        'all_predictions': allPredictions,
        'detections': allDetections,
      };
    }

    return {
      'label': bestLabel,
      'confidence': bestScore,
      'bbox': bestBbox,
      'all_predictions': allPredictions,
      'detections': allDetections,
    };
  }

  Map<String, dynamic> _errorResult(String message) {
    return {
      'label': message,
      'confidence': 0.0,
      'all_predictions': [],
    };
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isModelLoaded = false;
    debugPrint('Fooddetector disposed');
  }
}
