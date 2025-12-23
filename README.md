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
- **Animated Progress Ring** with milestone markers and counting animations
- **Skeleton Loaders** with shimmer effects for smooth loading states
- **Staggered Animations** for meal sections with sequential fade-in
- **Smart Empty States** with custom illustrations and actionable CTAs
- **Nutrition Ring Chart** showing calories, protein, carbs, and fat at a glance
- **Interactive Water Tracker** with animated glass and wave motion
- **Meal Organization** by Breakfast, Lunch, Dinner, and Snacks
- **Quick Stats Cards** showing meals logged, protein intake, and water consumption
- **Swipe-to-Delete** for easy entry management
- **Pull-to-Refresh** for instant data updates

### 🔍 Search Screen - Find Foods Fast
- **10,000+ Indian Foods Database** (Anuvaad INDB 2024)
- **Real-time Smart Search** with instant filtering
- **Auto-Calculation** - Enter serving size, nutrients calculate automatically
- **Category Browsing** (Fruits, Proteins, Grains, Vegetables, Dairy, Nuts & Seeds)
- **Quick Add Chips** for common foods
- **Barcode Scanner** (mobile only, with food detection AI)
- **Empty State Prompts** guiding users to search or scan

### 📊 Analytics Screen - Track Your Progress
- **Skeleton Chart Loaders** for better perceived performance
- **Calorie Trend Chart** with smooth line graphs
- **Macro Distribution Analysis** over time
- **Meal Distribution Pie Chart**
- **Customizable Time Ranges** (7, 14, 30, 90 days)
- **Statistics Cards** with averages and totals
- **Interactive Charts** with beautiful gradients
- **Smart Empty States** when no data is available

### 👤 Profile Screen - Manage Your Health
- **Complete Profile Management** with avatar
- **BMI Calculator** with automatic health categorization
- **Weight Progress Tracking** with line charts
- **Goal Setting** for calories, protein, carbs, fat, and water
- **Activity Level Selection** (Sedentary to Very Active)
- **Smart Macro Calculations** using Mifflin-St Jeor equation
- **Health Conditions Tracking** for personalized alerts
- **Allergy Management** for safe eating
- **Dark Mode Toggle** with instant switching

### 🎨 UI/UX Excellence
- **🌙 Dark Mode Support** - Seamlessly switch between light and dark themes
- **Material Design 3** - Modern, clean interface
- **Skeleton Loaders** - Shimmer effects during loading
- **Staggered Animations** - Sequential fade and slide transitions
- **Animated Counters** - Numbers count up smoothly
- **Progress Rings** - Circular indicators with milestones
- **Empty States** - Custom illustrations with helpful CTAs
- **Smooth Animations** - Fade, slide, and scale transitions
- **Gradient Backgrounds** - Eye-catching cyan-to-green gradients
- **Responsive Design** - Works perfectly on phones and tablets

### 🔐 Privacy & Security Features
- **🔒 100% Local Storage** - All data stays on YOUR device
- **🗄️ SQLite Database** - Fast, reliable data storage
- **🔐 Secure Storage** - Sensitive data encrypted with platform security
  - iOS: Keychain encryption
  - Android: KeyStore encryption
- **🚫 No Cloud Sync** - Your data never leaves your phone
- **🚫 No Accounts** - Start using immediately, no sign-up
- **🚫 No Tracking** - Zero analytics, zero data collection
- **🗑️ Easy Data Export** - You own your data, take it anywhere

### 🏥 Health & Wellness
- **Health Condition Tracking** - Monitor diabetes, hypertension, cholesterol
- **Allergy Alerts** - Set up warnings for specific ingredients
- **Custom Health Goals** - Personalize calorie and macro targets
- **BMI Monitoring** - Track your body mass index trends
- **Weight Progress** - Visualize your weight loss/gain journey
- **Activity-Based Goals** - Adjust calories based on your lifestyle

### 🤖 AI-Powered Features
- **Food Detection** - Take photos of meals for automatic recognition
- **TensorFlow Lite** - On-device ML model for food classification
- **Smart Suggestions** - Based on your eating patterns
- **Nutrition Insights** - AI-powered health recommendations

---

## 🚀 Quick Start

### Prerequisites
```bash
Flutter SDK: 3.10 or higher
Dart SDK: 3.10 or higher
Android Studio or VS Code
Android/iOS device or emulator
```

### Installation

1. **Install dependencies**
```bash
flutter pub get
```

2. **Run the app**
```bash
flutter run
```

3. **Build for release**
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

### First Time Setup

1. Navigate to **Profile tab** (bottom right)
2. Tap **"Create Profile"**
3. Fill in your information (name, age, gender, height, weight)
4. Select your activity level
5. Tap **"Auto Calculate"** for recommended macros
6. Save and start tracking!

---

## 📦 Tech Stack

### Core
- **Flutter 3.10+** - Cross-platform UI framework
- **Dart 3.10+** - Programming language
- **Material Design 3** - Modern design system

### Storage & Database
- **sqflite ^2.3.0** - SQLite database
- **flutter_secure_storage ^9.0.0** - Encrypted storage
- **shared_preferences ^2.2.2** - Key-value storage

### UI & Animations
- **fl_chart ^0.66.0** - Interactive charts
- **flutter_staggered_animations ^1.1.1** - Staggered list animations
- **shimmer ^3.0.0** - Skeleton loader shimmer effects
- **animations ^2.0.11** - Smooth transitions
- **flutter_slidable ^3.0.1** - Swipe actions
- **google_fonts ^6.1.0** - Custom fonts

### AI & ML
- **tflite_flutter ^0.11.0** - TensorFlow Lite for food detection
- **camera ^0.10.5+5** - Camera access
- **image ^4.0.17** - Image processing
- **image_picker ^1.0.4** - Photo selection

### Utilities
- **intl ^0.19.0** - Date/time formatting
- **csv ^6.0.0** - CSV parsing for food database
- **mobile_scanner ^3.5.5** - Barcode scanning
- **provider ^6.1.1** - State management
- **flutter_tts ^4.0.2** - Text-to-speech

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
│   ├── home_screen.dart              # Main dashboard
│   ├── search_screen.dart            # Food search & scanner
│   ├── analytics_screen.dart         # Charts and statistics
│   ├── profile_screen.dart           # User profile & settings
│   ├── add_food_screen.dart          # Add/edit food entries
│   ├── edit_profile_screen.dart      # Edit user information
│   ├── health_conditions_screen.dart # Health tracking setup
│   └── food_scanner_screen.dart      # AI food detection
├── widgets/
│   ├── nutrition_ring_chart.dart     # Custom ring chart
│   ├── meal_section.dart             # Meal display component
│   ├── water_tracker.dart            # Water intake tracker
│   ├── skeleton_loader.dart          # Shimmer loading states
│   ├── animated_progress_ring.dart   # Circular progress with milestones
│   ├── animated_counter.dart         # Counting number animations
│   └── empty_state_widget.dart       # Illustrated empty states
├── utils/
│   ├── storage_helper.dart           # Unified storage interface
│   ├── database_helper.dart          # SQLite database manager
│   ├── secure_storage_helper.dart    # Secure data encryption
│   ├── food_data_loader.dart         # CSV food database loader
│   └── health_alert_service.dart     # Health condition monitoring
└── theme/
    └── theme_manager.dart            # Theme state management

assets/
├── Anuvaad_INDB_2024.11.csv         # Indian food database (10,000+ foods)
└── models/
    └── Fooddetector.tflite           # AI food detection model
```

---

## 🎯 How to Use

### Adding Food (Smart Way)
1. Tap **"Add Food"** button
2. Start typing (e.g., "chicken")
3. See real-time search results
4. Select the food you want
5. Adjust serving size (e.g., 150g instead of 100g)
6. Nutrients calculate automatically!
7. Save - done in seconds! ✨

### Using AI Food Scanner
1. Tap **Search tab** → **Camera icon**
2. Point camera at your meal
3. AI detects the food automatically
4. Review and adjust if needed
5. Save to your diary

### Tracking Water
1. Go to **Home tab**
2. Find **Water Tracker card**
3. Tap **+** to add 250ml
4. Watch the animated glass fill up!

### Viewing Analytics
1. Go to **Analytics tab**
2. Select time range (7/14/30/90 days)
3. View calorie trends, macro distribution, and meal patterns

---

## 🗄️ Storage Architecture

### Three-Tier Security System

1. **SQLite Database** 📊
   - Food entries (all logged meals)
   - User profile (personal information)
   - Water intake logs
   - Weight tracking history

2. **Secure Storage** 🔐
   - Theme preferences (dark mode)
   - Notification settings
   - Biometric preferences
   - Sensitive user data

3. **SharedPreferences** ⚙️
   - App configuration
   - UI preferences
   - Migration flags

---

## 🎨 Latest UI Enhancements

### Skeleton Loaders
- Shimmer effects during loading
- Realistic placeholders for cards, charts, and lists
- Dark mode compatible
- Reduces perceived wait time

### Staggered Animations
- Sequential fade-in for meal sections
- Smooth slide-up transitions
- Perfect timing (600ms main, 400ms meals)
- Professional, polished feel

### Smart Empty States
- Custom illustrations for different scenarios
- No Meals: Plate with utensils
- No Data: Bar chart illustration
- No Search Results: Magnifying glass
- Search Prompt: Barcode scanner frame
- Actionable CTAs with gradient buttons

### Enhanced Progress Indicators
- Animated circular rings with milestones
- Smooth counting animations
- Color transitions (green → yellow → orange → red)
- Milestone markers at 25%, 50%, 75%, 100%

---

## 🌙 Dark Mode

Fully functional dark mode with:
- **Instant switching** - Changes immediately
- **Persistent** - Remembers your choice
- **Complete** - All screens adapt
- **Smooth** - Proper system UI updates
- **Material 3** - Modern design system

**Colors:**
- Light: Clean white backgrounds, dark text
- Dark: Deep navy backgrounds (#1A1A2E), light text
- Both: Vibrant cyan (#00C9FF) to mint green (#92FE9D) gradients

---

## 🔧 Configuration

### Android Setup
- **Gradle**: 7.6.4
- **AGP**: 7.4.2
- **Kotlin**: 1.9.22
- **compileSdk**: 34
- **minSdk**: 24
- **Java**: 17

### Build Commands
```bash
# Fresh setup
flutter clean
flutter pub get

# Run app
flutter run

# Build APK
flutter build apk --release

# Build for iOS
flutter build ios --release
```

---

## 🐛 Troubleshooting

### Dependencies Won't Install
```bash
flutter clean
flutter pub get
```

### App Won't Run
```bash
flutter doctor
flutter run --verbose
```

### Charts Not Showing
- Add some food entries first
- Try different time ranges
- Pull down to refresh

### Barcode Scanner Not Working
- Grant camera permissions
- Use manual search instead (web doesn't support scanner)

---

## 🔮 Future Enhancements

- [ ] **Meal Templates** - Save favorite meals
- [ ] **Recipe Builder** - Create and track recipes
- [ ] **Export to CSV/PDF** - Generate nutrition reports
- [ ] **Meal Reminders** - Notifications for logging
- [ ] **Streaks & Achievements** - Gamify tracking
- [ ] **Multi-language Support** - Internationalization
- [ ] **Apple Health / Google Fit** - Sync with health apps
- [ ] **Widget Support** - Home screen widgets
- [ ] **Wear OS / WatchOS** - Smartwatch companion

---

## 📄 Documentation

All documentation has been consolidated into this README. For specific topics:
- **Quick Start**: See [Quick Start](#-quick-start) section above
- **UI Features**: See [Latest UI Enhancements](#-latest-ui-enhancements)
- **Dark Mode**: See [Dark Mode](#-dark-mode) section
- **Storage**: See [Storage Architecture](#️-storage-architecture)
- **Troubleshooting**: See [Troubleshooting](#-troubleshooting)

---

## 🙏 Acknowledgments

- **Flutter Team** - Amazing cross-platform framework
- **fl_chart** - Beautiful chart library
- **sqflite** - Reliable SQLite plugin
- **flutter_secure_storage** - Platform-native encryption
- **shimmer** - Smooth loading animations
- **flutter_staggered_animations** - Delightful list animations
- **Material Design 3** - Modern design guidelines
- **Indian INDB Database** - Comprehensive Indian food data
- **TensorFlow** - AI/ML capabilities
- **Open Source Community** - All the amazing packages

---

## 💡 Why NutriTrack?

### Privacy First
Unlike other nutrition apps that upload your data to the cloud, NutriTrack keeps everything local. Your eating habits, weight, and health information are yours alone.

### No Subscriptions
No monthly fees, no premium tiers, no ads. Just a clean, functional app that respects your privacy and wallet.

### Beautiful Design
We believe health tracking shouldn't be boring. Every screen is carefully designed with smooth animations, skeleton loaders, and modern aesthetics.

### Fully Functional
This isn't a half-baked prototype. NutriTrack is a complete nutrition tracking solution with AI-powered food detection, 10,000+ foods database, and all the features you need.

---

<div align="center">

**Built with ❤️ and Flutter**

*Your health, your data, your choice*

[⬆ Back to Top](#-nutritrack---privacy-first-nutrition-tracking)

</div>
