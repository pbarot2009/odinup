#!/usr/bin/env bash
set -e

# ANSI Color Codes
RESET="\033[0m"
BOLD="\033[1m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
CYAN="\033[36m"
DIM="\033[90m"

echo -e "${BOLD}${CYAN}🚀 OdinUP Installer${RESET}"
echo -e "${DIM}The Native Odin Version Manager${RESET}\n"

# 1. System Profiling
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

if [ "$ARCH" = "x86_64" ]; then ARCH="amd64"; fi
if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then ARCH="arm64"; fi  # Fix 1: missing space before [ 

TARGET="odinup-${OS}-${ARCH}.tar.gz"
echo -e "🔎 Detected System: ${CYAN}${OS}-${ARCH}${RESET}"

# 2. Interrogate GitHub API
echo -e "🌐 Querying GitHub for latest release..."
REPO_API="https://api.github.com/repos/pbarot2009/odinup/releases/latest"
API_RESPONSE=$(curl -s "$REPO_API")

LATEST_TAG=$(echo "$API_RESPONSE" | grep -m 1 '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
DOWNLOAD_URL=$(echo "$API_RESPONSE" | grep -m 1 "browser_download_url.*$TARGET" | sed -E 's/.*"([^"]+)".*/\1/')

if [ -z "$LATEST_TAG" ] || [ -z "$DOWNLOAD_URL" ]; then
    echo -e "${RED}✖ Error: Could not find a release asset for $TARGET.${RESET}"
    exit 1
fi

# 3. State Check & Version Comparison
ODINUP_HOME="${ODINUP_HOME:-$HOME/.odinup}"
BIN_DIR="$ODINUP_HOME/bin"
VERSION_FILE="$ODINUP_HOME/.version"
UPDATING=false

if [ -f "$BIN_DIR/odinup" ]; then  # Fix 2: was if[ (missing space)
    LOCAL_VERSION="unknown"
    if [ -f "$VERSION_FILE" ]; then  # Fix 3: was if[ (missing space)
        LOCAL_VERSION=$(cat "$VERSION_FILE")
    fi

    if [ "$LOCAL_VERSION" = "$LATEST_TAG" ]; then
        echo -e "\n${GREEN}✔ You already have the latest version of OdinUP ($LATEST_TAG).${RESET}"
        echo -e "Aborting installation."
        exit 0
    else
        echo -e "\n${YELLOW}✨ A new version of OdinUP is available!${RESET}"
        echo -e "Current: ${RED}$LOCAL_VERSION${RESET} -> Latest: ${GREEN}$LATEST_TAG${RESET}"

        read -p "Do you want to update now? [y/N]: " choice
        case "$choice" in
            y|Y ) echo -e "\n${CYAN}Proceeding with update...${RESET}"; UPDATING=true;;
            * ) echo -e "Update aborted."; exit 0;;
        esac
    fi
else
    echo -e "Target Version: ${GREEN}$LATEST_TAG${RESET}"
fi

# 4. Download & Extraction
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

echo -e "📦 Downloading ${TARGET}..."
curl -L --progress-bar "$DOWNLOAD_URL" -o "odinup.tar.gz"

echo -e "📂 Extracting archive..."
tar -xzf odinup.tar.gz

# 5. Binary Placement & State Update
mkdir -p "$BIN_DIR"
mv odinup "$BIN_DIR/"
chmod +x "$BIN_DIR/odinup"
echo "$LATEST_TAG" > "$VERSION_FILE"

# 6. Persistent PATH Injection (Skipped if updating)
if [ "$UPDATING" = false ]; then
    PROFILE_FILES=("$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.bash_profile" "$HOME/.profile")
    ADDED_PATH=false

    for profile in "${PROFILE_FILES[@]}"; do
        if [ -f "$profile" ]; then  # Fix 4: was if[ (missing space)
            if ! grep -q "$BIN_DIR" "$profile"; then
                echo "" >> "$profile"
                echo "# OdinUP Environment" >> "$profile"
                echo "export PATH=\"$BIN_DIR:\$PATH\"" >> "$profile"
                echo -e "${GREEN}✔ Permanently added OdinUP to $profile${RESET}"
                ADDED_PATH=true
            else
                echo -e "${GREEN}✔ OdinUP is already configured in $profile${RESET}"
                ADDED_PATH=true
            fi
        fi
    done

    if [ "$ADDED_PATH" = false ]; then
        echo -e "${YELLOW}⚠ Could not automatically configure shell. Add this to your profile:${RESET}"
        echo -e "export PATH=\"$BIN_DIR:\$PATH\""
    fi
fi

# 7. Cleanup
cd "$HOME"
rm -rf "$TMP_DIR"

echo -e "\n${BOLD}${GREEN}✨ OdinUP $LATEST_TAG successfully installed!${RESET}"
if [ "$UPDATING" = false ]; then  # Fix 5: was if[ (missing space)
    echo -e "Restart your terminal, or run: ${CYAN}source ~/.bashrc${RESET}"
fi
echo -e "Type ${CYAN}odinup help${RESET} to get started."