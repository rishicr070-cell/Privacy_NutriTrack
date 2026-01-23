import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class FoodRecognitionService {
  static Interpreter? _interpreter;
  static List<String>? _labels;
  static bool _isInitialized = false;

  // Initialize the TFLite model
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      print('Loading TFLite model...');
      _interpreter = await Interpreter.fromAsset('assets/best_int8.tflite');
      print('Model loaded successfully');
      
      // Load labels (you'll need to create this file with your food classes)
      _labels = await _loadLabels();
      print('Labels loaded: ${_labels?.length} classes');
      
      _isInitialized = true;
    } catch (e) {
      print('Error loading TFLite model: $e');
      rethrow;
    }
  }

  // Load labels from a text file
  static Future<List<String>> _loadLabels() async {
    // TODO: Add your labels.txt file to assets with list of food names
    // For now, returning sample labels
    return [
      'Apple',
      'Banana',
      'Orange',
      'Chicken',
      'Rice',
      'Bread',
      'Egg',
      'Fish',
      'Salad',
      'Pasta',
      // Add all your food classes here
    ];
  }

  // Recognize food from image bytes
  static Future<FoodRecognitionResult?> recognizeFood(Uint8List imageBytes) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Decode image
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) {
        print('Failed to decode image');
        return null;
      }

      // Preprocess image (resize to model input size, usually 224x224)
      img.Image resizedImage = img.copyResize(image, width: 224, height: 224);
      
      // Convert to input tensor format
      var input = _imageToByteListUint8(resizedImage);
      
      // Output tensor
      var output = List.filled(1 * (_labels?.length ?? 10), 0).reshape([1, _labels?.length ?? 10]);
      
      // Run inference
      _interpreter?.run(input, output);
      
      // Get results
      List<double> probabilities = output[0].cast<double>();
      
      // Find top prediction
      double maxProb = 0;
      int maxIndex = 0;
      for (int i = 0; i < probabilities.length; i++) {
        if (probabilities[i] > maxProb) {
          maxProb = probabilities[i];
          maxIndex = i;
        }
      }

      if (maxProb < 0.3) {
        // Confidence too low
        return null;
      }

      return FoodRecognitionResult(
        foodName: _labels?[maxIndex] ?? 'Unknown',
        confidence: maxProb,
        allPredictions: _getTopPredictions(probabilities, 3),
      );
    } catch (e) {
      print('Error during food recognition: $e');
      return null;
    }
  }

  // Convert image to byte list for model input
  static Uint8List _imageToByteListUint8(img.Image image) {
    var convertedBytes = Uint8List(1 * 224 * 224 * 3);
    var buffer = ByteData.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (int i = 0; i < 224; i++) {
      for (int j = 0; j < 224; j++) {
        var pixel = image.getPixel(j, i);
        buffer.setUint8(pixelIndex++, pixel.r.toInt());
        buffer.setUint8(pixelIndex++, pixel.g.toInt());
        buffer.setUint8(pixelIndex++, pixel.b.toInt());
      }
    }

    return convertedBytes;
  }

  // Get top N predictions
  static List<Prediction> _getTopPredictions(List<double> probabilities, int topK) {
    List<Prediction> predictions = [];
    
    for (int i = 0; i < probabilities.length; i++) {
      predictions.add(Prediction(
        label: _labels?[i] ?? 'Unknown',
        confidence: probabilities[i],
      ));
    }
    
    predictions.sort((a, b) => b.confidence.compareTo(a.confidence));
    
    return predictions.take(topK).toList();
  }

  // Clean up resources
  static void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
  }
}

class FoodRecognitionResult {
  final String foodName;
  final double confidence;
  final List<Prediction> allPredictions;

  FoodRecognitionResult({
    required this.foodName,
    required this.confidence,
    required this.allPredictions,
  });
}

class Prediction {
  final String label;
  final double confidence;

  Prediction({
    required this.label,
    required this.confidence,
  });
}
