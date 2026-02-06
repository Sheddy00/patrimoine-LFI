#!/bin/bash

# --- Configuration ---
LAST_VERSION="0.2.9" # put here the latest version number
LINK='https://www.dropbox.com/scl/fi/vq9tb9q4n7rxe1y1hlo3h/patrimoine-0.2.9.jar?rlkey=iepbhyq7muz2qnz4ipq5crsox&st=pf8koyk7&dl=1'  # link to dropbox

JAR_NAME="patrimoine@${LAST_VERSION}.jar"
USER_DIR="$HOME"

# --- Patrimoine directories ---
BASE_DIR="$HOME/.patrimoine/download"
PLANIFIES_DIR="$BASE_DIR/planifies"
REALISES_DIR="$BASE_DIR/realises"
JUSTIFICATIFS_DIR="$BASE_DIR/justificatifs"

# --- Gists ---
GIST_PLANIFIES_REALISES="https://gist.github.com/Mihajatiana-dev/1871e3fddaf1a9f8b347f2adea1c323c/archive/refs/heads/master.zip"
GIST_JUSTIFICATIFS="https://gist.github.com/Mihajatiana-dev/9d3c42811242c373696443a028b2bdcf/archive/refs/heads/master.zip"

TMP_DIR="/tmp/patrimoine_templates"

cd "$USER_DIR" || { echo "Impossible d'accéder au dossier $USER_DIR"; exit 1; }

echo "Création des dossiers Patrimoine si absents..."
mkdir -p "$PLANIFIES_DIR" "$REALISES_DIR" "$JUSTIFICATIFS_DIR"

echo "Téléchargement des templates..."
rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"

# --- Templates planifies & realises ---
curl -L -o "$TMP_DIR/templates_pr.zip" "$GIST_PLANIFIES_REALISES"
unzip -q "$TMP_DIR/templates_pr.zip" -d "$TMP_DIR/pr"

PR_EXTRACTED_DIR=$(find "$TMP_DIR/pr" -mindepth 1 -maxdepth 1 -type d)

cp -r "$PR_EXTRACTED_DIR"/* "$PLANIFIES_DIR"/
cp -r "$PR_EXTRACTED_DIR"/* "$REALISES_DIR"/

# --- Templates justificatifs ---
curl -L -o "$TMP_DIR/templates_j.zip" "$GIST_JUSTIFICATIFS"
unzip -q "$TMP_DIR/templates_j.zip" -d "$TMP_DIR/j"

J_EXTRACTED_DIR=$(find "$TMP_DIR/j" -mindepth 1 -maxdepth 1 -type d)

cp -r "$J_EXTRACTED_DIR"/* "$JUSTIFICATIFS_DIR"/

# Nettoyage
rm -rf "$TMP_DIR"

echo "Templates installés avec succès."

echo "Vérification de la présence du fichier patrimoine.jar dans $USER_DIR..."

# Find existing jar files matching the pattern
EXISTING_JAR=$(ls patrimoine@*.jar 2>/dev/null | head -n 1)

if [ -n "$EXISTING_JAR" ]; then
    CURRENT_VERSION=$(echo "$EXISTING_JAR" | cut -d "@" -f 2 | cut -d "." -f 1-3)
    if [ "$CURRENT_VERSION" = "$LAST_VERSION" ]; then
        echo "Vous avez déjà la dernière version : $EXISTING_JAR"
    else
        echo "Ancienne version détectée : $CURRENT_VERSION. Suppression et téléchargement de la version $LAST_VERSION..."
        rm -f "$EXISTING_JAR"
        curl -L -o "$JAR_NAME" "$LINK"
    fi
else
    echo "Aucune version détectée. Téléchargement de la version $LAST_VERSION..."
    curl -L -o "$JAR_NAME" "$LINK"
fi

# Check if the jar file was downloaded successfully
if [ -f "$JAR_NAME" ]; then
    echo "Lancement de $JAR_NAME..."
    java -jar "$JAR_NAME"
else
    echo "Erreur : le fichier $JAR_NAME n'a pas pu être téléchargé."
    exit 1
fi
