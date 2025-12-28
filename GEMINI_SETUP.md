# Gemini AI Setup Instructions

## Overview
This app uses Google's Gemini AI (gemini-1.5-flash model) to provide personalized nutrition insights automatically. The API key is stored securely in a `.env` file that never gets committed to version control.

## Quick Setup (3 Steps)

### Step 1: Get Your Gemini API Key
1. Visit [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Sign in with your Google account
3. Click **"Create API Key"**
4. Copy the generated API key

### Step 2: Add Your API Key
1. Open the `.env` file in the project root directory
2. Replace `YOUR_GEMINI_API_KEY_HERE` with your actual API key:
   ```
   GEMINI_API_KEY=AIzaSyD...your_actual_key_here
   ```
3. Save the file

### Step 3: Run the App
```bash
flutter pub get
flutter run
```

## Features Enabled by Gemini AI

### 🎯 Automatic Nutrition Insights
- **Home Screen**: Get daily insights based on your food intake
- Analyzes your progress towards goals
- Suggests improvements based on your health conditions
- Updates automatically as you log meals

### 🍽️ Smart Food Analysis
- **When adding food**: Real-time feedback on your food choices
- Checks if food aligns with your goals
- Suggests healthier alternatives when needed
- Considers your health conditions

### 💡 Personalized Suggestions
- **Throughout the day**: Tips on what to eat next
- Helps balance your macros
- Prevents overeating or undereating
- Adapts to your specific goals

### 🏥 Health Condition Guidance
- Custom advice for diabetes, hypertension, etc.
- Indian food recommendations
- Practical dietary tips

## Model Information

**Current Model**: `gemini-1.5-flash`
- Fast responses
- Excellent for nutrition analysis
- Cost-effective for daily use
- High quality insights

## How It Works

The app automatically:
1. **Loads your API key** from the `.env` file on startup
2. **Analyzes your nutrition data** in the background
3. **Generates insights** without any manual input
4. **Updates recommendations** as you log meals

You never need to enter the API key in the app - it's all handled automatically!

## Security

✅ **Your API key is secure:**
- Stored in `.env` file (never committed to git)
- Only accessible on your device
- Not shared with any third party
- Protected by `.gitignore`

✅ **Your data is private:**
- All nutrition data stays on your device
- Only anonymized summaries sent to Gemini
- No personal information shared

## Troubleshooting

### "AI insights unavailable" message?
**Solution**: Check that your `.env` file has a valid API key

### Model not found error?
**Solution**: The app now uses `gemini-1.5-flash` which is the latest available model. Make sure you have the latest version of the code.

### API key not working?
**Solutions**:
1. Make sure there are no extra spaces in the `.env` file
2. Verify the key is correct at [Google AI Studio](https://aistudio.google.com/app/apikey)
3. Check you're not exceeding the free tier limits

### Can't find .env file?
**Solution**: Copy `.env.example` to `.env` and add your key

## API Limits (Free Tier)

Google Gemini Free Tier (gemini-1.5-flash):
- ✅ 15 requests per minute
- ✅ 1,500 requests per day
- ✅ 1 million tokens per month
- ✅ Perfect for personal use!

The app is optimized to stay well within these limits.

## Console Output

When working correctly, you'll see:
```
✅ Environment variables loaded
✅ Gemini AI service initialized successfully
```

If there's an issue:
```
⚠️ Gemini API key not configured. Please add it to .env file.
Get your key from: https://aistudio.google.com/app/apikey
```

## Need Help?

1. Check the console logs for detailed error messages
2. Verify your API key at Google AI Studio
3. Ensure `.env` file is in the project root (same folder as pubspec.yaml)
4. Run `flutter pub get` after any changes
5. Restart the app completely after adding/updating API key

---

**Get your free API key**: https://aistudio.google.com/app/apikey

**Note**: The model name has been updated from `gemini-pro` to `gemini-1.5-flash` for better compatibility with the current API version.
