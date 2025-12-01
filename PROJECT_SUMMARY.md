# NutriTrack - Privacy-First Nutrition Tracking App
## Project Summary Document for AI Context

---

## PROJECT OVERVIEW

**App Name:** NutriTrack
**Type:** Privacy-First Nutrition Tracking Application
**Platforms:** Web (Browser localStorage), Mobile (SQLite), Desktop (SQLite)
**Framework:** Flutter
**Current Status:** Core functionality implemented, storage working across all platforms

---

## COMPLETED FEATURES

### 1. USER PROFILE MANAGEMENT
- **Create Profile Screen** with comprehensive form:
  - Personal info: Name, Age, Gender, Height
  - Weight tracking: Current weight, Target weight
  - Activity level selection (Sedentary to Very Active)
  - Automatic macro calculation using Mifflin-St Jeor Equation
  - Daily goals: Calories, Protein, Carbs, Fat, Water
  - Manual goal adjustment with sliders
  - Health conditions and allergies tracking

- **Profile Display:**
  - Avatar with initials
  - Stats grid showing BMI, daily goals, progress
  - Weight chart visualization (using fl_chart)
  - Goals overview card
  - Settings integration

### 2. FOOD TRACKING SYSTEM
- **Food Entry Model** with properties:
  - Name, Calories, Protein, Carbs, Fat
  - Serving size and unit
  - Meal type (Breakfast, Lunch, Dinner, Snack)
  - Timestamp

- **Food Search & Database:**
  - Pre-populated food database with common items
  - Search functionality with real-time filtering
  - Categories: Fruits, Proteins, Carbs, Vegetables, Dairy, Nuts
  - Category-based browsing
  - Quick add from search results

- **Meal Sections:**
  - Four meal categories with color coding
  - Visual meal type indicators (icons)
  - Add/Edit/Delete food entries
  - Swipe to delete functionality (flutter_slidable)

- **Barcode Scanner:**
  - Implemented using mobile_scanner package
  - Disabled on web (not supported)
  - Shows helpful message on web platform

### 3. HOME SCREEN
- **Daily Overview:**
  - Gradient welcome card with personalized greeting
  - Current date display
  - Calorie progress indicator

- **Nutrition Visualization:**
  - Custom ring chart (CustomPainter) showing:
    - Protein (outer ring, blue)
    - Carbs (middle ring, orange)
    - Fat (inner ring, purple)
  - Central calorie count display
  - Progress bars for each macro
  - Color-coded goals

- **Water Tracker:**
  - Visual cup representation
  - Quick add/subtract buttons (+250ml)
  - Daily goal tracking
  - Progress percentage

- **Meal Sections:**
  - Expandable sections for each meal
  - Total macro summary per meal
  - Empty state with "Add Food" prompts
  - Floating Action Button for quick food entry

### 4. ANALYTICS SCREEN
- **Weekly Overview:**
  - Calorie trend chart
  - Average daily intake
  - Weekly comparison

- **Macro Distribution:**
  - Pie chart showing protein/carbs/fat split
  - Percentage breakdown
  - Daily averages

- **Progress Tracking:**
  - Weight change graph
  - Calorie adherence stats
  - Streak counter

### 5. NAVIGATION & UI
- **Bottom Navigation:**
  - Custom animated navigation bar
  - Icons: Home, Search, Analytics, Profile
  - Active state indicators
  - Smooth transitions with AnimatedSwitcher

- **Theme System:**
  - Light and Dark mode support
  - Color scheme: Primary (#6C63FF), Secondary colors
  - Material 3 design
  - Custom gradient backgrounds
  - Consistent card styling (20px border radius)

- **Animations:**
  - Page transitions
  - Loading indicators
  - Smooth macro updates
  - Interactive elements

---

## STORAGE ARCHITECTURE (CRITICAL - PLATFORM SPECIFIC)

### Web Platform (Browser):
```dart
// Uses custom WebStorage class (dart:html)
// Direct access to browser's localStorage
// Prefix: "nutritrack_"
// Keys: user_profile, food_entries, water_intake, weight_data, dark_mode, etc.
```

**Implementation:**
- Custom `WebStorage` class wraps `dart:html` localStorage API
- Synchronous operations
- Persistent across browser sessions
- Located in: `lib/utils/web_storage.dart`

### Mobile/Desktop Platforms:
```dart
// Uses SQLite database (sqflite package)
// Database name: nutritrack.db
// Tables: food_entries, user_profile, water_intake, weight_log
// Secure storage for sensitive data (flutter_secure_storage)
```

**Implementation:**
- `DatabaseHelper` class manages SQLite operations
- CRUD operations for all data types
- Located in: `lib/utils/database_helper.dart`

### Unified Storage Layer:
```dart
// StorageHelper class (lib/utils/storage_helper.dart)
// Automatically detects platform using kIsWeb
// Routes to appropriate storage backend
```

**Key Methods:**
- `getUserProfile()` / `saveUserProfile()`
- `getFoodEntries()` / `saveFoodEntry()` / `deleteFoodEntry()`
- `getWaterIntake()` / `saveWaterIntake()`
- `getWeightData()` / `saveWeight()`
- `isDarkMode()` / `setDarkMode()`
- `clearAllData()`

---

## FILE STRUCTURE

```
lib/
├── main.dart                          # App entry point, theme setup
├── models/
│   ├── food_entry.dart               # Food entry data model
│   └── user_profile.dart             # User profile data model
├── screens/
│   ├── home_screen.dart              # Main dashboard
│   ├── search_screen.dart            # Food search & barcode scanner
│   ├── analytics_screen.dart         # Charts and stats
│   ├── profile_screen.dart           # User profile display
│   ├── edit_profile_screen.dart      # Profile creation/editing
│   └── add_food_screen.dart          # Manual food entry
├── widgets/
│   ├── nutrition_ring_chart.dart     # Custom ring chart (CustomPainter)
│   ├── meal_section.dart             # Expandable meal sections
│   └── water_tracker.dart            # Water intake widget
├── utils/
│   ├── storage_helper.dart           # Unified storage interface
│   ├── database_helper.dart          # SQLite implementation
│   ├── database_helper_stub.dart     # Web stub for SQLite
│   ├── web_storage.dart              # Web localStorage wrapper
│   ├── web_storage_stub.dart         # Non-web stub
│   └── secure_storage_helper.dart    # Secure storage wrapper
└── theme/
    └── theme_manager.dart            # Theme state management (Provider)
```

---

## DEPENDENCIES (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  shared_preferences: ^2.2.2          # Key-value storage
  flutter_secure_storage: ^9.0.0     # Encrypted storage
  sqflite: ^2.3.0                     # SQLite database (mobile/desktop)
  path: ^1.8.3                        # Path manipulation
  fl_chart: ^0.66.0                   # Charts and graphs
  intl: ^0.19.0                       # Date formatting
  mobile_scanner: ^3.5.5              # Barcode scanning (mobile only)
  animations: ^2.0.11                 # Page transitions
  flutter_slidable: ^3.0.1            # Swipe actions
  google_fonts: ^6.1.0                # Custom fonts (disabled on web)
  csv: ^6.0.0                         # CSV export/import
  provider: ^6.1.1                    # State management
```

---

## KEY TECHNICAL DECISIONS

### 1. Platform-Specific Storage
**Problem:** SQLite (sqflite) doesn't work on web browsers
**Solution:** 
- Created dual storage system
- Web uses browser's localStorage directly
- Mobile/Desktop uses SQLite
- Single unified API via StorageHelper

### 2. Web Storage Implementation
**Why custom WebStorage class:**
- shared_preferences on web was not persisting data reliably in debug mode
- Direct localStorage access ensures data persistence
- Added prefix "nutritrack_" to avoid key conflicts

### 3. Barcode Scanner
**Problem:** mobile_scanner doesn't work on web
**Solution:**
- Wrapped scanner in platform check (kIsWeb)
- Shows informative message on web
- Fully functional on mobile platforms

### 4. Google Fonts
**Problem:** Google Fonts caused issues on web in debug mode
**Solution:**
- Commented out Google Fonts imports
- Using default system fonts
- Can be re-enabled for production builds

---

## DATA MODELS

### UserProfile
```dart
class UserProfile {
  final String name;
  final int age;
  final String gender;              // 'male', 'female', 'other'
  final double height;              // cm
  final double currentWeight;       // kg
  final double targetWeight;        // kg
  final String activityLevel;       // 'sedentary', 'light', 'moderate', 'active', 'very_active'
  final double dailyCalorieGoal;
  final double dailyProteinGoal;    // grams
  final double dailyCarbsGoal;      // grams
  final double dailyFatGoal;        // grams
  final double dailyWaterGoal;      // ml
  final List<String> healthConditions;
  final List<String> allergies;
}
```

### FoodEntry
```dart
class FoodEntry {
  final String id;                  // Unique identifier
  final String name;                // Food name (stored as foodName in DB)
  final double calories;
  final double protein;             // grams
  final double carbs;               // grams
  final double fat;                 // grams
  final double servingSize;
  final String servingUnit;         // 'g', 'ml', 'piece', 'cup', etc.
  final DateTime timestamp;
  final String mealType;            // 'breakfast', 'lunch', 'dinner', 'snack'
}
```

---

## KNOWN ISSUES & WORKAROUNDS

### 1. Debug Mode Data Persistence
**Issue:** `flutter run -d chrome` creates temporary browser profiles
**Workaround:** Data persists within the same debug session
**For testing persistence:** Use `flutter build web` then serve via HTTP server
**Production:** Not an issue - deployed apps use regular browser storage

### 2. Google Fonts on Web
**Issue:** Font loading issues in web debug mode
**Current State:** Disabled, using system fonts
**TODO:** Re-enable for production builds

### 3. Mobile Scanner on Web
**Status:** Intentionally disabled with helpful user message
**Reason:** Camera access not supported in browser context

---

## TESTING NOTES

### Testing Storage Persistence (Web):
1. Build: `flutter build web`
2. Serve: `cd build/web && python -m http.server 8000`
3. Open: `http://localhost:8000` in regular Chrome
4. Create profile, close browser completely
5. Reopen: Data should persist

### Verifying localStorage (Chrome DevTools):
1. Press F12
2. Go to Application tab
3. Expand Local Storage → http://localhost:xxx
4. Look for keys starting with "nutritrack_"

### Testing on Mobile:
1. Connect device or start emulator
2. Run: `flutter run`
3. Data persists using SQLite automatically

---

## CURRENT STATE SUMMARY

✅ **Working:**
- User profile creation and editing
- Food entry tracking (add, edit, delete)
- Water intake logging
- Weight tracking
- Analytics and charts
- Search functionality
- Platform-specific storage (web localStorage, mobile SQLite)
- Dark/Light theme
- Navigation and UI animations

⚠️ **Limitations:**
- Debug mode web doesn't persist between restarts (normal behavior)
- Barcode scanner only works on mobile
- Google Fonts disabled on web

🚀 **Ready for:**
- Additional features
- UI refinements
- Export/Import functionality
- More analytics
- Recipe/meal planning
- Social features

---

## NEXT STEPS / ENHANCEMENT IDEAS

### High Priority:
1. **Data Export/Import:**
   - CSV export for food entries
   - JSON backup/restore
   - Share data between devices

2. **Enhanced Analytics:**
   - Monthly trends
   - Nutrient deficiency alerts
   - Meal timing analysis
   - Comparison with goals over time

3. **Food Database:**
   - Expand built-in food database
   - API integration (USDA FoodData Central, OpenFoodFacts)
   - User custom foods
   - Recent/favorites list

### Medium Priority:
4. **Meal Planning:**
   - Save favorite meals
   - Meal templates
   - Copy meals from previous days
   - Quick-add frequent combinations

5. **Goals & Streaks:**
   - Achievement system
   - Streak tracking
   - Weekly challenges
   - Progress milestones

6. **Photos:**
   - Meal photo logging
   - Before/after photos
   - Gallery view

### Low Priority:
7. **Social Features:**
   - Share recipes (optional)
   - Community meal ideas
   - Friend challenges

8. **Integrations:**
   - Fitness tracker sync
   - Calendar integration
   - Notifications/reminders

9. **Advanced Features:**
   - Macro timing (pre/post workout)
   - Intermittent fasting timer
   - Recipe calculator
   - Restaurant menu search

---

## DEPLOYMENT READINESS

### Web Deployment:
```bash
flutter build web --release
# Upload build/web folder to:
# - Firebase Hosting
# - Vercel
# - Netlify
# - GitHub Pages
```

### Mobile Deployment:
```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release
```

### What works in production:
- ✅ All storage persists correctly
- ✅ Web uses localStorage permanently
- ✅ Mobile uses SQLite
- ✅ All features functional
- ✅ Cross-platform compatibility

---

## IMPORTANT NOTES FOR FUTURE DEVELOPMENT

1. **Never use localStorage/sessionStorage APIs directly in artifacts** - they're not supported in Claude.ai environment

2. **Storage Helper is the single source of truth** - Always use StorageHelper methods, never access storage directly

3. **Platform checking is critical** - Always use `kIsWeb` to differentiate web vs mobile behavior

4. **Web debugging vs production** - Data persistence works differently in debug mode vs production

5. **Model compatibility** - Ensure JSON serialization works for both web (localStorage) and mobile (SQLite)

6. **Testing checklist:**
   - Test on web (Chrome)
   - Test on mobile (Android emulator)
   - Test data persistence
   - Test storage operations
   - Test platform-specific features

---

## CONTACT POINTS FOR DEBUGGING

### Storage Issues:
- Check: `lib/utils/storage_helper.dart`
- Web: `lib/utils/web_storage.dart`
- Mobile: `lib/utils/database_helper.dart`

### UI Issues:
- Screens: `lib/screens/`
- Widgets: `lib/widgets/`
- Theme: `lib/theme/theme_manager.dart`

### Data Issues:
- Models: `lib/models/`
- Ensure JSON serialization (toJson/fromJson) is correct

---

## CONCLUSION

This is a fully functional, cross-platform nutrition tracking app with a robust storage system that automatically adapts to the platform. The core features are complete, data persists correctly, and the app is ready for enhancement with additional features.

The storage architecture is the most critical component - it successfully solves the challenge of having a unified codebase that works seamlessly on both web (localStorage) and mobile (SQLite) platforms.

Ready for next steps! 🚀
