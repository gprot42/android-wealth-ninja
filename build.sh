#!/bin/bash
# Unified Flutter build script for Android (APK), iOS, macOS, or pushing builds.
# Usage: ./build.sh [android|ios|macos|push|--release] [options]
# android: [debug|release] [push] (skips upload by default, add 'push' to enable)
# ios: no additional options
# macos: no additional options
# push: <file_path> [ip_address_or_url] [port]  (manually uploads a specified file, optionally overriding the upload target and TCP port)
# --release: Build release APK and publish to GitHub as a new release
set -euo pipefail

# --- Configuration ---
ACTION=${1:-android}
ARG2=${2:-}
ARG3=${3:-}
ARG4=${4:-}
ARG5=${5:-}
UPLOAD_URL="http://192.168.1.217:8080/"

export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk
export ANDROID_HOME=$ANDROID_SDK_ROOT
export PATH=$PATH:$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/platform-tools

# --- Build Artifact Paths ---
ANDROID_OUTPUT_DIR="build/app/outputs/flutter-apk"
APK_RELEASE="${ANDROID_OUTPUT_DIR}/app-release.apk"
APK_DEBUG="${ANDROID_OUTPUT_DIR}/app-debug.apk"

# --- Functions ---
get_version() {
  # Read version from version.md (source of truth)
  if [ -f "version.md" ]; then
    # Extract the first version number found in ## format (BSD grep compatible)
    local ver=$(grep '^## ' version.md | head -1 | sed 's/^## //' | sed 's/ .*//')
    if [ -n "$ver" ]; then
      echo "$ver"
      return
    fi
  fi
  # Fallback to pubspec.yaml
  grep "version:" pubspec.yaml | head -1 | sed 's/version: //' | sed 's/+.*//' | tr -d ' '
}

get_arch() {
  # Determine architecture from the APK or system
  if [ -f "$APK_PATH" ]; then
    # Check for common arch indicators in the APK
    echo "arm64_v8a"
  else
    echo "arm64"
  fi
}

github_release() {
  local apk_path=$1
  local version
  version=$(get_version)
  local tag="v${version}"
  local release_name="Release ${version}"
  local arch=$(get_arch)
  local apk_name="wealth-ninja-v${version}-${arch}-release.apk"

  if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI (gh) is not installed."
    echo "Install it with: brew install gh"
    exit 1
  fi

  if ! gh auth status &> /dev/null; then
    echo "Error: Not authenticated with GitHub CLI."
    echo "Run: gh auth login"
    exit 1
  fi

  echo "Creating GitHub release ${tag}..."

  if gh release view "$tag" &> /dev/null; then
    echo "Release ${tag} already exists. Uploading APK to existing release..."
    gh release upload "$tag" "$apk_path#${apk_name}" --clobber
  else
    gh release create "$tag" "$apk_path#${apk_name}" \
      --title "$release_name" \
      --notes "Release ${version}" \
      --latest
  fi

  echo "GitHub release published: ${tag}"
  gh release view "$tag" --web || true
}
clean() {
  echo "Running flutter clean..."
  flutter clean
  echo "Running flutter pub get..."
  flutter pub get
  echo "Checking for outdated dependencies..."
  flutter pub outdated
}

push_file() {
    local file_to_upload=$1
    local override_target=${2:-}
    local override_port=${3:-}

    if [[ ! -f "$file_to_upload" ]]; then
        echo "Error: File to upload not found at '$file_to_upload'."
        return 1
    fi

    local filename
    filename=$(basename "$file_to_upload")
    local upload_url="$UPLOAD_URL"

    local base_url="${UPLOAD_URL%/}"
    local default_scheme="http"
    local default_host=""
    local default_port=""

    if [[ "$base_url" == http://* || "$base_url" == https://* ]]; then
        default_scheme="${base_url%%://*}"
        local base_rest="${base_url#*://}"
        local base_host_port="${base_rest%%/*}"
        default_host="${base_host_port%%:*}"
        if [[ "$base_host_port" == *:* ]]; then
            default_port="${base_host_port##*:}"
        fi
    else
        default_host="${base_url%%/*}"
        if [[ "$base_url" == *:* ]]; then
            default_port="${base_url##*:}"
        fi
    fi

    if [[ -z "$default_port" ]]; then
        if [[ "$default_scheme" == "https" ]]; then
            default_port="443"
        else
            default_port="80"
        fi
    fi

    if [[ -n "$override_target" ]]; then
        local target="$override_target"

        if [[ "$target" == http://* || "$target" == https://* ]]; then
            upload_url="${target%/}"
            if [[ -n "$override_port" ]]; then
                if [[ "$upload_url" =~ :[0-9]+$ ]]; then
                    upload_url="${upload_url%:*}:${override_port}"
                else
                    upload_url="${upload_url}:${override_port}"
                fi
            fi
        else
            local host_part="$target"
            local port_to_use="$override_port"

            if [[ "$target" == *:* ]]; then
                host_part="${target%%:*}"
                port_to_use="${target#*:}"
            fi

            if [[ -z "$port_to_use" ]]; then
                port_to_use="8080"
            fi

            upload_url="http://${host_part}:${port_to_use}"
        fi
    elif [[ -n "$override_port" ]]; then
        upload_url="${default_scheme}://${default_host}:${override_port}"
    else
        upload_url="${UPLOAD_URL%/}"
    fi

    if [[ -z "$override_target" && -z "$override_port" && -n "$default_host" ]]; then
        echo "Using default upload target ${default_host}:${default_port}"
    fi

    if [[ "$upload_url" != */ ]]; then
        upload_url="${upload_url}/"
    fi

    echo "Uploading '${filename}' to ${upload_url}..."
    if curl -u admin:password -F "uploadedFile=@${file_to_upload}" "$upload_url"; then
        echo "Upload completed successfully."
    else
        echo "Error: Upload failed."
        return 1
    fi
}


# --- Pre-flight Checks ---
# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "Error: Flutter is not installed. Please install Flutter SDK."
    exit 1
fi

# Validate action
if [[ "$ACTION" != "android" && "$ACTION" != "ios" && "$ACTION" != "macos" && "$ACTION" != "push" && "$ACTION" != "--release" ]]; then
  cat <<EOF
Error: Invalid action '$ACTION'. Use 'android', 'ios', 'macos', 'push', or '--release'.
Usage:
  $0 android [debug|release] [push [ip_address_or_url] [port]] # default: release
  $0 ios
  $0 macos
  $0 push <file_path> [ip_address_or_url] [port]
  $0 --release  # Build release APK and publish to GitHub
EOF
  exit 1
fi

echo "Starting Flutter workflow for '${ACTION}'..."

# Platform-specific checks
case "$ACTION" in
  macos)
    # Check if running on macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
      echo "Error: macOS desktop builds are only supported on macOS."
      exit 1
    fi
    # Check if Xcode is installed
    if ! command -v xcodebuild &> /dev/null; then
        echo "Error: Xcode is not installed. Please install Xcode from the Mac App Store."
        exit 1
    fi
    # Check if macOS desktop support is enabled
    if ! flutter config | grep -q "enable-macos-desktop: true"; then
      echo "Enabling macOS desktop support..."
      flutter config --enable-macos-desktop
    fi
    # Check if macOS project is configured
    if [ ! -d "macos" ]; then
      echo "No macOS desktop project configured. Adding macOS support..."
      flutter create --platforms=macos .
    fi
    ;;
esac


# --- Main Logic ---
case "$ACTION" in
  android)
    # Check if Android SDK is available
    if ! command -v adb &> /dev/null || ! command -v java &> /dev/null; then
      echo "Warning: Android SDK tools not found in PATH. Make sure ANDROID_HOME is set correctly."
      echo "Expected Android SDK location: $ANDROID_SDK_ROOT"
      echo "You may need to install Android Studio or set up the Android SDK manually."
      echo "Continuing with build attempt..."
    fi

    clean
    ANDROID_VARIANT=${ARG2:-release}
    # Handle --release flag
    if [[ "$ANDROID_VARIANT" == "--release" ]]; then
        ANDROID_VARIANT="release"
    fi
    APK_PATH=""
    echo "Building Android APK (variant: ${ANDROID_VARIANT})..."
    case "$ANDROID_VARIANT" in
      debug)
        flutter build apk --debug --verbose
        APK_PATH="$APK_DEBUG"
        ;;
      release)
        flutter build apk --release --verbose
        APK_PATH="$APK_RELEASE"
        ;;
      *)
        echo "Error: Android variant must be 'debug' or 'release'." >&2
        exit 1
        ;;
    esac

    if [[ ! -f "$APK_PATH" ]]; then
      echo "Error: Expected APK not found at '$APK_PATH'." >&2
      exit 1
    fi
    ls -l "$APK_PATH"
    echo "Build successful. APK generated at: $APK_PATH"

    # --- Copy APK to project root with version and arch ---
    VERSION=$(get_version)
    ARCH=$(get_arch)
    ROOT_APK_NAME="wealth-ninja-v${VERSION}-${ARCH}-${ANDROID_VARIANT}.apk"
    echo "Copying ${ANDROID_VARIANT} APK to project root as '$ROOT_APK_NAME'..."
    if cp "$APK_PATH" "$ROOT_APK_NAME"; then
        echo "Successfully copied APK to project root."
    else
        echo "Warning: Failed to copy APK to project root." >&2
    fi

    # --- Copy release build to Downloads ---
    if [[ "$ANDROID_VARIANT" == "release" ]]; then
        DOWNLOADS_DIR="${HOME}/Downloads"
        if [ -d "$DOWNLOADS_DIR" ]; then
            DEST_APK_PATH="${DOWNLOADS_DIR}/wealth-ninja-v${VERSION}-${ARCH}-release.apk"
            echo "Copying release APK to '$DEST_APK_PATH'..."
            if cp "$APK_PATH" "$DEST_APK_PATH"; then
                echo "Successfully copied and renamed APK."
            else
                echo "Warning: Failed to copy APK to Downloads directory." >&2
            fi
        else
            echo "Warning: Downloads directory not found at '$DOWNLOADS_DIR'. Skipping copy." >&2
        fi
    fi
    # --- End copy ---

    if [[ "$ARG3" == "push" ]]; then
        target_endpoint="$ARG4"
        target_port="$ARG5"
        if ! push_file "$APK_PATH" "$target_endpoint" "$target_port"; then
            exit 1
        fi
    else
        echo "Build complete. Skipping push (use 'push' as third argument to enable upload)."
    fi
    ;;

  ios)
    clean
    echo "Building iOS app..."
    if flutter build ios; then
      echo "iOS build completed. Proceed with Xcode for archiving/signing as needed."
    else
      echo "Error: iOS build failed." >&2
      exit 1
    fi
    ;;

  macos)
    clean
    echo "Running macOS desktop target..."
    echo "This will launch 'flutter run -d macos'; press 'q' in the Flutter console to stop."
    echo "Launching lib/main.dart on macOS in debug mode..."
    flutter run -d macos
    ;;

  push)
    FILE_TO_PUSH=${ARG2:-}
    TARGET_ENDPOINT=${ARG3:-}
    TARGET_PORT=${ARG4:-}
    if [[ -z "$FILE_TO_PUSH" ]]; then
        echo "Error: Please specify the file to push." >&2
        echo "Usage: $0 push <file_path> [ip_address_or_url] [port]"
        exit 1
    fi
    if ! push_file "$FILE_TO_PUSH" "$TARGET_ENDPOINT" "$TARGET_PORT"; then
        exit 1
    fi
    ;;

  --release)
    clean
    echo "Building release APK for GitHub..."
    flutter build apk --release --verbose

    if [[ ! -f "$APK_RELEASE" ]]; then
      echo "Error: Release APK not found at '$APK_RELEASE'." >&2
      exit 1
    fi

    ls -l "$APK_RELEASE"
    echo "Build successful. APK generated at: $APK_RELEASE"

    # --- Copy APK to project root with version and arch ---
    VERSION=$(get_version)
    ARCH=$(get_arch)
    ROOT_APK_NAME="wealth-ninja-v${VERSION}-${ARCH}-release.apk"
    echo "Copying release APK to project root as '$ROOT_APK_NAME'..."
    if cp "$APK_RELEASE" "$ROOT_APK_NAME"; then
        echo "Successfully copied APK to project root."
    else
        echo "Warning: Failed to copy APK to project root." >&2
    fi

    echo "Publishing to GitHub..."
    github_release "$APK_RELEASE"
    ;;
esac

echo "Workflow finished for '${ACTION}'."