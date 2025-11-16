# Troubleshooting Guide

## Issue: Blank Screen on Web Debug

### Solution 1: Clean Build
```bash
# Navigate to project directory
cd C:\Users\rishi\OneDrive\Desktop\Apps\privacy_first_nutrition_tracking_app

# Clean build files
flutter clean

# Get dependencies
flutter pub get

# Run app
flutter run -d chrome
```

### Solution 2: Check Browser Console
1. Press F12 in Chrome to open Developer Tools
2. Go to Console tab
3. Look for any red error messages
4. Check Network tab to see if files are loading

### Solution 3: Clear Browser Data
1. In Chrome, press Ctrl + Shift + Delete
2. Select "Cached images and files"
3. Click "Clear data"
4. Restart Flutter app

### Solution 4: Use Different Port
```bash
flutter run -d chrome --web-port=8080
```

### Solution 5: Check Flutter Doctor
```bash
flutter doctor -v
```
Make sure Chrome is properly detected.

### Solution 6: Enable Verbose Logging
```bash
flutter run -d chrome -v
```
This will show detailed logs of what's happening.

### Solution 7: Build and Serve Manually
```bash
# Build the web app
flutter build web

# Serve using Python (if installed)
cd build/web
python -m http.server 8000

# Or use Flutter's serve command
flutter run -d web-server --web-port=8000
```

Then open http://localhost:8000 in your browser.

## Common Causes

1. **Build files not generated** - Run `flutter clean` and rebuild
2. **Browser cache** - Clear cache or use incognito mode
3. **Port conflict** - Another app might be using the same port
4. **Missing dependencies** - Run `flutter pub get`
5. **Browser compatibility** - Make sure you're using a recent version of Chrome
6. **Firewall/Antivirus** - Check if they're blocking localhost connections

## Check if it works on mobile/desktop
```bash
# Try Android emulator
flutter run -d emulator-5554

# Try Windows desktop
flutter run -d windows
```

If it works on other platforms but not web, it's specifically a web configuration issue.
