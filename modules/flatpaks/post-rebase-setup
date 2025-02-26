#!/usr/bin/env bash

mapfile -t INSTALL < "/usr/share/tylers-os/flatpaks/install-list"
FEDORA_FLATPAK_APPS=$(flatpak list --app --columns=application --runtime | grep 'fedora')

for APP in $FEDORA_FLATPAK_APPS; do
    echo "Uninstalling fedora flatpak app $APP"
    flatpak uninstall --assumeyes "$APP"
done

flatpak remote-delete fedora

for APP in $INSTALL; do 
    flatpak install --user --assumeyes --sideload-repo="/usr/share/tylers-os/flatpaks/offline-repo/.ostree/repo"
done
