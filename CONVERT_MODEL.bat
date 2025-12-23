@echo off
cls
echo ==========================================
echo  YOLOV8 MODEL CONVERSION GUIDE
echo ==========================================
echo.
echo Step 1: Clone the repository
echo ----------------------------------------
echo Run this command:
echo   git clone https://github.com/johnw1llliam/Indian_Food_Classification.git
echo.
pause
echo.
echo Step 2: Install Python dependencies
echo ----------------------------------------
echo Run these commands:
echo   pip install ultralytics
echo   pip install tensorflow
echo.
pause
echo.
echo Step 3: Download the model
echo ----------------------------------------
echo - Go to the cloned repo folder
echo - Find the model file (best.pt or similar)
echo - Note the model's class names
echo.
pause
echo.
echo Step 4: Convert the model
echo ----------------------------------------
echo - Copy convert_model.py to the repo folder
echo - Run: python convert_model.py
echo - This will create a .tflite file
echo.
pause
echo.
echo Step 5: Copy to Flutter project
echo ----------------------------------------
echo Copy the generated .tflite file to:
echo   %CD%\assets\models\Fooddetector.tflite
echo.
echo Replace the existing file!
echo.
pause
echo.
echo Step 6: Update class labels
echo ----------------------------------------
echo Edit: lib\services\food_detector_service.dart
echo Update the labels list to match the new model
echo.
pause
echo.
echo Step 7: Clean and rebuild
echo ----------------------------------------
echo Run:
echo   flutter clean
echo   flutter pub get
echo   flutter run
echo.
echo ==========================================
echo  DONE! Follow these steps carefully
echo ==========================================
pause
