@echo off
echo ========================================
echo  SimplyStyles - Upload Fix Deployment
echo ========================================
echo.

echo [1/4] Running tests...
call flutter test test/upload_validation_test.dart
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: Tests failed! Fix tests before deploying.
    pause
    exit /b 1
)

echo.
echo [2/4] Building web app...
call flutter build web
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: Build failed!
    pause
    exit /b 1
)

echo.
echo [3/4] Deploying to Firebase...
call firebase deploy --only hosting
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: Deployment failed!
    pause
    exit /b 1
)

echo.
echo [4/4] Deployment complete!
echo.
echo ========================================
echo  DEPLOYMENT SUCCESSFUL
echo ========================================
echo.
echo Live URL: https://simplysoph-66c78.web.app
echo.
echo Next steps:
echo 1. Test upload functionality on live site
echo 2. Monitor Firebase Console for errors
echo 3. Notify investment team
echo.
pause
