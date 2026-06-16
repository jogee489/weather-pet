#!/bin/bash
# Installs the Flutter SDK so `flutter analyze` / `flutter test` work in
# Claude Code on the web sessions. Idempotent and non-interactive.
set -euo pipefail

# Web (remote) sessions only — local machines already have Flutter.
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

FLUTTER_VERSION="3.44.2"
FLUTTER_DIR="$HOME/flutter"
ARCHIVE="flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/${ARCHIVE}"

# Install the SDK only if this exact version isn't already present (the
# container caches state after the hook, so re-runs are cheap no-ops).
if [ ! -x "$FLUTTER_DIR/bin/flutter" ] || \
   ! "$FLUTTER_DIR/bin/flutter" --version 2>/dev/null | grep -q "$FLUTTER_VERSION"; then
  rm -rf "$FLUTTER_DIR"
  echo "Downloading Flutter ${FLUTTER_VERSION}..." >&2
  curl -fsSL --retry 3 -o "/tmp/${ARCHIVE}" "$URL"
  tar -xf "/tmp/${ARCHIVE}" -C "$HOME"
  rm -f "/tmp/${ARCHIVE}"
fi

# Git 'dubious ownership' guard — the SDK dir may be owned differently.
git config --global --add safe.directory "$FLUTTER_DIR" || true

export PATH="$FLUTTER_DIR/bin:$PATH"

# Persist Flutter on PATH for the rest of the session.
if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  echo "export PATH=\"$FLUTTER_DIR/bin:\$PATH\"" >> "$CLAUDE_ENV_FILE"
fi

# Warm the build cache and fetch package deps so the first analyze/test is fast.
flutter --version >&2
flutter pub get >&2

echo "Flutter ${FLUTTER_VERSION} ready." >&2
