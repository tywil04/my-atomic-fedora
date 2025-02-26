#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -euo pipefail

get_json_array INSTALL "try .install[]" "$1"

echo "Install List: ${INSTALL[@]}"

echo "Copying files"
cp -r "$MODULE_DIRECTORY/flatpak/files/"* "/"

echo "Adding flathub remote"
flatpak remote-add --installation="tylers-os" --if-not-exists "flathub" "https://dl.flathub.org/repo/flathub.flatpakrepo"

echo "Installing packages"
flatpak install --installation="tylers-os" --assumeyes --noninteractive "${INSTALL[@]}"

echo "Done"
