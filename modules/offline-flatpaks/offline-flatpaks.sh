#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -euo pipefail

OUTPUT_DIR="/usr/share/tylers-os/offline-flatpaks"

get_json_array INSTALL "try .install[]" "$1"
REPO_URL=$(echo "$1" | jq -r 'try .["repo-url"]')
REPO_NAME=$(echo "$1" | jq -r 'try .["repo-name"]')
COLLECTION_ID=$(echo "$1" | jq -r 'try .["collection-id"]')

if [[ $REPO_URL == "null" || $REPO_NAME == "null" || $COLLECTION_ID == "null" ]]; then
    REPO_URL="https://dl.flathub.org/repo/flathub.flatpakrepo"
    REPO_NAME="flathub"
    COLLECTION_ID="org.flathub.Stable"
fi

echo "Repo URL: $REPO_URL"
echo "Repo Name: $REPO_NAME"
echo "Collection ID: $COLLECTION_ID"
echo "Install List: ${INSTALL[@]}"

echo "Making offline-flatpaks directory"
mkdir -p "$OUTPUT_DIR"

echo "Adding flathub as flatpak remote"
flatpak remote-add --if-not-exists "$REPO_NAME" "$REPO_URL"

echo "Installing packages from install list"
flatpak install --assumeyes "${INSTALL[@]}"

echo "Modifying flathub remote"
flatpak remote-modify --collection-id="$COLLECTION_ID" "$REPO_NAME"

echo "Creating offline flatpak repo"
flatpak create-usb "$OUTPUT_DIR" "${INSTALL[@]}"

echo "Saving install list for post rebase setup"
for $APP in $INSTALL; do
    echo $APP >> "$OUTPUT_DIR/install-list"
done

echo "Done"
