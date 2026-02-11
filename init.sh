#!/bin/bash

# Placeholders
MOI=$1
SEX=$2
PETIT_COPAIN_OU_PETITE_COPINE=$([[ "$SEX" == "M" ]] && echo "PetiteCopine" || echo "PetitCopain")

# Detect windows
is_windows() {
    [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" || "$OSTYPE" == "cygwin" ]]
}

# Paths
PATRIMOINE_DIR="$HOME/.patrimoine"
JAR_PATTERN="$HOME/patrimoine@*.jar"

# Security check
if [ -z "$HOME" ]; then
    echo "Error : HOME variable not defined"
    exit 1
fi

echo "This script will remove and recreate:"
echo "$PATRIMOINE_DIR"

# Verify existing JARs
JAR_FILES=$(ls $JAR_PATTERN 2>/dev/null)
if [ -n "$JAR_FILES" ]; then
    echo ""
    echo "JAR file(s) detected :"
    for jar in $JAR_FILES; do
        echo " $jar"
    done
    echo ""
    read -p "Do you want to delete the JAR file(s)? ? (o/N) : " -n 1 -r
    echo ""
    DELETE_JAR=false
    if [[ $REPLY =~ ^[OoYy]$ ]]; then
        DELETE_JAR=true
    fi
else
    DELETE_JAR=false
fi

echo ""
read -p "Confirm deletion ? (o/N) : " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[OoYy]$ ]]; then
    echo "Operation canceled"
    exit 0
fi

# Deletion of the .patrimoine folder
echo "Deletion of $PATRIMOINE_DIR..."
if [ -d "$PATRIMOINE_DIR" ]; then
    rm -rf "$PATRIMOINE_DIR"
    if [ $? -eq 0 ]; then
        echo "Folder deleted successfully"
    else
        echo "Error deleting folder"
        exit 1
    fi
else
    echo "No folders to delete"
fi

# Config
PATRIMOINE_BASE_DIR="$HOME/.patrimoine"
PATRIMOINE_DOWNLOAD_SUB_DIRS=("planifies" "realises" "justificatifs")

# Creating Patrimoine Directories
echo ""
echo "[START] - Creating necessary patrimoine folders"
for sub_dir in "${PATRIMOINE_DOWNLOAD_SUB_DIRS[@]}"; do
    mkdir -p "$PATRIMOINE_BASE_DIR/download/$sub_dir"
done
echo "[FINISHED] - Creating necessary patrimoine folders"

# Download templates if not downloaded yet
download_file() {
    local url="$1"
    local dest="$2"

    if command -v curl &>/dev/null; then
        if is_windows; then
            curl --ssl-no-revoke -L -o "$dest" "$url"
        else
            curl -L -o "$dest" "$url"
        fi
    elif command -v wget &>/dev/null; then
        wget -O "$dest" "$url"
    else
        echo "Error: Neither curl nor wget is installed" >&2
        exit 1
    fi
}

# Replace placeholders in filename and content
replace_placeholders_in_file() {
    local file="$1"

    # --- New filename ---
    local new_file="$file"
    new_file="${new_file/MOI/$MOI}"
    new_file="${new_file/PETIT_COPAIN_OU_PETITE_COPINE/$PETIT_COPAIN_OU_PETITE_COPINE}"

    if [ "$new_file" != "$file" ]; then
        mv "$file" "$new_file"
        file="$new_file"
    fi

    # --- Replace inside file ---
    sed -i.bak "s/\$MOI/$MOI/g; s/\$PETIT_COPAIN_OU_PETITE_COPINE/$PETIT_COPAIN_OU_PETITE_COPINE/g" "$file" && rm "${file}.bak"
}

TEMPLATE_BASE_URL="https://raw.githubusercontent.com/Sheddy00/patrimoine-LFI/refs/heads/main/templates"
TEMPLATE_FILE_NAMES=("CasSet.tout.md" "MOI.cas.md" "Parents.cas.md" "PETIT_COPAIN_OU_PETITE_COPINE.cas.md")

echo ""
echo "[START] - Downloading templates"
DOWNLOAD_DIR="$PATRIMOINE_BASE_DIR/download/realises"
for name in "${TEMPLATE_FILE_NAMES[@]}"; do
    url="$TEMPLATE_BASE_URL/$name"
    local filename="$(basename "$url")"
    local dest="$DOWNLOAD_DIR/$filename"

    echo "[DOWNLOADING] $filename"
    download_file "$url" "$dest"

    echo "[REPLACING PLACEHOLDERS] $filename"
    replace_placeholders_in_file "$dest"
done

echo "[FINISHED] All templates downloaded and placeholders replaced."
cp -r "$PATRIMOINE_BASE_DIR/download/realises/"* "$PATRIMOINE_BASE_DIR/download/planifies/"

# Delete the JARs if requested
if [ "$DELETE_JAR" = true ]; then
    echo ""
    for jar in $JAR_FILES; do
        echo "Deletion of $jar..."
        rm -f "$jar"
        if [ $? -eq 0 ]; then
            echo "File deleted successfully"
        else
            echo "Error during deletion"
        fi
    done
fi

echo ""
echo "========================================="
echo "Reset completed"
echo "========================================="
echo ""
echo "You can now restart the main script"
