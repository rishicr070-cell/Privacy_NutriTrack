@echo off
cls
echo ==========================================
echo   Fixing tflite_flutter + Rebuilding
echo ==========================================
echo.

echo [1/4] Cleaning...
call flutter clean
echo.

echo [2/4] Removing pub cache for tflite...
rmdir /s /q "%LOCALAPPDATA%\Pub\Cache\hosted\pub.dev\tflite_flutter-0.10.4" 2>nul
echo.

echo [3/4] Getting packages (will download tflite 0.9.0)...
call flutter pub get
echo.

echo [4/4] Building...
call flutter run

if %errorlevel% neq 0 (
    echo.
    echo ==========================================
    echo   If build fails, try:
    echo   flutter run --verbose
    echo ==========================================
)

pause
