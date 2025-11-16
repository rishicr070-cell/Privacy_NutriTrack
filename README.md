# NutriTrack - Privacy-First Nutrition Tracking App

A beautiful, modern nutrition tracking app built with Flutter that prioritizes your privacy by storing all data locally on your device.

![Flutter](https://img.shields.io/badge/Flutter-3.10+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.10+-blue.svg)
![License](https://img.shields.io/badge/License-Private-red.svg)

## ✨ Features

### 🏠 Home Screen
- **Beautiful Dashboard** with gradient designs and glassmorphism effects
- **Nutrition Overview** with interactive ring charts showing calories, protein, carbs, and fat
- **Daily Progress Tracking** with visual progress indicators
- **Water Intake Tracker** with interactive glass counter
- **Meal Sections** organized by Breakfast, Lunch, Dinner, and Snacks
- **Swipe-to-Delete** functionality for easy entry management
- **Pull-to-Refresh** for instant data updates

### 🔍 Search Screen
- **Comprehensive Food Database** with 20+ common foods pre-loaded
- **Real-time Search** with instant results
- **Barcode Scanner** integration for quick food entry
- **Category Organization** (Fruits, Proteins, Carbs, Vegetables, Dairy, Nuts)
- **One-Tap Add** foods to any meal
- **Custom Food Creation** for items not in database

### 📊 Analytics Screen
- **Beautiful Line Charts** showing calorie trends over time
- **Macro Distribution Charts** tracking protein, carbs, and fat
- **Pie Chart** showing meal distribution
- **Customizable Time Ranges** (7, 14, 30, 90 days)
- **Statistics Cards** with average calories and total entries
- **Interactive Charts** with hover tooltips

### 👤 Profile Screen
- **User Profile Management** with avatar and personal info
- **BMI Calculator** with automatic categorization
- **Weight Progress Tracking** with beautiful line charts
- **Goal Setting** for calories, macros, and water intake
- **Activity Level Selection** (Sedentary to Very Active)
- **Auto-Calculate Macros** based on age, weight, height, and activity level
- **Weight Logging** with date tracking

### 🎨 UI/UX Highlights
- **Dark Mode Support** with seamless theme switching
- **Google Fonts** integration for beautiful typography
- **Gradient Backgrounds** and modern card designs
- **Smooth Animations** and transitions between screens
- **Custom Bottom Navigation** with animated indicators
- **Material 3 Design** with modern color schemes
- **Responsive Layout** that works on all screen sizes

### 🔐 Privacy-First
- **100% Local Storage** - All data stays on your device
- **No Cloud Sync** - No data leaves your phone
- **No Accounts Required** - Start using immediately
- **No Tracking** - Your nutrition data is yours alone

## 📱 Screenshots

[Add screenshots here after running the app]

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.10 or higher
- Dart SDK 3.10 or higher
- Android Studio / VS Code with Flutter extensions
- An Android or iOS device/emulator

### Installation

1. **Clone the repository**
   ```bash
   cd C:\Users\rishi\OneDrive\Desktop\Apps\privacy_first_nutrition_tracking_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  shared_preferences: ^2.2.2      # Local storage
  fl_chart: ^0.66.0                # Beautiful charts
  intl: ^0.19.0                    # Date formatting
  mobile_scanner: ^3.5.5           # Barcode scanning
  animations: ^2.0.11              # Smooth transitions
  flutter_slidable: ^3.0.1         # Swipe actions
  google_fonts: ^6.1.0             # Custom fonts
```

## 🏗️ Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/
│   ├── food_entry.dart         # Food entry data model
│   └── user_profile.dart       # User profile data model
├── screens/
│   ├── home_screen.dart        # Main dashboard
│   ├── search_screen.dart      # Food search & barcode
│   ├── analytics_screen.dart   # Charts & statistics
│   ├── profile_screen.dart     # User profile & settings
│   ├── add_food_screen.dart    # Add/edit food entries
│   └── edit_profile_screen.dart # Profile editing
├── widgets/
│   ├── nutrition_ring_chart.dart  # Custom ring chart
│   ├── meal_section.dart          # Meal display widget
│   └── water_tracker.dart         # Water intake widget
└── utils/
    └── storage_helper.dart        # Local storage management
```

## 🎯 Key Features Explained

### Nutrition Tracking
- Track calories, protein, carbs, and fat for every meal
- Set custom serving sizes and units
- View daily totals and compare against goals
- Historical data with trend analysis

### Smart Calculations
- **BMR (Basal Metabolic Rate)** using Mifflin-St Jeor Equation
- **TDEE (Total Daily Energy Expenditure)** based on activity level
- **Automatic Macro Calculation** with customizable ratios
- **BMI (Body Mass Index)** with category classification

### Data Management
- **Import/Export** (can be added)
- **Backup/Restore** (can be added)
- **Data Clearing** for fresh starts
- **Persistent Storage** using SharedPreferences

## 🎨 Customization

### Changing Colors
Edit the theme in `main.dart`:
```dart
colorScheme: ColorScheme.fromSeed(
  seedColor: const Color(0xFF6C63FF), // Change this color
  brightness: Brightness.light,
),
```

### Adding Foods to Database
Edit `_foodDatabase` in `search_screen.dart`:
```dart
{'name': 'New Food', 'calories': 100.0, 'protein': 5.0, ...}
```

### Modifying Goals
Default goals can be changed in `edit_profile_screen.dart`

## 🐛 Known Issues & Future Enhancements

### Planned Features
- [ ] Food favorites
- [ ] Meal templates
- [ ] Recipe builder
- [ ] Export to CSV/PDF
- [ ] Backup to cloud (optional)
- [ ] Photo food logging
- [ ] Nutrition API integration
- [ ] Meal reminders
- [ ] Streaks and achievements
- [ ] Multi-language support

### Current Limitations
- Barcode scanner requires actual barcode database integration
- Limited food database (expandable)
- No cloud backup (by design for privacy)

## 📄 License

This project is private and not for public distribution.

## 👏 Acknowledgments

- Flutter team for the amazing framework
- fl_chart for beautiful charts
- Material Design 3 for design guidelines
- All open-source contributors

## 🤝 Contributing

This is a private project. For any questions or suggestions, please contact the developer.

## 📞 Support

For any issues or questions:
- Create an issue in the repository
- Contact the developer directly

---

**Built with ❤️ and Flutter**

*Privacy-first nutrition tracking for everyone*
