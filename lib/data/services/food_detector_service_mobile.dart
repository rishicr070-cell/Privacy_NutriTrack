import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

/// Food classification service using TFLite model
/// Replaces the previous YOLO-based detector with a classification approach
class FoodDetectorServiceImpl {
  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _isModelLoaded = false;

  // Model configuration (will be detected dynamically)
  int _inputSize = 224; // Default, will be updated after model inspection

  Future<void> loadModel() async {
    if (_isModelLoaded) return;

    try {
      // Load the TFLite model
      _interpreter = await Interpreter.fromAsset('assets/models/model.tflite');

      // Load labels
      final labelsData = await rootBundle.loadString(
        'assets/models/labels.txt',
      );
      _labels = labelsData
          .split('\n')
          .where((label) => label.trim().isNotEmpty)
          .toList();

      // Inspect model to get actual input size
      final inputShape = _interpreter!.getInputTensor(0).shape;
      if (inputShape.length >= 2) {
        _inputSize = inputShape[1]; // Assuming [1, size, size, 3]
      }

      _isModelLoaded = true;
      debugPrint('✅ Food classification model loaded');
      debugPrint('   Model: model.tflite');
      debugPrint('   Input shape: $inputShape');
      debugPrint('   Input size: $_inputSize x $_inputSize');
      debugPrint('   Labels: ${_labels.length} food classes');
      debugPrint('   Output shape: ${_interpreter!.getOutputTensor(0).shape}');
    } catch (e, stackTrace) {
      debugPrint('❌ Model loading error: $e');
      debugPrint('Stack trace: $stackTrace');
      _isModelLoaded = false;
      rethrow;
    }
  }

  /// Detect/classify food from image bytes
  Future<Map<String, dynamic>> detectFood(
    Uint8List imageBytes,
    List<String> labels, // Kept for compatibility, but we use loaded labels
  ) async {
    if (!_isModelLoaded || _interpreter == null) {
      await loadModel();
    }

    try {
      // 1. PREPROCESS: Decode and resize image
      final decoded = img.decodeImage(imageBytes);
      if (decoded == null) {
        return _errorResult('Invalid image');
      }

      // Center crop to square
      final size = math.min(decoded.width, decoded.height);
      final offsetX = (decoded.width - size) ~/ 2;
      final offsetY = (decoded.height - size) ~/ 2;
      final cropped = img.copyCrop(
        decoded,
        x: offsetX,
        y: offsetY,
        width: size,
        height: size,
      );

      // Resize to model input size
      final resized = img.copyResize(
        cropped,
        width: _inputSize,
        height: _inputSize,
        interpolation: img.Interpolation.linear,
      );

      // Convert to uint8 input tensor (0-255 range, no normalization)
      final input = _imageToUint8Tensor(resized);

      // 2. ALLOCATE OUTPUT
      final outputShape = _interpreter!.getOutputTensor(0).shape;
      final numClasses = outputShape[1];
      final output = List.filled(numClasses, 0.0).reshape([1, numClasses]);

      // 3. RUN INFERENCE
      debugPrint('🔍 Running classification inference...');
      _interpreter!.run(input, output);
      debugPrint('✅ Inference complete');

      // 4. POSTPROCESS: Convert output to doubles and apply softmax
      final outputList = (output[0] as List)
          .map((e) => (e as num).toDouble())
          .toList();
      final probabilities = _softmax(outputList);
      return _parseClassificationResults(probabilities);
    } catch (e, stackTrace) {
      debugPrint('❌ Classification error: $e');
      debugPrint('Stack: $stackTrace');
      return _errorResult('Error: $e');
    }
  }

  /// Convert image to Uint8 tensor [1, size, size, 3] with values 0-255
  List<List<List<List<int>>>> _imageToUint8Tensor(img.Image image) {
    final tensor = List.generate(
      1,
      (_) => List.generate(
        _inputSize,
        (_) => List.generate(_inputSize, (_) => List<int>.filled(3, 0)),
      ),
    );

    for (int y = 0; y < _inputSize; y++) {
      for (int x = 0; x < _inputSize; x++) {
        final pixel = image.getPixelSafe(x, y);
        tensor[0][y][x][0] = pixel.r.toInt(); // R (0-255)
        tensor[0][y][x][1] = pixel.g.toInt(); // G (0-255)
        tensor[0][y][x][2] = pixel.b.toInt(); // B (0-255)
      }
    }

    return tensor;
  }

  /// Apply softmax to convert logits to probabilities
  List<double> _softmax(List<double> logits) {
    final maxLogit = logits.reduce(math.max);
    final exps = logits.map((x) => math.exp(x - maxLogit)).toList();
    final sumExps = exps.reduce((a, b) => a + b);
    return exps.map((x) => x / sumExps).toList();
  }

  /// Parse classification results and return top-k predictions
  Map<String, dynamic> _parseClassificationResults(List<double> probabilities) {
    // Create list of (label, confidence) pairs
    final predictions = <Map<String, dynamic>>[];
    for (int i = 0; i < probabilities.length && i < _labels.length; i++) {
      predictions.add({'label': _labels[i], 'confidence': probabilities[i]});
    }

    // Sort by confidence descending
    predictions.sort(
      (a, b) =>
          (b['confidence'] as double).compareTo(a['confidence'] as double),
    );

    // Get top prediction
    final topPrediction = predictions.first;
    final topLabel = topPrediction['label'] as String;
    final topConfidence = topPrediction['confidence'] as double;

    debugPrint(
      '🍽️ Classification → $topLabel (${(topConfidence * 100).toStringAsFixed(1)}%)',
    );
    debugPrint('   Top 5 predictions:');
    for (int i = 0; i < math.min(5, predictions.length); i++) {
      final pred = predictions[i];
      debugPrint(
        '   ${i + 1}. ${pred['label']}: ${((pred['confidence'] as double) * 100).toStringAsFixed(1)}%',
      );
    }

    // Return result in format compatible with existing code
    return {
      'label': topLabel,
      'confidence': topConfidence,
      'all_predictions': predictions.take(10).toList(), // Top 10 for UI
      'bbox': null, // No bounding box for classification
    };
  }

  Map<String, dynamic> _errorResult(String message) {
    return {
      'label': message,
      'confidence': 0.0,
      'all_predictions': [],
      'bbox': null,
    };
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isModelLoaded = false;
    _labels.clear();
    debugPrint('Food classifier disposed');
  }
}
