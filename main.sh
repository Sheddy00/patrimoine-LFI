#!/bin/bash

# Placeholders 
MOI=$1
SEX=$2
PETIT_COPAIN_OU_PETITE_COPINE=$([[ "$SEX" == "M" ]] && echo "PetiteCopine" || echo "PetitCopain")

# Detect windows
is_windows() {
    [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" || "$OSTYPE" == "cygwin" ]]
}

# Config
PATRIMOINE_BASE_DIR="$HOME/.patrimoine"
PATRIMOINE_DOWNLOAD_SUB_DIRS=("planifies" "realises" "justificatifs")

# Creating Patrimoine Directories
create_patrimoine_directories() {
    echo "[START] - Creating necessary patrimoine folders"
    for sub_dir in "${PATRIMOINE_DOWNLOAD_SUB_DIRS[@]}"; do
        mkdir -p "$PATRIMOINE_BASE_DIR/download/$sub_dir"
    done
    echo "[FINISHED] - Creating necessary patrimoine folders"
}

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
        echo "Erreur : ni curl ni wget n'est installé" >&2
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
download_templates() {
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
}

should_configure() {
    local dir="$PATRIMOINE_BASE_DIR/download/realises"

    if [ ! -d "$dir" ]; then
        return 0  # dossier vide / inexistant
    fi

    # Vérifie s'il contient au moins un fichier
    if [ "$(ls -A "$dir" 2>/dev/null)" ]; then
        return 1
    else
        return 0
    fi
}

if should_configure; then
    echo "Launch Configuration"
    rm -rf $PATRIMOINE_BASE_DIR
    create_patrimoine_directories
    download_templates
fi


LAST_VERSION="0.2.9" # put here the latest version number
LINK='https://www.dropbox.com/scl/fi/vq9tb9q4n7rxe1y1hlo3h/patrimoine-0.2.9.jar?rlkey=iepbhyq7muz2qnz4ipq5crsox&st=pf8koyk7&dl=1'

JAR_NAME="patrimoine@${LAST_VERSION}.jar"
USER_DIR="$HOME"

cd "$USER_DIR" || { echo "Impossible d'accéder au dossier $USER_DIR"; exit 1; }


echo "Vérification de la présence du fichier patrimoine.jar dans $USER_DIR..."

# Find existing jar files matching the pattern
EXISTING_JAR=$(ls patrimoine@*.jar 2>/dev/null | head -n 1)

if [ -n "$EXISTING_JAR" ]; then
    CURRENT_VERSION=$(echo "$EXISTING_JAR" | cut -d "@" -f 2 | cut -d "." -f 1-3)
    if [ "$CURRENT_VERSION" = "$LAST_VERSION" ]; then
        echo "Vous avez déjà la dernière version : $EXISTING_JAR dans $(pwd)/$EXISTING_JAR"
    else
        echo "Ancienne version détectée : $CURRENT_VERSION. Suppression et téléchargement de la version $LAST_VERSION..."
        rm -f "$EXISTING_JAR"
        if is_windows; then
            curl --ssl-no-revoke -L -o "$JAR_NAME" "$LINK"
        else
            curl -L -o "$JAR_NAME" "$LINK"
        fi
    fi
else
    echo "Aucune version détectée. Téléchargement de la version $LAST_VERSION..."
    echo "Le téléchargement peut prendre quelques instants..."
    if is_windows; then
        curl --ssl-no-revoke -L -o "$JAR_NAME" "$LINK"
    else
        curl -L -o "$JAR_NAME" "$LINK"
    fi
fi

echo "Lancement de $JAR_NAME..."
java -Dpatrimoine.mode=OFFLINE -jar "$JAR_NAME"
