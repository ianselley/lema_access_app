#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEFAULT_SOURCE_ICON="assets/branding/app_icon.png"
SOURCE_ICON_PATH="${1:-$DEFAULT_SOURCE_ICON}"
TARGET_ICON_PATH="$ROOT_DIR/$DEFAULT_SOURCE_ICON"
CONFIG_PATH="$ROOT_DIR/flutter_launcher_icons.yaml"

if [[ $# -gt 1 ]]; then
  echo "Usage: ./script/generate_app_icons.sh [path/to/source-icon.png]" >&2
  exit 1
fi

cd "$ROOT_DIR"

mkdir -p "$(dirname "$TARGET_ICON_PATH")"

if [[ ! -f "$SOURCE_ICON_PATH" ]]; then
  echo "Missing source icon: $SOURCE_ICON_PATH" >&2
  exit 1
fi

if [[ "$SOURCE_ICON_PATH" != "$DEFAULT_SOURCE_ICON" ]]; then
  cp "$SOURCE_ICON_PATH" "$TARGET_ICON_PATH"
  echo "Copied source icon to $DEFAULT_SOURCE_ICON"
fi

echo "Generating Android and iOS launcher icons from $DEFAULT_SOURCE_ICON"
flutter pub get
dart run flutter_launcher_icons -f "$CONFIG_PATH"
