import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

/// Debug utility to inspect TFLite model structure
class ModelInspector {
  static Future<void> inspectModel(String assetPath) async {
    try {
      final interpreter = await Interpreter.fromAsset(assetPath);
      final inputs = interpreter.getInputTensors();
      final outputs = interpreter.getOutputTensors();

      debugPrint('═══════════════════════════════════════');
      debugPrint('Model Inspection: $assetPath');
      debugPrint('═══════════════════════════════════════');

      for (var i = 0; i < inputs.length; i++) {
        final t = inputs[i];
        debugPrint('Input[$i]:');
        debugPrint('  Shape: ${t.shape}');
        debugPrint('  Type: ${t.type}');
      }

      debugPrint('───────────────────────────────────────');

      for (var i = 0; i < outputs.length; i++) {
        final t = outputs[i];
        debugPrint('Output[$i]:');
        debugPrint('  Shape: ${t.shape}');
        debugPrint('  Type: ${t.type}');
      }

      debugPrint('═══════════════════════════════════════');

      interpreter.close();
    } catch (e, stackTrace) {
      debugPrint('❌ Error inspecting model: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }
}
