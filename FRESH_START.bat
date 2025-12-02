@echo off
cls
echo ==========================================
echo   FRESH START - Complete Setup
echo ==========================================
echo.

echo [1/8] Checking Java version...
java -version
echo.

echo [2/8] Cleaning Flutter completely...
call flutter clean
echo.

echo [3/8] Removing ALL build directories...
if exist .dart_tool rmdir /s /q .dart_tool 2>nul
if exist build rmdir /s /q build 2>nul
if exist android\.gradle rmdir /s /q android\.gradle 2>nul
if exist android\app\build rmdir /s /q android\app\build 2>nul
if exist android\build rmdir /s /q android\build 2>nul
if exist .flutter-plugins rmdir /s /q .flutter-plugins 2>nul
if exist .flutter-plugins-dependencies rmdir /s /q .flutter-plugins-dependencies 2>nul
echo Done!
echo.

echo [4/8] Removing cached tflite packages...
rmdir /s /q "%LOCALAPPDATA%\Pub\Cache\hosted\pub.dev\tflite_flutter-0.10.4" 2>nul
rmdir /s /q "%LOCALAPPDATA%\Pub\Cache\hosted\pub.dev\tflite_flutter-0.10.3" 2>nul
rmdir /s /q "%LOCALAPPDATA%\Pub\Cache\hosted\pub.dev\tflite_flutter-0.10.2" 2>nul
echo Done!
echo.

echo [5/8] Getting Flutter packages...
call flutter pub get
echo.

echo [6/8] Running Flutter doctor...
call flutter doctor -v
echo.

echo [7/8] Testing Gradle configuration...
cd android
call gradlew.bat tasks --no-daemon
cd ..
echo.

echo [8/8] Ready to build!
echo.
echo ==========================================
echo   Setup Complete!
echo ==========================================
echo.
echo Next steps:
echo 1. Connect your device
echo 2. Run: flutter run
echo.

pause
