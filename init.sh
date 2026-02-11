#!/bin/bash

# Paths
PATRIMOINE_DIR="$HOME/.patrimoine"
JAR_PATTERN="$HOME/patrimoine@*.jar"

# Security check
if [ -z "$HOME" ]; then
    echo "Error : HOME variable not defined"
    exit 1
fi

echo "This script will remove :"
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

# Delete the JARs
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
