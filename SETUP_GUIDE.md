# 🚀 Quick Setup Guide

## Installation Steps

### 1. Install Dependencies
Open your terminal in the project directory and run:
```bash
flutter pub get
```

This will install all required packages:
- shared_preferences (local storage)
- fl_chart (charts)
- intl (date formatting)
- mobile_scanner (barcode scanning)
- animations (smooth transitions)
- flutter_slidable (swipe actions)
- google_fonts (custom fonts)

### 2. Run the App

#### On Android Emulator
```bash
flutter run
```

#### On iOS Simulator (Mac only)
```bash
flutter run -d ios
```

#### On Chrome (Web)
```bash
flutter run -d chrome
```

### 3. First Launch Setup

When you first launch the app:

1. **Navigate to Profile tab** (bottom right icon)
2. **Tap "Create Profile"** button
3. **Fill in your information:**
   - Name
   - Age
   - Gender
   - Height (cm)
   - Current Weight (kg)
   - Target Weight (kg)
   - Activity Level
4. **Tap "Auto Calculate"** to set recommended macros
5. **Tap "Save"** in the top right

You're now ready to start tracking!

## 🎯 Quick Start Guide

### Adding Your First Meal

**Method 1: From Home Screen**
1. Tap the **"Add Food"** floating button
2. Select meal type or tap on a meal section
3. Fill in food details
4. Tap "Save"

**Method 2: From Search Screen**
1. Go to **Search tab** (bottom nav)
2. Search for a food or browse categories
3. Tap on a food to add it
4. It's automatically added to the selected meal type!

**Method 3: Quick Add from Add Food Screen**
1. Tap **"Add Food"** button
2. Use the **"Quick Add Common Foods"** chips at the bottom
3. Modify if needed
4. Save

### Tracking Water Intake
1. Go to **Home tab**
2. Find the **Water Tracker card**
3. Tap **+** to add 250ml
4. Tap **-** to remove 250ml
5. Watch your progress bar fill up!

### Viewing Analytics
1. Go to **Analytics tab**
2. Select time range (7, 14, 30, or 90 days)
3. View:
   - Daily calorie trends
   - Macro distribution over time
   - Meal distribution pie chart
   - Average statistics

### Logging Weight
1. Go to **Profile tab**
2. Tap **"Log"** button in Weight Progress card
3. Enter your current weight
4. Save
5. Watch your progress chart update!

## 🎨 Customization Tips

### Changing Theme
The app supports **Dark Mode**! It will:
- Auto-detect system theme preference
- Remember your last theme choice
- Apply beautiful gradients in both modes

### Adjusting Daily Goals
1. Go to **Profile tab**
2. Tap **Edit icon** (top right of profile card)
3. Scroll to **"Daily Goals"** section
4. Adjust sliders for:
   - Calories (1200-3500 kcal)
   - Protein (50-300g)
   - Carbs (50-400g)
   - Fat (20-150g)
   - Water (1000-4000ml)
5. Or tap **"Auto Calculate"** for recommended values

## 🔧 Troubleshooting

### Dependencies Won't Install
```bash
flutter clean
flutter pub get
```

### App Won't Run
```bash
flutter doctor
```
Fix any issues shown, then:
```bash
flutter run
```

### Charts Not Showing
- Make sure you've added some food entries
- Try selecting a different time range
- Pull down to refresh

### Barcode Scanner Not Working
- Ensure camera permissions are granted
- Currently shows scanned codes (full database integration can be added)
- Use manual search instead

## 📱 Platform-Specific Notes

### Android
- Minimum SDK: 21 (Android 5.0)
- Camera permission needed for barcode scanner
- Works on all Android devices

### iOS
- Minimum iOS: 12.0
- Camera permission needed for barcode scanner
- Requires Xcode for building

### Web
- All features work except barcode scanner
- Use Chrome or Edge for best experience
- Local storage uses browser storage

## 💡 Pro Tips

1. **Set Realistic Goals**: Use the auto-calculate feature based on your stats
2. **Log Immediately**: Add foods right after eating for accuracy
3. **Use Quick Add**: Save time with the quick add food chips
4. **Check Analytics**: Review weekly to spot patterns
5. **Track Water**: Proper hydration is crucial for health
6. **Weight Weekly**: Log weight once a week for better trends

## 🎯 What to Track

### Essential
- ✅ All meals and snacks
- ✅ Water intake
- ✅ Daily weight (optional, weekly recommended)

### Optional
- Meal timing
- Exercise (future feature)
- Notes (can be added to food entries)

## 📊 Understanding Your Data

### Nutrition Ring Chart
- **Outer Ring**: Protein (Blue)
- **Middle Ring**: Carbs (Orange)
- **Inner Ring**: Fat (Purple)
- **Center**: Total calories

### BMI Categories
- **Underweight**: < 18.5
- **Normal**: 18.5 - 24.9
- **Overweight**: 25.0 - 29.9
- **Obese**: ≥ 30.0

### Activity Levels
- **Sedentary**: Little to no exercise
- **Light**: Exercise 1-3 days/week
- **Moderate**: Exercise 3-5 days/week
- **Active**: Exercise 6-7 days/week
- **Very Active**: Physical job + training

## 🔐 Privacy Note

**All your data is stored locally on your device.**
- No internet required (except for barcode lookup in future)
- No accounts or cloud sync
- No tracking or analytics
- Export/backup features can be added for personal use

## 🆘 Need Help?

Common questions:

**Q: Can I edit a food entry?**
A: Currently you can delete and re-add. Edit feature coming soon!

**Q: How do I clear all data?**
A: Profile tab → Settings → Clear All Data (be careful!)

**Q: Can I add my own foods?**
A: Yes! Use the "Add Food" button and enter all details manually.

**Q: Does it work offline?**
A: Yes! Everything works offline by design.

---

**Happy Tracking! 🎉**

Remember: Consistency is key for achieving your nutrition goals!
