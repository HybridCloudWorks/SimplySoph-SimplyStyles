@echo off
REM CI/CD Setup Script for Windows
REM This script helps set up Firebase service account for GitHub Actions

echo ========================================
echo SimplyStyles CI/CD Setup
echo ========================================
echo.

set PROJECT_ID=simplysoph-66c78
set SA_NAME=github-actions-deploy

echo Step 1: Checking gcloud installation...
where gcloud >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: gcloud CLI not found!
    echo Please install from: https://cloud.google.com/sdk/docs/install
    pause
    exit /b 1
)
echo ✓ gcloud found
echo.

echo Step 2: Authenticating with Google Cloud...
gcloud auth login
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Authentication failed
    pause
    exit /b 1
)
echo ✓ Authenticated
echo.

echo Step 3: Setting project to %PROJECT_ID%...
gcloud config set project %PROJECT_ID%
echo ✓ Project set
echo.

echo Step 4: Creating service account...
gcloud iam service-accounts create %SA_NAME% --display-name="GitHub Actions Deploy" --project=%PROJECT_ID%
if %ERRORLEVEL% NEQ 0 (
    echo WARNING: Service account may already exist
)
echo ✓ Service account ready
echo.

echo Step 5: Granting Firebase Hosting Admin role...
gcloud projects add-iam-policy-binding %PROJECT_ID% --member="serviceAccount:%SA_NAME%@%PROJECT_ID%.iam.gserviceaccount.com" --role="roles/firebasehosting.admin"
echo ✓ Role granted
echo.

echo Step 6: Creating service account key...
gcloud iam service-accounts keys create github-actions-key.json --iam-account=%SA_NAME%@%PROJECT_ID%.iam.gserviceaccount.com --project=%PROJECT_ID%
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to create key
    pause
    exit /b 1
)
echo ✓ Key created: github-actions-key.json
echo.

echo ========================================
echo SUCCESS! Setup complete
echo ========================================
echo.
echo Next steps:
echo 1. Open: github-actions-key.json
echo 2. Copy the entire contents
echo 3. Go to: GitHub repo → Settings → Secrets → Actions
echo 4. Create new secret named: FIREBASE_SERVICE_ACCOUNT
echo 5. Paste the JSON contents
echo.
echo Opening the key file...
start notepad github-actions-key.json
echo.
echo Press any key to open GitHub secrets page...
pause >nul
start https://github.com/YOUR_USERNAME/SimplySoph-SimplyStyles/settings/secrets/actions
echo.
echo Done!
pause
