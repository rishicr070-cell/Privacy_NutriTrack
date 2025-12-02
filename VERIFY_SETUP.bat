@echo off
cls
echo ==========================================
echo   CONFIGURATION VERIFICATION
echo ==========================================
echo.

set ERRORS=0

REM Check 1: Java
echo [CHECK 1/6] Java Installation
java -version 2>&1 | findstr "version"
if %errorlevel% neq 0 (
    echo [X] FAILED - Java not found
    set /a ERRORS+=1
) else (
    echo [✓] PASSED
)
echo.

REM Check 2: Flutter
echo [CHECK 2/6] Flutter Installation
flutter --version 2>&1 | findstr "Flutter"
if %errorlevel% neq 0 (
    echo [X] FAILED - Flutter not found
    set /a ERRORS+=1
) else (
    echo [✓] PASSED
)
echo.

REM Check 3: Gradle wrapper
echo [CHECK 3/6] Gradle Wrapper
if exist android\gradlew.bat (
    echo [✓] PASSED - gradlew.bat exists
) else (
    echo [X] FAILED - gradlew.bat missing
    set /a ERRORS+=1
)
echo.

REM Check 4: pubspec.yaml
echo [CHECK 4/6] Package Configuration
findstr "tflite_flutter: \^0.9.0" pubspec.yaml >nul
if %errorlevel% equ 0 (
    echo [✓] PASSED - tflite_flutter 0.9.0
) else (
    echo [X] WARNING - tflite_flutter version might be wrong
)
echo.

REM Check 5: Assets
echo [CHECK 5/6] Asset Files
if exist assets\models\Fooddetector.tflite (
    echo [✓] PASSED - ML model exists
) else (
    echo [!] WARNING - Fooddetector.tflite missing
)
echo.

REM Check 6: Device
echo [CHECK 6/6] Connected Devices
call flutter devices
echo.

echo ==========================================
if %ERRORS% equ 0 (
    echo   ALL CHECKS PASSED!
    echo   Ready to run: flutter run
) else (
    echo   FOUND %ERRORS% ERRORS
    echo   Fix errors above before building
)
echo ==========================================
echo.

pause
