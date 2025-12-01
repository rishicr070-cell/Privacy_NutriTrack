# 🧪 Quick Test Guide - Health Alerts

## Setup (30 seconds)

```bash
# 1. Rebuild app
flutter clean && flutter pub get && flutter run

# 2. Add health condition
App → Profile → Health Conditions → Select "Diabetes" → Save
```

---

## Test 1: Ice Cream Alert (DANGER) 🚨

### Steps:
1. Tap any meal (Breakfast/Lunch/Dinner/Snack)
2. Click "+" or search bar
3. Enter food details:
   ```
   Name: Chocolate Ice Cream
   Serving: 100g
   Calories: 200
   Protein: 4
   Carbs: 65
   Fat: 8
   ```
4. Click **SAVE**

### ✅ Expected Result:
```
⚠️ RED WARNING POPUP appears

Shows 3 alerts:
1. "contains chocolate"
2. "contains ice cream"  
3. "Very High Carbs - 65g"

Buttons: [Cancel] [Add Anyway]
```

### ✅ Test Actions:
- **Click "Cancel"** → Food NOT added ✓
- **Click "Add Anyway"** → Food IS added ✓

---

## Test 2: Rice Alert (WARNING) ⚠️

### Steps:
1. Add new food:
   ```
   Name: White Rice
   Serving: 200g
   Calories: 260
   Protein: 5
   Carbs: 56
   Fat: 0.5
   ```
2. Click **SAVE**

### ✅ Expected Result:
```
ℹ️ ORANGE INFO POPUP appears

Shows:
"High Carbohydrate Warning
 Contains 56g of carbs..."

Button: [Understood]
```

### ✅ Test Actions:
- **Click "Understood"** → Food IS added ✓

---

## Test 3: Healthy Food (NO ALERT) ✅

### Steps:
1. Add new food:
   ```
   Name: Grilled Chicken
   Serving: 100g
   Calories: 165
   Protein: 31
   Carbs: 0
   Fat: 3.6
   ```
2. Click **SAVE**

### ✅ Expected Result:
```
NO POPUP

Food saves immediately ✓
```

---

## Test 4: Multiple Conditions

### Setup:
Add multiple conditions: Diabetes + Hypertension

### Test with Pickles:
```
Name: Mixed Pickle
Serving: 50g
Calories: 20
Protein: 1
Carbs: 3
Fat: 0.5
```

### ✅ Expected:
```
RED WARNING for:
- Contains "pickle" (restricted)
- High sodium warning
```

---

## 🎯 Quick Verification

| Food | Condition | Alert Type | Expected |
|------|-----------|------------|----------|
| Chocolate Ice Cream | Diabetes | 🔴 DANGER | 3 alerts, RED popup |
| White Rice (200g) | Diabetes | 🟠 WARNING | 1 alert, ORANGE popup |
| Grilled Chicken | Diabetes | ✅ NONE | No popup, saves |
| Gulab Jamun | Diabetes | 🔴 DANGER | RED popup |
| Pickles | Hypertension | 🔴 DANGER | RED popup |
| Samosa (fried) | Heart Disease | 🔴 DANGER | RED popup |

---

## 🐛 If It's Not Working:

### 1. No Alert Showing?
```bash
# Check profile has condition
Profile → Health Conditions → Verify "Diabetes" selected

# Rebuild
flutter clean && flutter run
```

### 2. Wrong Alert Type?
```
Check nutritional values:
- Carbs > 60g → DANGER (red)
- Carbs 45-60g → WARNING (orange)
- Contains "ice cream" → DANGER (red)
```

### 3. Can't Cancel?
```
Make sure clicking "Cancel" not "Add Anyway"
Food should NOT appear in meal section
```

---

## ✅ Success Checklist

- [ ] Diabetes condition added in profile
- [ ] Ice cream shows RED danger popup
- [ ] Popup shows 3 specific warnings
- [ ] Cancel button works (doesn't add food)
- [ ] Add Anyway button works (adds food)
- [ ] Rice shows ORANGE warning
- [ ] Chicken has NO warning
- [ ] Alerts are color-coded correctly

---

## 📸 What You Should See

### DANGER Alert (Red):
```
┌──────────────────────────────┐
│ ⚠️ Health Warning           │
│━━━━━━━━━━━━━━━━━━━━━━━━━━━━│
│ This food may not be        │
│ suitable for your health    │
│ conditions:                 │
│                             │
│ ┌─────────────────────────┐│
│ │🩺 Diabetes Alert        ││
│ │ Contains "chocolate"... ││
│ └─────────────────────────┘│
│ ┌─────────────────────────┐│
│ │🩺 DANGER: Very High...  ││
│ │ 65g carbs!              ││
│ └─────────────────────────┘│
│                             │
│ ℹ️ Consult doctor...        │
│                             │
│  [Cancel]   [Add Anyway]    │
└──────────────────────────────┘
```

---

**Time to Test**: 2 minutes
**Status**: ✅ Ready to Test
