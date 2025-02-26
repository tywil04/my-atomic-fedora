#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -euo pipefail

get_json_array INSTALL "try .install[]" "$1"

echo "Install List: ${INSTALL[@]}"

echo "Making directory for storage"
mkdir -p "/usr/share/tylers-os/flatpak/offline-repo"

echo "Copying files"
cp -r "$MODULE_DIRECTORY/flatpak/files" "/"

echo "Adding flathub as flatpak remote"
flatpak remote-add --if-not-exists "flathub" "https://dl.flathub.org/repo/flathub.flatpakrepo"

echo "Installing packages from install list"
flatpak install --assumeyes --noninteractive "${INSTALL[@]}"

echo "Modifying flathub remote"
flatpak remote-modify --collection-id="org.flathub.Stable" "flathub"

echo "Creating offline flatpak repo"
flatpak create-usb "/usr/share/tylers-os/flatpak/offline-repo" "${INSTALL[@]}"

echo "Saving install list for setup"
for APP in ${INSTALL[@]}; do
    echo $APP >> "/usr/share/tylers-os/flatpak/install-list"
done

echo "Enabling setup service"
systemctl enable -f tylers-os-flatpak-setup.service

echo "Done"
