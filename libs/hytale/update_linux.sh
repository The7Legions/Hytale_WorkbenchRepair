#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMP_DIR="$(mktemp -d)"
EXTRACT_DIR="$TEMP_DIR/unpacked"
ZIP_PATH="$TEMP_DIR/game.zip"
DOWNLOADER_TMP="$(mktemp -d)"
DOWNLOADER="$SCRIPT_DIR/hytale-downloader-linux-amd64"
SERVER_OUTPUT_ROOT="$SCRIPT_DIR/nix-server"
VERSION_FILE="$SERVER_OUTPUT_ROOT/last_version.txt"

cleanup() {
	rm -rf "$TEMP_DIR" "$DOWNLOADER_TMP"
}
trap cleanup EXIT ERR SIGINT SIGTERM

mkdir -p "$SERVER_OUTPUT_ROOT"

if [[ ! -x "$DOWNLOADER" ]]; then
    echo "Updater not found, fetching latest..."
    curl -fsSL https://downloader.hytale.com/hytale-downloader.zip -o "$DOWNLOADER_TMP/dl.zip"
    ./7zip/7zz e "$DOWNLOADER_TMP/dl.zip" -o"$DOWNLOADER_TMP"
    cp "$(find "$DOWNLOADER_TMP" -name 'hytale-downloader-*-amd64' -type f | head -n1)" "$DOWNLOADER"
    chmod +x "$DOWNLOADER"
fi

CHECK_UPDATE_OUTPUT="$("$DOWNLOADER" -check-update 2>&1 | tee /dev/stderr)"

PATTERN="([0-9]+\.[0-9]+\.[0-9]+\-[0-9a-zA-Z]+)"
if [[ "$CHECK_UPDATE_OUTPUT" =~ $PATTERN ]] \
	&& [[ -f "$SERVER_OUTPUT_ROOT/HytaleServer.jar" ]] \
	&& [[ -f "$SERVER_OUTPUT_ROOT/Assets.zip" ]]; then
	REMOTE_VERSION="${BASH_REMATCH[1]}"
	OLD_VERSION="$(cat "$VERSION_FILE" 2>/dev/null || true)"
	[[ -n "$REMOTE_VERSION" && -f "$VERSION_FILE" ]] && {
		echo "Up to date ($REMOTE_VERSION) already. Exiting."
		exit 0
	}
fi

echo "Downloading..."

PATTERN="successfully downloaded.*\(version ([0-9]+\.[0-9]+\.[0-9]+\-[0-9a-zA-Z]+)\)"
set -o pipefail
DOWNLOAD_OUTPUT="$("$DOWNLOADER" -download-path "$ZIP_PATH" 2>&1 | tee /dev/stderr)"
set +o pipefail
echo "Download output: || $DOWNLOAD_OUTPUT ||"
if [[ "$DOWNLOAD_OUTPUT" =~ $PATTERN ]]; then
	echo "Pattern match: ${BASH_REMATCH[1]}"
	echo "${BASH_REMATCH[1]}" > "$VERSION_FILE"
fi

echo "Extracting..."
../7zip/7zz e "$ZIP_PATH" -o"$EXTRACT_DIR"

echo "Updating..."

[[ -f "$EXTRACT_DIR/Assets.zip" ]] && \
    cp "$EXTRACT_DIR/Assets.zip" "$SERVER_OUTPUT_ROOT/Assets.zip"
[[ -f "$EXTRACT_DIR/HytaleServer.jar" ]] && \
    cp "$EXTRACT_DIR/HytaleServer.jar" "$SERVER_OUTPUT_ROOT/HytaleServer.jar"

echo "Update Complete."