#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -euo pipefail

get_json_array INSTALL "try .install[]" "$1"

echo "Install List: ${INSTALL[@]}"

echo "Setting up post rebase script and service"
cp -r "$MODULE_DIRECTORY"/flatpak/tylers-os-post-rebase-setup /usr/bin/tylers-os-post-rebase-setup
chmod +x /usr/bin/tylers-os-post-rebase-setup
cp -r "$MODULE_DIRECTORY"/flatpak/tylers-os-post-rebase-setup.service /usr/lib/systemd/system/tylers-os-post-rebase-setup.service

echo "Making flatpak directory"
mkdir -p "/usr/share/tylers-os/flatpak/offline-repo"

echo "Adding flathub as flatpak remote"
flatpak remote-add --if-not-exists "flathub" "https://dl.flathub.org/repo/flathub.flatpakrepo"

echo "Installing packages from install list"
flatpak install --assumeyes "${INSTALL[@]}"

echo "Modifying flathub remote"
flatpak remote-modify --collection-id="org.flathub.Stable" "flathub"

echo "Creating offline flatpak repo"
flatpak create-usb "/usr/share/tylers-os/flatpak/offline-repo" "${INSTALL[@]}"

echo "Saving install list for post rebase setup"
for APP in ${INSTALL[@]}; do
    echo $APP >> "/usr/share/tylers-os/flatpak/install-list"
done

echo "Saving install list for post rebase setup"
for APP in ${INSTALL[@]}; do
    echo $APP >> "/usr/share/tylers-os/flatpak/install-list"
done

echo "Enabling post rebase service"
systemctl enable -f tylers-os-post-rebase-setup.service

echo "Done"
