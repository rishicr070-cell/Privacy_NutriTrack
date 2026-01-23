import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:privacy_first_nutrition_tracking_app/data/services/food_detector_service.dart';
import 'package:privacy_first_nutrition_tracking_app/data/services/food_search_service.dart';
import 'package:privacy_first_nutrition_tracking_app/data/services/portion_estimation_service.dart';
import 'package:privacy_first_nutrition_tracking_app/data/local/food_data_loader.dart';
import 'package:privacy_first_nutrition_tracking_app/data/models/food_item.dart';

class FoodScannerScreen extends StatefulWidget {
  final String? mealType;

  const FoodScannerScreen({super.key, this.mealType});

  @override
  State<FoodScannerScreen> createState() => _FoodScannerScreenState();
}

class _FoodScannerScreenState extends State<FoodScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  final FoodDetectorService _detector = FoodDetectorService();
  final PortionEstimationService _portionService = PortionEstimationService();

  bool _isLoading = false;
  bool _isLoadingDatabase = true;
  Map<String, dynamic>? _result;
  Uint8List? _imageBytes;
  List<FoodItem> _foodDatabase = [];
  List<FoodSearchResult> _nutritionMatches = [];
  String _selectedPortionSize = 'Medium'; // Default portion size

  @override
  void initState() {
    super.initState();
    _loadModel();
    _loadFoodDatabase();
  }

  Future<void> _loadFoodDatabase() async {
    try {
      final foods = await FoodDataLoader.loadFoodItems();
      setState(() {
        _foodDatabase = foods;
        _isLoadingDatabase = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Loaded ${foods.length} foods'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoadingDatabase = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Error loading food database: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _loadModel() async {
    try {
      await _detector.loadModel();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Model ready!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() => _isLoading = true);

      final bytes = await image.readAsBytes();
      final result = await _detector.detectFood(bytes);

      // Auto-search for nutrition data
      List<FoodSearchResult> matches = [];
      if (result['label'] != null && _foodDatabase.isNotEmpty) {
        final detectedName = result['label'] as String;
        matches = FoodSearchService.searchFoods(
          detectedName,
          _foodDatabase,
          maxResults: 3,
          minSimilarity: 0.4,
        );
      }

      setState(() {
        _result = result;
        _imageBytes = bytes;
        _nutritionMatches = matches;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _detector.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Food'),
        backgroundColor: const Color(0xFF4ECDC4),
        foregroundColor: Colors.white,
      ),
      body: _isLoading || _isLoadingDatabase
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    _isLoadingDatabase
                        ? 'Loading food database...'
                        : 'Detecting food...',
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_imageBytes != null) ...[
                    _buildImagePreview(),
                    const SizedBox(height: 24),
                  ],
                  if (_result != null) ...[
                    _buildResults(),
                    const SizedBox(height: 16),
                    _buildPortionSelector(),
                    const SizedBox(height: 16),
                  ],
                  if (_nutritionMatches.isNotEmpty) ...[
                    _buildNutritionMatches(),
                    const SizedBox(height: 24),
                  ],
                  _buildActionButtons(),
                  const SizedBox(height: 16),
                  _buildInstructions(),
                ],
              ),
            ),
    );
  }

  Widget _buildImagePreview() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.memory(_imageBytes!, fit: BoxFit.cover, height: 300),
      ),
    );
  }

  Widget _buildResults() {
    final label = _result?['label'] as String? ?? 'Unknown';
    final confidence = _result?['confidence'] as double? ?? 0.0;
    final allPredictions = _result?['all_predictions'] as List? ?? [];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  confidence > 0.25 ? Icons.check_circle : Icons.warning,
                  color: confidence > 0.25 ? Colors.green : Colors.orange,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Detected Food',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Text(
                        label.replaceAll('_', ' '),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildConfidenceBar(confidence),
            if (allPredictions.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Top Predictions:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...allPredictions.take(5).map((pred) {
                final predLabel = (pred['label'] as String?) ?? 'Unknown';
                final predConf = (pred['confidence'] as double?) ?? 0.0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(child: Text(predLabel.replaceAll('_', ' '))),
                      Text(
                        '${(predConf * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: predConf > 0.5 ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
            if (confidence > 0.25) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final estimatedWeight = _portionService.getEstimate(
                      label,
                      _selectedPortionSize,
                    );
                    Navigator.pop(context, {
                      'name': label.replaceAll('_', ' '),
                      'confidence': confidence,
                      'mealType': widget.mealType,
                      'estimatedWeight': estimatedWeight,
                      'portionSize': _selectedPortionSize,
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Use This Food'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4ECDC4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceBar(double confidence) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Confidence',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              '${(confidence * 100).toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: confidence,
            minHeight: 12,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              confidence > 0.7
                  ? Colors.green
                  : confidence > 0.4
                  ? Colors.orange
                  : Colors.red,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionMatches() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.restaurant,
                  color: Color(0xFF4ECDC4),
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Nutrition Data',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._nutritionMatches.map((match) => _buildNutritionMatch(match)),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionMatch(FoodSearchResult match) {
    final food = match.food;
    final matchIcon = match.matchType == MatchType.exact
        ? Icons.check_circle
        : match.matchType == MatchType.high
        ? Icons.check_circle_outline
        : Icons.info_outline;
    final matchColor =
        match.matchType == MatchType.exact || match.matchType == MatchType.high
        ? Colors.green
        : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(matchIcon, color: matchColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.foodName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (food.category != null)
                      Text(
                        food.category!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: matchColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${match.confidencePercent}% match',
                  style: TextStyle(
                    fontSize: 12,
                    color: matchColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Nutrition info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNutrientInfo(
                'Calories',
                '${food.calories.toStringAsFixed(0)}',
                'kcal',
                const Color(0xFFFFBE0B),
              ),
              _buildNutrientInfo(
                'Protein',
                '${food.protein.toStringAsFixed(1)}',
                'g',
                const Color(0xFF4ECDC4),
              ),
              _buildNutrientInfo(
                'Carbs',
                '${food.carbs.toStringAsFixed(1)}',
                'g',
                const Color(0xFFFFBE0B),
              ),
              _buildNutrientInfo(
                'Fat',
                '${food.fat.toStringAsFixed(1)}',
                'g',
                const Color(0xFFFF006E),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final label = _result?['label'] as String? ?? '';
                final estimatedWeight = _portionService.getEstimate(
                  label,
                  _selectedPortionSize,
                );
                Navigator.pop(context, {
                  'foodItem': food,
                  'detectionConfidence': _result?['confidence'] ?? 0.0,
                  'matchConfidence': match.similarity,
                  'mealType': widget.mealType,
                  'estimatedWeight': estimatedWeight,
                  'portionSize': _selectedPortionSize,
                });
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add to Meal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4ECDC4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientInfo(
    String label,
    String value,
    String unit,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              TextSpan(
                text: ' $unit',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _pickImage(ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Take Photo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4ECDC4),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _pickImage(ImageSource.gallery),
            icon: const Icon(Icons.photo_library),
            label: const Text('Choose from Gallery'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF4ECDC4),
              padding: const EdgeInsets.all(16),
              side: const BorderSide(color: Color(0xFF4ECDC4)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructions() {
    return Card(
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  'Best results:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInstruction('📸 Clear, well-lit photos'),
            _buildInstruction('🍽️ Focus on food'),
            _buildInstruction('📏 Fill frame with dish'),
            _buildInstruction('🇮🇳 Indian food works best'),
          ],
        ),
      ),
    );
  }

  Widget _buildInstruction(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(text, style: const TextStyle(fontSize: 14)),
    );
  }

  Widget _buildPortionSelector() {
    final label = _result?['label'] as String? ?? '';
    final portionOptions = _portionService.getPortionOptions(label);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.straighten,
                  color: Color(0xFF4ECDC4),
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Select Portion Size',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: portionOptions.map((option) {
                final size = option['size'] as String;
                final weight = option['weight'] as int;
                final icon = option['icon'] as String;
                final isSelected = _selectedPortionSize == size;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedPortionSize = size;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF4ECDC4).withOpacity(0.2)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF4ECDC4)
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(icon, style: const TextStyle(fontSize: 28)),
                            const SizedBox(height: 8),
                            Text(
                              size,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? const Color(0xFF4ECDC4)
                                    : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '~${weight}g',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Portion sizes are typical estimates. You can adjust in the next screen.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
