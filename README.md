# 🥗 NutriTrack - Privacy-First Nutrition Tracking

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?style=for-the-badge&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.10+-0175C2?style=for-the-badge&logo=dart)
![SQLite](https://img.shields.io/badge/SQLite-3-003B57?style=for-the-badge&logo=sqlite)
![License](https://img.shields.io/badge/License-Private-red?style=for-the-badge)

**A beautiful, modern nutrition tracking app that prioritizes your privacy**

*All your data stays on your device. No cloud. No tracking. Just you and your health goals.*

</div>

---

## ✨ Features

### 🏠 Home Screen - Your Daily Dashboard
- **Beautiful Gradient Design** with glassmorphism effects
- **Nutrition Ring Chart** showing calories, protein, carbs, and fat at a glance
- **Daily Progress Tracking** with animated progress bars
- **Interactive Water Tracker** with glass counter animation
- **Meal Organization** by Breakfast, Lunch, Dinner, and Snacks
- **Smart Stats Cards** showing meals logged, protein intake, and water consumption
- **Swipe-to-Delete** for easy entry management
- **Pull-to-Refresh** for instant data updates
- **Floating Action Button** for quick food logging

### 🔍 Search Screen - Find Foods Fast
- **Pre-loaded Food Database** with nutritional information
- **Real-time Search** with instant filtering
- **Category Browsing** (Fruits, Proteins, Grains, Vegetables, Dairy, Nuts & Seeds)
- **Complete Nutrition Info** for each food item
- **Quick Add to Meals** with one tap
- **CSV Import Support** - Load custom food databases
- **Indian Food Database** (Anuvaad INDB 2024) included

### 📊 Analytics Screen - Track Your Progress
- **Calorie Trend Chart** showing your intake over time
- **Macro Distribution Analysis** (protein, carbs, fat breakdown)
- **Meal Distribution Pie Chart** 
- **Customizable Time Ranges** (7, 14, 30, 90 days)
- **Statistics Cards** with averages and totals
- **Interactive Charts** with beautiful gradients
- **Export-Ready Data** for future features

### 👤 Profile Screen - Manage Your Health
- **Complete Profile Management** with avatar
- **BMI Calculator** with automatic health categorization
- **Weight Progress Tracking** with line charts
- **Goal Setting** for calories, protein, carbs, fat, and water
- **Activity Level Selection** (Sedentary to Very Active)
- **Smart Macro Calculations** based on your stats
- **Health Conditions Tracking** for personalized alerts
- **Allergy Management** for safe eating
- **Weight Logging** with date tracking
- **Dark Mode Toggle** with instant switching

### 🎨 UI/UX Excellence
- **🌙 Dark Mode Support** - Seamlessly switch between light and dark themes
- **Material Design 3** - Modern, clean interface
- **Google Fonts** - Beautiful Poppins typography throughout
- **Smooth Animations** - Fade, slide, and scale transitions
- **Gradient Backgrounds** - Eye-catching cyan-to-green gradients
- **Custom Navigation** - Animated bottom navigation bar
- **Responsive Design** - Works perfectly on phones and tablets
- **Haptic Feedback** - Subtle vibrations for better UX

### 🔐 Privacy & Security Features
- **🔒 100% Local Storage** - All data stays on YOUR device
- **🗄️ SQLite Database** - Fast, reliable, encrypted data storage
- **🔐 Secure Storage** - Sensitive data encrypted with platform security
  - iOS: Keychain encryption
  - Android: KeyStore encryption
- **🚫 No Cloud Sync** - Your data never leaves your phone
- **🚫 No Accounts** - Start using immediately, no sign-up
- **🚫 No Tracking** - Zero analytics, zero data collection
- **🗑️ Easy Data Export** - You own your data, take it anywhere
- **🔓 Open Architecture** - Know exactly where your data lives

### 🏥 Health & Wellness
- **Health Condition Tracking** - Monitor diabetes, hypertension, cholesterol, etc.
- **Allergy Alerts** - Set up warnings for specific ingredients
- **Custom Health Goals** - Personalize calorie and macro targets
- **BMI Monitoring** - Track your body mass index trends
- **Weight Progress** - Visualize your weight loss/gain journey
- **Activity-Based Goals** - Adjust calories based on your lifestyle

---

## 🗄️ Storage Architecture

### Three-Tier Security System

1. **SQLite Database** 📊
   - Food entries (all your logged meals)
   - User profile (personal information)
   - Water intake logs
   - Weight tracking history
   - Fast queries and efficient storage

2. **Secure Storage** 🔐
   - Theme preferences (dark mode)
   - Notification settings
   - Biometric preferences
   - Sensitive user data
   - Platform-native encryption

3. **SharedPreferences** ⚙️
   - App configuration
   - UI preferences
   - Migration flags

**Read more:** [Storage Implementation Guide](STORAGE_IMPLEMENTATION_GUIDE.md)

---

## 📦 Tech Stack

### Core
- **Flutter 3.10+** - Cross-platform UI framework
- **Dart 3.10+** - Programming language
- **Material Design 3** - Modern design system

### Storage & Database
- **sqflite ^2.3.0** - SQLite database for structured data
- **flutter_secure_storage ^9.0.0** - Encrypted storage for sensitive data
- **shared_preferences ^2.2.2** - Simple key-value storage
- **path ^1.8.3** - File path utilities

### UI & Charts
- **fl_chart ^0.66.0** - Beautiful interactive charts
- **google_fonts ^6.1.0** - Custom fonts (Poppins)
- **animations ^2.0.11** - Smooth transitions
- **flutter_slidable ^3.0.1** - Swipe actions

### Utilities
- **intl ^0.19.0** - Date/time formatting
- **csv ^6.0.0** - CSV parsing for food database
- **mobile_scanner ^3.5.5** - Barcode scanning support

---

## 🚀 Getting Started

### Prerequisites
```bash
Flutter SDK: 3.10 or higher
Dart SDK: 3.10 or higher
Android Studio or VS Code
Android/iOS device or emulator
```

### Installation

1. **Clone the repository**
```bash
cd C:\Users\katev\OneDrive\Desktop\apps\Privacy_NutriTrack
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the app**
```bash
flutter run
```

4. **Build for release**
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

---

## 📂 Project Structure

```
lib/
├── main.dart                          # App entry point & theme
├── models/
│   ├── food_entry.dart               # Food entry data model
│   ├── food_item.dart                # Food database item model
│   └── user_profile.dart             # User profile data model
├── screens/
│   ├── home_screen.dart              # Main dashboard with nutrition overview
│   ├── search_screen.dart            # Food search and database browser
│   ├── analytics_screen.dart         # Charts and statistics
│   ├── profile_screen.dart           # User profile and settings
│   ├── add_food_screen.dart          # Add/edit food entries
│   ├── edit_profile_screen.dart      # Edit user information
│   └── health_conditions_screen.dart # Health tracking setup
├── widgets/
│   ├── nutrition_ring_chart.dart     # Custom ring chart widget
│   ├── meal_section.dart             # Meal display component
│   └── water_tracker.dart            # Water intake tracker widget
└── utils/
    ├── storage_helper.dart           # Unified storage interface
    ├── database_helper.dart          # SQLite database manager
    ├── secure_storage_helper.dart    # Secure data encryption
    ├── food_data_loader.dart         # CSV food database loader
    └── health_alert_service.dart     # Health condition monitoring

assets/
└── Anuvaad_INDB_2024.11.csv         # Indian food database
```

---

## 🎯 How It Works

### Data Flow

```
User Input → Storage Helper → {SQLite DB | Secure Storage} → Device Storage
                                    ↓              ↓
                            Bulk Data    Sensitive Data
                         (Food entries)  (Settings/Theme)
```

### Storage Locations

#### What's in SQLite Database:
- ✅ All food entries (meals logged)
- ✅ User profile (name, age, weight, goals)
- ✅ Water intake records
- ✅ Weight tracking history

#### What's in Secure Storage:
- ✅ Dark mode preference
- ✅ Notification settings
- ✅ Biometric preferences
- ✅ Other sensitive settings

#### What's in SharedPreferences:
- ✅ App configuration
- ✅ Migration flags
- ✅ UI state

---

## 🔧 Customization

### Change App Colors
Edit `lib/main.dart`:
```dart
ThemeData _buildLightTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF00C9FF), // Change primary color
      secondary: const Color(0xFF92FE9D), // Change secondary color
    ),
  );
}
```

### Add Foods to Database
Edit the CSV file in `assets/Anuvaad_INDB_2024.11.csv` or add foods directly in the search screen.

### Modify Daily Goals
Default calculations are in `lib/screens/edit_profile_screen.dart` using the Mifflin-St Jeor equation.

---

## 📊 Database Schema

### Food Entries Table
```sql
CREATE TABLE food_entries (
  id TEXT PRIMARY KEY,
  foodName TEXT NOT NULL,
  calories REAL NOT NULL,
  protein REAL NOT NULL,
  carbs REAL NOT NULL,
  fat REAL NOT NULL,
  servingSize REAL NOT NULL,
  servingUnit TEXT NOT NULL,
  mealType TEXT NOT NULL,
  timestamp INTEGER NOT NULL
)
```

### User Profile Table
```sql
CREATE TABLE user_profile (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  age INTEGER NOT NULL,
  gender TEXT NOT NULL,
  height REAL NOT NULL,
  currentWeight REAL NOT NULL,
  targetWeight REAL NOT NULL,
  activityLevel TEXT NOT NULL,
  dailyCalorieGoal REAL NOT NULL,
  dailyProteinGoal REAL NOT NULL,
  dailyCarbsGoal REAL NOT NULL,
  dailyFatGoal REAL NOT NULL,
  dailyWaterGoal REAL NOT NULL,
  healthConditions TEXT,
  allergies TEXT
)
```

**See full schema:** [Storage Implementation Guide](STORAGE_IMPLEMENTATION_GUIDE.md)

---

## 🎨 Screenshots

*Add your app screenshots here*

| Home Screen | Search Screen | Analytics | Profile |
|------------|---------------|-----------|---------|
| ![Home](screenshots/home.png) | ![Search](screenshots/search.png) | ![Analytics](screenshots/analytics.png) | ![Profile](screenshots/profile.png) |

---

## 🔮 Roadmap & Future Features

### Planned Features
- [ ] **Meal Templates** - Save favorite meals for quick logging
- [ ] **Recipe Builder** - Create and track recipes
- [ ] **Photo Food Logging** - Take pictures of meals
- [ ] **Export to CSV/PDF** - Generate nutrition reports
- [ ] **Meal Reminders** - Notifications for logging meals
- [ ] **Barcode Integration** - Scan product barcodes
- [ ] **Nutrition API** - Connect to USDA or other databases
- [ ] **Streaks & Achievements** - Gamify your tracking
- [ ] **Multi-language Support** - Internationalization
- [ ] **Biometric Lock** - Secure app with fingerprint/face
- [ ] **Apple Health / Google Fit** - Sync with health apps
- [ ] **Widget Support** - Home screen widgets
- [ ] **Wear OS / WatchOS** - Smartwatch companion

### Current Limitations
- Barcode scanner UI exists but needs database integration
- No cloud backup (by design for privacy, but optional sync could be added)
- Limited to one user per device

---

## 🐛 Known Issues

### None! 🎉

All major features are working:
- ✅ Dark mode switching
- ✅ Data persistence
- ✅ All CRUD operations
- ✅ Chart rendering
- ✅ Profile management
- ✅ Weight tracking
- ✅ Water tracking
- ✅ Health conditions

**See troubleshooting:** [Storage Implementation Guide](STORAGE_IMPLEMENTATION_GUIDE.md#-troubleshooting)

---

## 📄 Documentation

- [Storage Implementation Guide](STORAGE_IMPLEMENTATION_GUIDE.md) - Complete storage architecture
- [Dark Mode Fix](DARK_MODE_FIX.md) - Theme switching documentation
- [Dark Mode Testing](DARK_MODE_TESTING.md) - Testing checklist
- [Setup Guide](SETUP_GUIDE.md) - Initial setup instructions

---

## 🤝 Contributing

This is a private project, but suggestions are welcome! Feel free to:
- Report bugs by creating an issue
- Suggest features
- Improve documentation

---

## 📜 License

This project is private and not for public distribution.

---

## 🙏 Acknowledgments

- **Flutter Team** - Amazing cross-platform framework
- **fl_chart** - Beautiful chart library
- **sqflite** - Reliable SQLite plugin
- **flutter_secure_storage** - Platform-native encryption
- **Material Design 3** - Modern design guidelines
- **Indian INDB Database** - Comprehensive Indian food data
- **Open Source Community** - All the amazing packages

---

## 💡 Why NutriTrack?

### Privacy First
Unlike other nutrition apps that upload your data to the cloud, NutriTrack keeps everything local. Your eating habits, weight, and health information are yours alone.

### No Subscriptions
No monthly fees, no premium tiers, no ads. Just a clean, functional app that respects your privacy and wallet.

### Beautiful Design
We believe health tracking shouldn't be boring. Every screen is carefully designed with smooth animations and modern aesthetics.

### Fully Functional
This isn't a half-baked prototype. NutriTrack is a complete nutrition tracking solution with all the features you need.

---

## 📞 Support

For questions, issues, or feature requests:
1. Check the [Documentation](#-documentation) section
2. Review [Known Issues](#-known-issues)
3. Create an issue in the repository
4. Contact the developer

---

<div align="center">

**Built with ❤️ and Flutter**

*Your health, your data, your choice*

[⬆ Back to Top](#-nutritrack---privacy-first-nutrition-tracking)

</div>
