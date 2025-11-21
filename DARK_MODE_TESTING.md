# Dark Mode Testing Guide

## Quick Test Steps

### 1. Test Dark Mode Toggle
1. Run the app: `flutter run`
2. Navigate to the **Profile** tab (bottom navigation)
3. Scroll down to the **Settings** section
4. Toggle the **Dark Mode** switch ON
5. ✅ **Expected**: App immediately switches to dark theme
6. Toggle the **Dark Mode** switch OFF
7. ✅ **Expected**: App immediately switches to light theme

### 2. Test Theme Persistence
1. Enable dark mode
2. Close the app completely (not just minimize)
3. Reopen the app
4. ✅ **Expected**: App opens in dark mode

### 3. Test All Screens in Dark Mode
Enable dark mode, then check each screen:

#### Home Screen
- ✅ Background color: dark
- ✅ Cards: dark surface color
- ✅ Text: light/white color
- ✅ Gradient headers: visible and vibrant
- ✅ Charts and progress bars: properly colored

#### Search Screen
- ✅ Search bar: dark theme
- ✅ Food items list: dark cards
- ✅ Text: readable on dark background

#### Analytics Screen
- ✅ Charts: properly themed
- ✅ Background: dark
- ✅ Text labels: light colored

#### Profile Screen
- ✅ Cards and stats: dark themed
- ✅ Weight chart: dark background
- ✅ Goals section: properly colored
- ✅ Dark mode toggle: shows correct state

### 4. Test System UI Updates
When dark mode is enabled:
- ✅ Status bar: light icons on dark background
- ✅ Navigation bar: dark color
- ✅ Smooth transition (no flashing)

### 5. Test Edge Cases
1. Toggle dark mode multiple times rapidly
   - ✅ No crashes or errors
   - ✅ Theme updates correctly each time

2. Toggle dark mode while on different screens
   - ✅ All screens update immediately
   - ✅ Navigation bar theme updates

3. Test with empty data (new user)
   - ✅ Empty states properly themed
   - ✅ Dark mode toggle still works

## Visual Verification Checklist

### Light Theme
- [ ] Background: Light gray (#F8F9FA)
- [ ] Cards: White
- [ ] Text: Dark gray (#2D3142)
- [ ] Primary color: Cyan (#00C9FF)
- [ ] Secondary color: Mint green (#92FE9D)

### Dark Theme
- [ ] Background: Deep blue-black (#1A1A2E)
- [ ] Cards: Lighter blue-black (#16213E)
- [ ] Text: White/light gray
- [ ] Primary color: Cyan (#00C9FF)
- [ ] Secondary color: Mint green (#92FE9D)

## Common Issues to Check

### ✅ Fixed Issues
- Dark mode toggle now works immediately
- Theme preference is properly saved
- All screens adapt to dark theme
- System UI colors update correctly

### If Issues Occur
1. **Theme doesn't change**: Check console for errors
2. **Theme doesn't persist**: Verify `shared_preferences` is working
3. **Some widgets not themed**: Ensure they use `Theme.of(context)`

## Code Verification

### Verify main.dart has:
```dart
// Global key
final GlobalKey<_MyAppState> appKey = GlobalKey<_MyAppState>();

// In _MyAppState
void setTheme(bool isDark) {
  if (_isDarkMode != isDark) {
    _toggleTheme();
  }
}
```

### Verify profile_screen.dart has:
```dart
import '../main.dart';

Future<void> _toggleDarkMode(bool value) async {
  setState(() => _isDarkMode = value);
  await StorageHelper.setDarkMode(value);
  
  if (mounted && appKey.currentState != null) {
    appKey.currentState!.setTheme(value);
  }
}
```

## Performance Check
- [ ] Theme switch is instant (no lag)
- [ ] No memory leaks when toggling
- [ ] Smooth animations maintained
- [ ] No frame drops during switch

## Accessibility Check
- [ ] Text contrast is sufficient in both themes
- [ ] Interactive elements are clearly visible
- [ ] Icons are properly colored
- [ ] Disabled states are distinguishable

---

## Success Criteria
All checkboxes above should be marked ✅ for the dark mode feature to be considered fully functional.

**Last Updated**: November 21, 2025
