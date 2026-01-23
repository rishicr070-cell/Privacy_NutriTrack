/// Portion size information for a food item
class PortionInfo {
  final int small;
  final int medium;
  final int large;
  final String unit;
  final String description;

  const PortionInfo({
    required this.small,
    required this.medium,
    required this.large,
    this.unit = 'grams',
    this.description = '',
  });
}

/// Service for estimating food portion sizes
/// 100% offline, no API calls, completely free
class PortionEstimationService {
  static final PortionEstimationService _instance =
      PortionEstimationService._internal();
  factory PortionEstimationService() => _instance;
  PortionEstimationService._internal();

  /// Database of typical portion sizes for Indian foods
  /// Based on nutritional guidelines and common serving sizes
  static const Map<String, PortionInfo> portionDatabase = {
    'Aloo_matar': PortionInfo(
      small: 100,
      medium: 150,
      large: 250,
      description: 'Potato and pea curry',
    ),
    'Besan_cheela': PortionInfo(
      small: 60,
      medium: 80,
      large: 120,
      description: '1 medium cheela',
    ),
    'Biryani': PortionInfo(
      small: 200,
      medium: 300,
      large: 450,
      description: '1 plate biryani',
    ),
    'Chapathi': PortionInfo(
      small: 30,
      medium: 40,
      large: 60,
      description: '1 medium roti',
    ),
    'Chole_bature': PortionInfo(
      small: 150,
      medium: 200,
      large: 300,
      description: '1 bhatura + chole',
    ),
    'Dahl': PortionInfo(
      small: 100,
      medium: 150,
      large: 250,
      description: '1 bowl dal',
    ),
    'Dhokla': PortionInfo(
      small: 80,
      medium: 120,
      large: 180,
      description: '4-6 pieces',
    ),
    'Dosa': PortionInfo(
      small: 80,
      medium: 120,
      large: 200,
      description: '1 medium dosa',
    ),
    'Gulab_jamun': PortionInfo(
      small: 40,
      medium: 60,
      large: 100,
      description: '2-3 pieces',
    ),
    'Idli': PortionInfo(
      small: 80,
      medium: 120,
      large: 160,
      description: '2-3 idlis',
    ),
    'Jalebi': PortionInfo(
      small: 50,
      medium: 80,
      large: 120,
      description: '3-4 pieces',
    ),
    'Kadai_paneer': PortionInfo(
      small: 120,
      medium: 180,
      large: 280,
      description: '1 bowl kadai paneer',
    ),
    'Naan': PortionInfo(
      small: 60,
      medium: 90,
      large: 130,
      description: '1 medium naan',
    ),
    'Paani_puri': PortionInfo(
      small: 60,
      medium: 100,
      large: 150,
      description: '6-10 puris',
    ),
    'Pakoda': PortionInfo(
      small: 60,
      medium: 100,
      large: 150,
      description: '4-6 pakodas',
    ),
    'Pav_bhaji': PortionInfo(
      small: 150,
      medium: 250,
      large: 400,
      description: '2 pav + bhaji',
    ),
    'Poha': PortionInfo(
      small: 100,
      medium: 150,
      large: 250,
      description: '1 bowl poha',
    ),
    'Rolls': PortionInfo(
      small: 120,
      medium: 180,
      large: 280,
      description: '1 medium roll',
    ),
    'Samosa': PortionInfo(
      small: 50,
      medium: 80,
      large: 120,
      description: '1-2 samosas',
    ),
    'Vada_pav': PortionInfo(
      small: 100,
      medium: 150,
      large: 220,
      description: '1 vada pav',
    ),
  };

  /// Get portion information for a detected food
  PortionInfo? getPortionInfo(String foodName) {
    return portionDatabase[foodName];
  }

  /// Get estimated weight based on size selection
  int getEstimate(String foodName, String size) {
    final info = getPortionInfo(foodName);
    if (info == null) return 100; // Default fallback

    switch (size.toLowerCase()) {
      case 'small':
        return info.small;
      case 'large':
        return info.large;
      case 'medium':
      default:
        return info.medium;
    }
  }

  /// Format a user-friendly portion description
  String getPortionDescription(String foodName, String size) {
    final info = getPortionInfo(foodName);
    if (info == null) return '$size portion';

    final weight = getEstimate(foodName, size);
    final displayName = foodName.replaceAll('_', ' ');

    return '$size $displayName (~${weight}g)';
  }

  /// Get all available portion sizes for a food
  List<Map<String, dynamic>> getPortionOptions(String foodName) {
    final info = getPortionInfo(foodName);
    if (info == null) {
      return [
        {'size': 'Small', 'weight': 50, 'icon': '🥄'},
        {'size': 'Medium', 'weight': 100, 'icon': '🍽️'},
        {'size': 'Large', 'weight': 200, 'icon': '🍲'},
      ];
    }

    return [
      {
        'size': 'Small',
        'weight': info.small,
        'icon': '🥄',
        'description': info.description,
      },
      {
        'size': 'Medium',
        'weight': info.medium,
        'icon': '🍽️',
        'description': info.description,
      },
      {
        'size': 'Large',
        'weight': info.large,
        'icon': '🍲',
        'description': info.description,
      },
    ];
  }
}
