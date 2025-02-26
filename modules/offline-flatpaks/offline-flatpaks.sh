#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -euo pipefail

get_json_array INSTALL "try .install[]" "$1"
REPO_URL=$(echo "$1" | jq -r 'try .["repo-url"]')
REPO_NAME=$(echo "$1" | jq -r 'try .["repo-name"]')
COLLECTION_ID=$(echo "$1" | jq -r 'try .["collection-id"]')

if [[ $REPO_URL == "null" || $REPO_NAME == "null" || $COLLECTION_ID == "null" ]]; then
    REPO_URL="https://dl.flathub.org/repo/flathub.flatpakrepo"
    REPO_NAME="flathub"
    COLLECTION_ID="org.flathub.Stable"
fi

mkdir -p /usr/share/tylers-os/offline-flatpaks

flatpak remote-add --if-not-exists $REPO_NAME $REPO_URL

flatpak remote-modify --collection-id=$COLLECTION_ID $REPO_NAME

flatpak create-usb /usr/share/tylers-os/offline-flatpaks "${INSTALL[@]}"
