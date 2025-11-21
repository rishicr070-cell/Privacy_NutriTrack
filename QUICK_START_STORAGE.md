# 🚀 Quick Start Guide - Storage Implementation

## What Changed?

Your app now uses **two storage systems** instead of one:

### Before ❌
- SharedPreferences only (simple key-value storage)
- Not ideal for large amounts of data
- No encryption for sensitive data

### After ✅
- **SQLite Database** for bulk data (food entries, profile)
- **Secure Storage** for sensitive data (theme, settings)
- **SharedPreferences** for simple config
- Better performance, security, and scalability

---

## 📥 Installation Steps

### 1. Update Dependencies
The `pubspec.yaml` has been updated. Run:
```bash
flutter pub get
```

This installs:
- `flutter_secure_storage` - Encrypted storage
- `sqflite` - SQLite database
- `path` - File path utilities

### 2. Files Added

Three new files in `lib/utils/`:

1. **database_helper.dart** 
   - Manages SQLite database
   - Handles all CRUD operations
   - Creates tables automatically

2. **secure_storage_helper.dart**
   - Manages encrypted storage
   - Platform-specific security
   - For sensitive data only

3. **storage_helper.dart** (updated)
   - Unified interface for both systems
   - Your app code uses this
   - Automatic routing to correct storage

### 3. Run the App
```bash
flutter run
```

The database will be created automatically on first run!

---

## 💻 How to Use in Your Code

### Nothing Changes! 🎉

Your existing code still works the same way:

```dart
// Still works exactly the same!
await StorageHelper.init();
await StorageHelper.saveFoodEntry(entry);
final entries = await StorageHelper.getFoodEntries();
```

**Behind the scenes**, data now goes to SQLite instead of SharedPreferences.

---

## 🗂️ What's Stored Where?

### SQLite Database (`nutritrack.db`)
Located: Device's database directory

Stores:
- ✅ Food entries (all your meals)
- ✅ User profile
- ✅ Water intake logs
- ✅ Weight tracking history

Size: Grows with usage (efficient compression)

### Secure Storage (Keychain/KeyStore)
Located: OS-protected secure storage

Stores:
- ✅ Dark mode preference
- ✅ Notification settings
- ✅ First run flag
- ✅ Biometric preferences

Size: Very small (< 1KB)

### SharedPreferences
Located: App preferences file

Stores:
- ✅ Migration flag
- ✅ App configuration

Size: Minimal

---

## 🔍 Verify Installation

### Check Database is Working
Add this temporarily to see stats:
```dart
// In your initState or button press
await StorageHelper.printStorageStats();
```

**Output should show:**
```
=== Storage Statistics ===
Food entries: 0
Water records: 0
Weight records: 0
User profile: not set
Dark mode: false
========================
```

### Check Secure Storage
```dart
// Test dark mode storage
await StorageHelper.setDarkMode(true);
final isDark = await StorageHelper.isDarkMode();
print('Dark mode: $isDark'); // Should print: true
```

---

## 🎯 Common Operations

### Save Food Entry
```dart
final entry = FoodEntry(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  foodName: 'Apple',
  calories: 95,
  protein: 0.5,
  carbs: 25,
  fat: 0.3,
  servingSize: 1,
  servingUnit: 'medium',
  mealType: 'snack',
  timestamp: DateTime.now(),
);

await StorageHelper.saveFoodEntry(entry);
```

### Get Today's Entries
```dart
final allEntries = await StorageHelper.getFoodEntries();
final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

final todayEntries = allEntries.where((entry) {
  final entryDate = DateFormat('yyyy-MM-dd').format(entry.timestamp);
  return entryDate == today;
}).toList();
```

### Get Entries by Date Range
```dart
final startDate = DateTime.now().subtract(Duration(days: 7));
final endDate = DateTime.now();

final weekEntries = await StorageHelper.getFoodEntriesByDateRange(
  startDate,
  endDate,
);
```

### Save User Profile
```dart
final profile = UserProfile(
  name: 'John Doe',
  age: 30,
  gender: 'Male',
  height: 175,
  currentWeight: 75,
  targetWeight: 70,
  activityLevel: 'moderate',
  // ... other fields
);

await StorageHelper.saveUserProfile(profile);
```

### Track Water Intake
```dart
final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
await StorageHelper.saveWaterIntake(today, 2000); // 2000ml
```

### Track Weight
```dart
final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
await StorageHelper.saveWeight(today, 75.5); // 75.5kg
```

---

## 🔧 Troubleshooting

### "Database not found" error
✅ **Solution**: Database creates automatically. Just run the app!

### "Cannot write to secure storage"
✅ **Solution**: 
- Android: Ensure device has lock screen
- iOS: Check keychain access
- Try: `await SecureStorageHelper().clearAll()`

### "Migration failed"
✅ **Solution**: Clear old data first
```dart
await StorageHelper.clearAllData();
```

### Data not showing up
✅ **Solution**: Check statistics
```dart
await StorageHelper.printStorageStats();
```

---

## 🎓 Learn More

### Full Documentation
- [Storage Implementation Guide](STORAGE_IMPLEMENTATION_GUIDE.md) - Complete technical details
- [README.md](README.md) - App overview and features

### Key Concepts

**SQLite Advantages:**
- Fast queries on large datasets
- Structured data with relations
- SQL queries for complex filtering
- Automatic indexing
- Transaction support

**Secure Storage Advantages:**
- OS-level encryption
- Biometric integration
- Keychain/KeyStore backed
- Automatic key management

**When to use which:**
- **SQLite**: List data, bulk records, complex queries
- **Secure Storage**: Passwords, tokens, sensitive preferences
- **SharedPreferences**: Simple config, flags

---

## ✅ Migration Checklist

When updating an existing installation:

- [x] Update pubspec.yaml dependencies
- [x] Run `flutter pub get`
- [x] New storage files added
- [x] Existing code still works
- [x] Data migrates automatically
- [x] Old data preserved
- [x] No code changes needed in screens
- [x] Test dark mode toggle
- [x] Test food entry saving
- [x] Test profile saving

---

## 🎉 You're Done!

The storage implementation is complete. Your app now has:

✅ **Better Performance** - SQLite is optimized for data operations
✅ **Better Security** - Sensitive data encrypted
✅ **Better Scalability** - Can handle thousands of entries
✅ **Better Organization** - Structured data with relations
✅ **Better Privacy** - Everything stays on device

**No code changes needed in your UI!** Everything works the same way from your perspective.

---

## 📞 Need Help?

1. Check [STORAGE_IMPLEMENTATION_GUIDE.md](STORAGE_IMPLEMENTATION_GUIDE.md)
2. Review troubleshooting section above
3. Check Flutter docs:
   - [sqflite](https://pub.dev/packages/sqflite)
   - [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage)

---

**Updated:** November 21, 2025
**Status:** ✅ Ready to Use
