#!/bin/bash

# WARNING: Firebase project simplysoph-66c78 is shared with the live SimplySoph
# website. Its default Hosting site belongs to that website, so this script would
# overwrite it. Do not run it until SimplyStyles has its own Hosting site.

# SimplyStyles Firebase Deployment Script
# This script builds and deploys your Flutter web app to Firebase Hosting

echo "🚀 SimplyStyles Deployment Script"
echo "=================================="
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null
then
    echo "❌ Flutter is not installed. Please install Flutter first:"
    echo "   https://docs.flutter.dev/get-started/install"
    exit 1
fi

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null
then
    echo "❌ Firebase CLI is not installed. Installing now..."
    npm install -g firebase-tools
fi

echo "✅ Prerequisites check passed!"
echo ""

# Step 1: Enable web support
echo "📱 Step 1: Enabling Flutter web support..."
flutter config --enable-web

# Step 2: Get dependencies
echo "📦 Step 2: Getting Flutter dependencies..."
flutter pub get

# Step 3: Build the web app
echo "🔨 Step 3: Building Flutter web app..."
flutter build web --release

if [ $? -ne 0 ]; then
    echo "❌ Build failed. Please check the errors above."
    exit 1
fi

echo "✅ Build completed successfully!"
echo ""

# Step 4: Deploy to Firebase
echo "🚀 Step 4: Deploying to Firebase Hosting..."
firebase deploy --only hosting

if [ $? -ne 0 ]; then
    echo "❌ Deployment failed. Please check the errors above."
    exit 1
fi

echo ""
echo "🎉 Deployment successful!"
echo "Your app is now live at: https://simplysoph-66c78.web.app"
echo ""
