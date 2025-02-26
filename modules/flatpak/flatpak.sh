#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -euo pipefail

get_json_array INSTALL "try .install[]" "$1"

echo "Install List: ${INSTALL[@]}"

echo "Setting up post rebase script and service"
cp -r "$MODULE_DIRECTORY"/flatpak/tylers-os-flatpak-setup /usr/bin/tylers-os-flatpak-setup
chmod +x /usr/bin/tylers-os-flatpak-setup
cp -r "$MODULE_DIRECTORY"/flatpak/tylers-os-flatpak-setup.service /usr/lib/systemd/system/tylers-os-flatpak-setup.service

sysctl kernel.unprivileged_userns_clone=1

echo "Making flatpak directory"
mkdir -p "/usr/share/tylers-os/flatpak/offline-repo"

echo "Adding flathub as flatpak remote"
flatpak remote-add --if-not-exists "flathub" "https://dl.flathub.org/repo/flathub.flatpakrepo"

echo "Installing packages from install list"
flatpak install --assumeyes --noninteractive "${INSTALL[@]}"

echo "Modifying flathub remote"
flatpak remote-modify --collection-id="org.flathub.Stable" "flathub"

echo "Creating offline flatpak repo"
flatpak create-usb "/usr/share/tylers-os/flatpak/offline-repo" "${INSTALL[@]}"

echo "Saving install list for post rebase setup"
for APP in ${INSTALL[@]}; do
    echo $APP >> "/usr/share/tylers-os/flatpak/install-list"
done

echo "Hashing install list"
$INSTALL_LIST_HASH=$(sha256sum "/usr/share/tylers-os/flatpak/install-list" | awk '{ print $1 }')
echo $INSTALL_LIST_HASH > "/usr/share/tylers-os/flatpak/install-list-hash"

echo "Enabling post rebase service"
systemctl enable -f tylers-os-flatpak-setup.service

echo "Done"
