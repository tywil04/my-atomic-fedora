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

echo "Repo URL: $REPO_URL"
echo "Repo Name: $REPO_NAME"
echo "Collection ID: $COLLECTION_ID"
echo "Install List: ${INSTALL[@]}"

echo "Setting up post rebase scripts and services"
cp -r "$MODULE_DIRECTORY"/flatpaks/tylers-os-system-post-rebase-setup /usr/bin/tylers-os-system-post-rebase-setup
cp -r "$MODULE_DIRECTORY"/flatpaks/tylers-os-user-post-rebase-setup /usr/bin/tylers-os-user-post-rebase-setup
cp -r "$MODULE_DIRECTORY"/flatpaks/tylers-os-system-post-rebase-setup.service /usr/lib/systemd/system/tylers-os-system-post-rebase-setup.service
cp -r "$MODULE_DIRECTORY"/flatpaks/tylers-os-user-post-rebase-setup.service /usr/lib/systemd/user/tylers-os-user-post-rebase-setup.service

echo "Making flatpaks directory"
mkdir -p "/usr/share/tylers-os/flatpaks/offline-repo"

echo "Adding flathub as flatpak remote"
flatpak remote-add --if-not-exists "$REPO_NAME" "$REPO_URL"

echo "Installing packages from install list"
flatpak install --assumeyes "${INSTALL[@]}"

echo "Modifying flathub remote"
flatpak remote-modify --collection-id="$COLLECTION_ID" "$REPO_NAME"

echo "Creating offline flatpak repo"
flatpak create-usb "/usr/share/tylers-os/flatpaks/offline-repo" "${INSTALL[@]}"

echo "Saving install list for post rebase setup"
for $APP in $INSTALL; do
    echo $APP >> "/usr/share/tylers-os/flatpaks/install-list"
done

echo "Enabling post rebase services"
systemctl enable -f stylers-os-system-post-rebase-setup.service
systemctl enable -f --global tylers-os-user-post-rebase-setup.service

echo "Done"
