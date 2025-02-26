#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -euo pipefail

CONFIG_FILE=$1
get_json_array INSTALL "try .install[]" "$CONFIG_FILE"
REPO_URL=$(jq -r 'try .["repo-url"]' "$CONFIG_FILE")
REPO_NAME=$(jq -r 'try .["repo-name"]' "$CONFIG_FILE")
COLLECTION_ID=$(jq -r 'try .["collection-id"]' "$CONFIG_FILE")

mkdir -p /usr/share/tylers-os/offline-flatpaks

flatpak remote-add --if-not-exists $REPO_NAME $REPO_URL

flatpak remote-modify --collection-id=$COLLECTION_ID $REPO_NAME

flatpak create-usb /usr/share/tylers-os/offline-flatpaks "${INSTALL[@]}"
