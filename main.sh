#!/bin/bash

# Detect windows
is_windows() {
    [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" || "$OSTYPE" == "cygwin" ]]
}

# Config
PATRIMOINE_BASE_DIR="$HOME/.patrimoine"
REALISES_DIR="$PATRIMOINE_BASE_DIR/download/realises"

if [ ! -d "$REALISES_DIR" ] || [ -z "$(ls -A "$REALISES_DIR" 2>/dev/null)" ]; then
    echo "ERROR: Patrimoine not initialized"
    echo ""
    echo "Please run init.sh first"
    echo ""
    exit 1
fi

LAST_VERSION="0.3.0" # put here the latest version number
LINK='https://www.dropbox.com/scl/fi/tq91xi8ebfdcjy7c6likm/patrimoine-0.3.1.jar?rlkey=notdyc96ebi364zdbdyxdw90x&st=i8z4nxec&dl=1'
JAR_NAME="patrimoine@${LAST_VERSION}.jar"
USER_DIR="$HOME"

cd "$USER_DIR" || { echo "Unable to access the file $USER_DIR"; exit 1; }

echo "Checking for the patrimoine.jar file in $USER_DIR..."

# Find existing jar files matching the pattern
EXISTING_JAR=$(ls patrimoine@*.jar 2>/dev/null | head -n 1)

if [ -n "$EXISTING_JAR" ]; then
    CURRENT_VERSION=$(echo "$EXISTING_JAR" | cut -d "@" -f 2 | cut -d "." -f 1-3)
    if [ "$CURRENT_VERSION" = "$LAST_VERSION" ]; then
        echo "You already have the latest version : $EXISTING_JAR"
    else
        echo "Old version detected : $CURRENT_VERSION."
        read -p "Update to version $LAST_VERSION? (y/N) : " -r
        if [[ $REPLY =~ ^[OoYy]$ ]]; then
            echo "Updating..."
            rm -f "$EXISTING_JAR"
            if is_windows; then
                curl --ssl-no-revoke -L -o "$JAR_NAME" "$LINK"
            else
                curl -L -o "$JAR_NAME" "$LINK"
            fi
        else
            echo "Update skipped. Using existing version $CURRENT_VERSION."
            JAR_NAME="$EXISTING_JAR"
        fi
    fi
else
    echo "No version detected."
    read -p "Download version $LAST_VERSION? (y/N) : " -r
    if [[ $REPLY =~ ^[OoYy]$ ]]; then
        echo "Downloading..."
        if is_windows; then
            curl --ssl-no-revoke -L -o "$JAR_NAME" "$LINK"
        else
            curl -L -o "$JAR_NAME" "$LINK"
        fi
    else
        echo "Download canceled. Cannot launch Patrimoine."
        exit 0
    fi
fi

if [ -f "$JAR_NAME" ]; then
    echo "Launching $JAR_NAME..."
    java -Dpatrimoine.mode=OFFLINE -jar "$JAR_NAME"
else
    echo "ERROR: JAR file not found. Launch aborted."
fi
