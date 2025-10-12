#!/bin/bash

RELEASE=1.0

echo "🚀 Starting Flutter build..."
flutter build apk

# Check if the build was successful before renaming
if [ $? -eq 0 ]; then
  echo "✅ Build successful. Renaming APK..."
  # Define variables for version from pubspec.yaml if needed
  # For simplicity, we'll hardcode the name here
  mv build/app/outputs/flutter-apk/app-release.apk build/app/outputs/flutter-apk/wealth-ninja-$RELEASE.apk
  echo "🎉 APK renamed to wealth-ninja-release.apk"
else
  echo "❌ Build failed."
  exit 1
fi

cp build/app/outputs/flutter-apk/wealth-ninja-$RELEASE.apk ~/Downloads
ls -l ~Downloads/wealth-ninja-$RELEASE.apk
