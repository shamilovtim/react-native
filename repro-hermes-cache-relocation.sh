#!/usr/bin/env bash
# Run from the repository root after yarn install, with JAVA_HOME and ANDROID_HOME set.
set -euo pipefail

task=':packages:react-native:ReactAndroid:hermes-engine:configureBuildForHermes'
gradle_args=(-Preact.internal.useHermesNightly=false -PreactNativeArchitectures=arm64-v8a --console=plain)

# Configure once at the original source location.
env -u REACT_NATIVE_OVERRIDE_HERMES_DIR ./gradlew "$task" "${gradle_args[@]}"

# Keep the build directory, but give the same sources a different absolute path.
moved_source="$(mktemp -d "${TMPDIR:-/tmp}/hermes-source-XXXXXX")"
cp -R packages/react-native/sdks/hermes/. "$moved_source/"
printf 'Moved Hermes sources to %s\n' "$moved_source"
REACT_NATIVE_OVERRIDE_HERMES_DIR="$moved_source" ./gradlew "$task" "${gradle_args[@]}"

# The fixed task should skip configuration when nothing else changes.
REACT_NATIVE_OVERRIDE_HERMES_DIR="$moved_source" ./gradlew "$task" "${gradle_args[@]}"
