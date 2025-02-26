#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -euo pipefail

CONFIG_FILE=$1
get_json_array INSTALL "try .install[]" "$CONFIG_FILE"

flatpak remote-modify --collection-id=org.flathub.Stable flathub

flatpak create-usb /usr/share/tylers-os/offline-flatpaks "${INSTALL[@]}"

