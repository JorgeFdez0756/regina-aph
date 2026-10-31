#!/usr/bin/env bash
# Ejecutar únicamente en Codex Cloud o GitHub Actions, desde cualquier directorio.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze --fatal-infos
flutter test --coverage
