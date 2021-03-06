#!/bin/bash -e

function usage() {
    cat <<EOF
usage: ./install.sh [-h|--help] [game-dir]

    game-dir  - Path to install. Defaults to '\$HOME/Games/Warframe'
    -h --help - Display this help message

Environment Variables:

The following environment variables will be preserved when later running the game:

    WINE      - Path to custom Wine executable. Defaults to 'wine64'
    WINEARCH  - Override Wine execution architecture. Currently, only 'win64' is supported.
    WINEDEBUG - Wine debugging settings. Defaults to '-all', all messages off.

EOF
}

if [ $# -gt 0 ]; then
    if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
	usage
	exit 0
    fi
fi

GAMEDIR="${1:-${HOME}/Games/Warframe}"

WFDIR="$GAMEDIR/drive_c/Program Files/Warframe"

WINE=${WINE:-wine64}
export WINEARCH=${WINEARCH:-win64}
export WINEDEBUG=${WINEDEBUG:--all}
export WINEPREFIX="$GAMEDIR"

echo "*************************************************"
echo "Creating wine prefix and performing winetricks."
echo "*************************************************"

mkdir -p "$GAMEDIR"
winetricks -q win7

echo "*************************************************"
echo "Creating warframe directories."
echo "*************************************************"
mkdir -p "$WFDIR"
mkdir -p "${GAMEDIR}/drive_c/users/${USER}/Local Settings/Application Data/Warframe"

echo "*************************************************"
echo "Copying warframe files."
echo "*************************************************"

cp -R updater.sh README.md dxvk-patched FAudio Warframe.x64.dxvk-cache "$WFDIR"

pushd "$WFDIR"

cat > uninstall.sh <<EOF
#!/bin/bash

if [ -e /usr/bin/warframe ]; then
	sudo rm -R /usr/bin/warframe
fi
rm -R "\$HOME/Desktop/warframe.desktop" "$GAMEDIR" \\
      "\$HOME/.local/share/applications/warframe.desktop"
echo "Warframe has been successfully removed."
EOF

chmod a+x updater.sh
chmod a+x uninstall.sh

echo "*************************************************"
echo "Installing async-patched DXVK."
echo "*************************************************"
cd dxvk-patched
winetricks --force setup_dxvk.verb
cd ..

#echo "*************************************************"
#echo "Installing FAudio with WMA support."
#echo "*************************************************"
cd FAudio
chmod a+x wine_setup_native && ./wine_setup_native
cd ..

echo "*************************************************"
echo "Creating warframe shell script"
echo "*************************************************"

cat > warframe.sh <<EOF
#!/bin/bash

export PULSE_LATENCY_MSEC=60
export __GL_THREADED_OPTIMIZATIONS=1
export MESA_GLTHREAD=TRUE
export PBA_DISABLE=1

export WINE=$WINE
export WINEARCH=$WINEARCH
export WINEDEBUG=$WINEDEBUG
export WINEPREFIX="$WINEPREFIX"
export DXVK_ASYNC=1

cd "$WFDIR"
exec ./updater.sh "\$@"
EOF

chmod a+x warframe.sh

# Errors are now tolerable
set +e

echo "*************************************************"
echo "The next few steps will prompt you for shortcut creations. If root is required, please enter your root password when prompted."
echo "*************************************************"

read -p "Would you like to add warframe to the default path? y/n" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
	sudo cp "$WFDIR/warframe.sh" /usr/bin/warframe
fi

popd &>/dev/null

function mkdesktop() {
	cat <<EOF
[Desktop Entry]
Encoding=UTF-8
Name=Warframe
GenericName=Warframe
Exec="$WFDIR/warframe.sh"
Icon="$WFDIR/warframe.png"
StartupNotify=true
Terminal=false
Type=Application
Categories=Application;Game
EOF
}

# Download warframe.png icon for creating shortcuts
curl -A Mozilla/5.0 http://i.imgur.com/lh5YKoc.png -o warframe.png

read -p "Would you like a menu shortcut? y/n" -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then

	echo "*************************************************"
	echo "Creating warframe application menu shortcut."
	echo "*************************************************"
	cp warframe.png "$WFDIR"
	mkdesktop > "$HOME/.local/share/applications/warframe.desktop"
fi

read -p "Would you like a desktop shortcut? y/n" -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
	echo "*************************************************"
	echo "Creating warframe desktop shortcut."
	echo "*************************************************"
	cp warframe.png "$WFDIR"
	mkdesktop > "${HOME}/Desktop/warframe.desktop"
fi


echo "*************************************************"
echo "Installation complete! It is safe to delete this folder."
echo "*************************************************"
