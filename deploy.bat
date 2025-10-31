@echo off
REM SimplyStyles Firebase Deployment Script for Windows
REM This script builds and deploys your Flutter web app to Firebase Hosting

echo.
echo ================================
echo SimplyStyles Deployment Script
echo ================================
echo.

REM Check if Flutter is installed
where flutter >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Flutter is not installed. Please install Flutter first:
    echo https://docs.flutter.dev/get-started/install
    exit /b 1
)

REM Check if Firebase CLI is installed
where firebase >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Firebase CLI is not installed. Installing now...
    call npm install -g firebase-tools
)

echo Prerequisites check passed!
echo.

REM Step 1: Enable web support
echo Step 1: Enabling Flutter web support...
call flutter config --enable-web

REM Step 2: Get dependencies
echo Step 2: Getting Flutter dependencies...
call flutter pub get

REM Step 3: Build the web app
echo Step 3: Building Flutter web app...
call flutter build web --release

if %ERRORLEVEL% NEQ 0 (
    echo Build failed. Please check the errors above.
    exit /b 1
)

echo Build completed successfully!
echo.

REM Step 4: Deploy to Firebase
echo Step 4: Deploying to Firebase Hosting...
call firebase deploy --only hosting

if %ERRORLEVEL% NEQ 0 (
    echo Deployment failed. Please check the errors above.
    exit /b 1
)

echo.
echo ================================
echo Deployment successful!
echo Your app is now live at: https://simplysoph-66c78.web.app
echo ================================
echo.
pause
