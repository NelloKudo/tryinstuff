#!/bin/bash

currentpath=$(pwd)
winepath=$HOME/.local/share/lutris/runners/wine/wine-osu/bin
mkdir -p "$currentpath"/osuconfig

# Checking for dependencies:


function tweaks()
{
    # Installing osu-handler from https://github.com/openglfreak/osu-handler-wine / https://aur.archlinux.org/packages/osu-handler
    wget -O "$currentpath"/osuconfig/osu-handler-wine https://github.com/NelloKudo/osu-winello/raw/main/stuff/osu-handler-wine 
    chmod +x "$currentpath"/osuconfig/osu-handler-wine

    # Installing osu-mime from https://aur.archlinux.org/packages/osu-mime
    wget -O /tmp/osu-mime.tar.gz https://aur.archlinux.org/cgit/aur.git/snapshot/osu-mime.tar.gz
    tar -xf /tmp/osu-mime.tar.gz -C /tmp
    mkdir -p "$HOME/.local/share/mime/packages"
    cp /tmp/osu-mime/osu-file-extensions.xml "$HOME/.local/share/mime/packages/osuwinello-file-extensions.xml"
    rm -f /tmp/osu-mime.tar.gz
    rm -rf /tmp/osu-mime

    # Creating entries..
    echo "[Desktop Entry]
    Type=Application
    Name=osu!
    MimeType=application/x-osu-skin-archive;application/x-osu-replay;application/x-osu-beatmap-archive;
    Exec=$currentpath/osuconfig/osu-handler-wine %f
    NoDisplay=true
    StartupNotify=true" >> "$HOME/.local/share/applications/osuwinello-file-extensions-handler.desktop"
    chmod +x "$HOME/.local/share/applications/osuwinello-file-extensions-handler.desktop"

    echo "[Desktop Entry]
    Type=Application
    Name=osu!
    MimeType=x-scheme-handler/osu;
    Exec=$currentpath/osuconfig/osu-handler-wine %u
    NoDisplay=true
    StartupNotify=true" >> "$HOME/.local/share/applications/osuwinello-url-handler.desktop"
    chmod +x "$HOME/.local/share/applications/osuwinello-url-handler.desktop"

    # Installing Winestreamproxy from https://github.com/openglfreak/winestreamproxy
    wget -O "/tmp/winestreamproxy-2.0.3-amd64.tar.gz" "https://github.com/openglfreak/winestreamproxy/releases/download/v2.0.3/winestreamproxy-2.0.3-amd64.tar.gz"
    tar -xf "/tmp/winestreamproxy-2.0.3-amd64.tar.gz" -C "/tmp/winestreamproxy"
    WINE="$winepath/wine" WINEPREFIX="$currentpath" bash "/tmp/winestreamproxy/install.sh"

    # Adding registry keys for native file manager support
    WINE="$winepath/wine" WINEPREFIX="$currentpath" wine reg add "HKEY_CLASSES_ROOT\folder\shell\open\command"
    WINE="$winepath/wine" WINEPREFIX="$currentpath" wine reg delete "HKEY_CLASSES_ROOT\folder\shell\open\ddeexec" /f
    WINE="$winepath/wine" WINEPREFIX="$currentpath" wine reg add "HKEY_CLASSES_ROOT\folder\shell\open\command" /f /ve /t REG_SZ /d "$currentpath/osuconfig/nativefolder.sh xdg-open \"%1\""
}   

if command -v zenity >/dev/null 2>&1 ; then
    zenitytrue="True"
else
    zenitytrue="False"
fi

if [ "$zenitytrue" == "True" ]; then
    if zenity --question --title="osu! tweaks install" --text="Welcome to the script! 
        This will install the following tweaks, taken from osu-winello:
        - Integration with native file manager
        - Install osu-handler to import skins/songs and make osu!direct links work again
        - Install Winestreamproxy for Discord RPC" --no-wrap ; then
        tweaks
        zenity --info --title="osu! tweaks install" --text="Installation finished! Relaunch Lutris and have fun playing!" --width=500
    fi
    else
    tweaks
fi


