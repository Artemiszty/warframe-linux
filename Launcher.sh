#!/bin/bash
# exit on first error, comment out for debugging
#set -e

# If we are not already running in a terminal
if [ ! -t 1 ]; then
	# Find a suitable one
	for i in x-terminal-emulator xterm gnome-terminal; do
		if which $i &>/dev/null; then
			# And respawn ourself inside it
			exec $i -e "$0" "$@"
		fi
	done

	# Couldn't find a terminal to run in. Just continue.
fi


# create folders if they don't exist - comment out for steam
#if [ ! -d "$WINEPREFIX/drive_c/Program Files/Warframe/Downloaded" ]; then
  #mkdir -p "$WINEPREFIX/drive_c/Program Files/Warframe/Downloaded/Public"
#fi

export PULSE_LATENCY_MSEC=60
export STEAM_COMPAT_DATA_PATH
export EXEPREFIX=$(echo "${PWD:0:-14}"Warframe/)
export PROTONDIR=$(echo ${PATH%%:*})
export DXVK_CONFIG_FILE=$(echo "$EXEPREFIX"dxvk-patched/dxvk.conf)

export PROTON=$(echo "${PROTONDIR:0:-9}"proton)

export __GL_THREADED_OPTIMIZATIONS=1
export MESA_GLTHREAD=TRUE

# warframe directory in steamapps common
export WARFRAME_DIR="$(dirname "${PWD}")"

# automatically enable firstrun flag when FIRSTRUN_FILE is missing
export FIRSTRUN_FILE="${WARFRAME_DIR}/firstrun.done"
if [ -f "$FIRSTRUN_FILE" ]; then
	firstrun=false
else
	firstrun=true
	echo "***********************"
	echo "Enabling firstrun flag.   "
	echo "***********************"
	touch "${FIRSTRUN_FILE}"
	echo "FIRSTRUN = true"
fi

#currently we use the 32 bit exe due to this bug with 64 bit xaudio2_7:
#https://bugs.winehq.org/show_bug.cgi?id=38668#c72
WARFRAME_EXE="Warframe.exe"
export WINPATH=Z:$(echo $EXEPREFIX$WARFRAME_EXE | sed 's#/#\\#g')

if [ "$WARFRAME_EXE" = "Warframe.x64.exe" ]; then
	export WINE=$(echo "${PROTONDIR}"wine64)
else
	export WINE=$(echo "${PROTONDIR}"wine)	
fi

function print_synopsis {
	echo "$0 [options]"
	echo ""
	echo "options:"
	echo "    --firstrun          installs the necessary files to run the game."
	echo "    --no-update         explicitly disable updating of warframe."
	echo "    --no-cache          explicitly disable cache optimization of warframe cache files."
	echo "    --no-game           explicitly disable launching of warframe."
	echo "    -language:xx        changes the game's language. example: -language:en"
	echo "                        supported languages: de,en,es,fr,it,ja,ko,pl,pt,ru,tc,uk,zh"	
	echo "    -v, --verbose       print each executed command"
	echo "    -h, --help          print this help message and quit"
}

#############################################################
# default values
#############################################################
do_update=true
do_cache=true
start_game=true
verbose=false
language="-language:en"
#############################################################
# parse command line arguments
#############################################################
# As long as there is at least one more argument, keep looping
while [[ $# -gt 0 ]]; do
	key="$1"
	case "$key" in
		--firstrun)
		firstrun=true
		;;
		--no-update)
		do_update=false
		;;
		--no-cache)
		do_cache=false
		;;
		--no-game)
		start_game=false
		;;
		"-language:"*)
		language="$key"
		;;
		-v|--verbose)
		verbose=true
		;;
		-h|--help)
		print_synopsis
		exit 0
		;;
		*)
		echo "Unknown option '$key'"
		print_synopsis
		exit 1
		;;
	esac
	# Shift after checking all the cases to get the next option
	shift
done

# show all executed commands
if [ "$verbose" = true ] ; then
	set -x
fi

if [ "$firstrun" = true ] ; then

echo "********************************"
echo "Preparing prefix for first run."
echo "********************************"

echo "Downloading Direct X..."

curl -A Mozilla/5.0 https://download.microsoft.com/download/8/4/A/84A35BF1-DAFE-4AE8-82AF-AD2AE20B6B14/directx_Jun2010_redist.exe -o directx_Jun2010_redist.exe

echo "Extracting Direct X... install files"
"$PROTON" run "$EXEPREFIX"Tools/directx_Jun2010_redist.exe /Q /T:C:\\dx9temp

echo "Installing Direct X... please wait...this will take a minute."
"$PROTON" run "$STEAM_COMPAT_DATA_PATH"/pfx/drive_c/dx9temp/DXSETUP.exe /silent

rm -R "$STEAM_COMPAT_DATA_PATH"/pfx/drive_c/dx9temp directx_Jun2010_redist.exe
	
	
echo "Adding XAudio2_7 dll override to registry..."

cat > wf.reg <<EOF
Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\Software\Wine\DllOverrides]
"xaudio2_7"="native,builtin"

[HKEY_CURRENT_USER\Software\Wine\X11 Driver]
"GrabFullScreen"="Y"

EOF

"$PROTON" run "$STEAM_COMPAT_DATA_PATH"/pfx/drive_c/windows/regedit.exe /S "$EXEPREFIX"Tools/wf.reg

echo "Adding patched wininet to proton..."


mv "$(echo "${PROTONDIR:0:-9}")"dist/lib/wine/wininet.dll.so "$(echo "${PROTONDIR:0:-9}")"dist/lib/wine/wininet.dll.so.bak
cp warframe-proton-fixes/lib/wine/wininet.dll.so "$(echo "${PROTONDIR:0:-9}")"dist/lib/wine/wininet.dll.so

mv "$(echo "${PROTONDIR:0:-9}")"dist/lib/wine/fakedlls/wininet.dll "$(echo "${PROTONDIR:0:-9}")"dist/lib/wine/fakedlls/wininet.dll.bak
cp warframe-proton-fixes/lib/wine/fakedlls/wininet.dll "$(echo "${PROTONDIR:0:-9}")"dist/lib/wine/fakedlls/wininet.dll

mv "$(echo "${PROTONDIR:0:-9}")"dist/lib64/wine/wininet.dll.so "$(echo "${PROTONDIR:0:-9}")"dist/lib64/wine/wininet.dll.so.bak
cp warframe-proton-fixes/lib64/wine/wininet.dll.so "$(echo "${PROTONDIR:0:-9}")"dist/lib64/wine/wininet.dll.so

mv "$(echo "${PROTONDIR:0:-9}")"dist/lib64/wine/fakedlls/wininet.dll "$(echo "${PROTONDIR:0:-9}")"dist/lib64/wine/fakedlls/wininet.dll.bak
cp warframe-proton-fixes/lib64/wine/fakedlls/wininet.dll "$(echo "${PROTONDIR:0:-9}")"dist/lib64/wine/fakedlls/wininet.dll

cp warframe-proton-fixes/lib64/wine/fakedlls/wininet.dll "$STEAM_COMPAT_DATA_PATH"/pfx/drive_c/windows/system32/wininet.dll
cp warframe-proton-fixes/lib/wine/fakedlls/wininet.dll "$STEAM_COMPAT_DATA_PATH"/pfx/drive_c/windows/syswow64/wininet.dll

echo "Adding patched dxvk to proton..."

mv "$(echo "${PROTONDIR:0:-9}")"dist/lib64/wine/dxvk/d3d11.dll "$(echo "${PROTONDIR:0:-9}")"dist/lib64/wine/dxvk/d3d11.dll.bak
cp dxvk-patched/x64/d3d11.dll "$(echo "${PROTONDIR:0:-9}")"dist/lib64/wine/dxvk/d3d11.dll

mv "$(echo "${PROTONDIR:0:-9}")"dist/lib64/wine/dxvk/dxgi.dll "$(echo "${PROTONDIR:0:-9}")"dist/lib64/wine/dxvk/dxgi.dll.bak
cp dxvk-patched/x64/dxgi.dll "$(echo "${PROTONDIR:0:-9}")"dist/lib64/wine/dxvk/dxgi.dll

mv "$(echo "${PROTONDIR:0:-9}")"dist/lib/wine/dxvk/d3d11.dll "$(echo "${PROTONDIR:0:-9}")"dist/lib/wine/dxvk/d3d11.dll.bak
cp dxvk-patched/x32/d3d11.dll "$(echo "${PROTONDIR:0:-9}")"dist/lib/wine/dxvk/d3d11.dll

mv "$(echo "${PROTONDIR:0:-9}")"dist/lib/wine/dxvk/dxgi.dll "$(echo "${PROTONDIR:0:-9}")"dist/lib/wine/dxvk/dxgi.dll.bak
cp dxvk-patched/x32/dxgi.dll "$(echo "${PROTONDIR:0:-9}")"dist/lib/wine/dxvk/dxgi.dll

cp dxvk-patched/x64/dxgi.dll "$STEAM_COMPAT_DATA_PATH"/pfx/drive_c/windows/system32/dxgi.dll
cp dxvk-patched/x64/d3d11.dll "$STEAM_COMPAT_DATA_PATH"/pfx/drive_c/windows/system32/d3d11.dll
cp dxvk-patched/x32/dxgi.dll "$STEAM_COMPAT_DATA_PATH"/pfx/drive_c/windows/syswow64/dxgi.dll
cp dxvk-patched/x32/d3d11.dll "$STEAM_COMPAT_DATA_PATH"/pfx/drive_c/windows/syswow64/d3d11.dll

echo "Finished prefix preparation!"

fi


#############################################################
# update game files
#############################################################
if [ "$do_update" = true ] ; then
    #old bug fix, leave this commented out for now
    #find "$EXEPREFIX" -name 'Warframe.*' -exec rm {} \;

	find "$EXEPREFIX" -name '*.lzma' -exec rm {} \;

	#keep wget as a backup in case curl fails
	#wget -qN http://origin.warframe.com/index.txt.lzma
	curl -A Mozilla/5.0 -s http://origin.warframe.com/index.txt.lzma -o index.txt.lzma
	unlzma -f index.txt.lzma


	echo "*********************"
	echo "Checking for updates."
	echo "*********************"

	#remove old downloaded archives
	find "$EXEPREFIX" -name '*.lzma' -exec rm {} \;

	#create list of all files to download
	rm -f updates.txt
	touch updates.txt
	while read -r line; do
		# get the raw filename with md5sum and lzma extension
		RAW_FILENAME=$(echo $line | awk -F, '{print $1}')
		# path to local file currently tested
		LOCAL_PATH="$EXEPREFIX${RAW_FILENAME:1:-38}"

		#check if local_index.txt exists
		if [ -f "local_index.txt" ]; then
			#if local index exists, check if new entry is in it
			if grep -q "$RAW_FILENAME" "local_index.txt"; then
				#if it's in the list, check if the file exists already
				if [ ! -f "$LOCAL_PATH" ]; then
					# if file doesnt exist, add it to download list, exempt launcher and Cache.windows
                    if [[ "$LOCAL_PATH" == *"Cache.Windows"* ]]; then
                        echo "Skipping Cache.Windows update"
                    elif [[ "$LOCAL_PATH" == *"Launcher"* ]]; then
                        echo "Skipping Launcher update"
                    else
                        echo "$line" >> updates.txt
                    fi
				fi
			else
				#if new md5sum isn't in local index list, add it to download list, exempt launcher and Cache.windows
				if [[ "$LOCAL_PATH" == *"Cache.Windows"* ]]; then
                    echo "Skipping Cache.Windows update"
                elif [[ "$LOCAL_PATH" == *"Launcher"* ]]; then
                    echo "Skipping Launcher update"
                else
                    echo "$line" >> updates.txt
				fi
			fi
		else
			#if no md5sum list exists, download all files and log md5sums, exempt launcher and Cache.windows
				if [[ "$LOCAL_PATH" == *"Cache.Windows"* ]]; then
                    echo "Skipping Cache.Windows update"
                elif [[ "$LOCAL_PATH" == *"Launcher"* ]]; then
                    echo "Skipping Launcher update"
                else
                    echo "$line" >> updates.txt
				fi
		fi
	done < index.txt
	# sum up total size of updates
	TOTAL_SIZE=0
	while read -r line; do
		# get the remote size of the lzma file when downloading
		REMOTE_SIZE=$(echo $line | awk -F, '{print $2}' | sed 's/\r//')
		(( TOTAL_SIZE+=$REMOTE_SIZE ))
	done < updates.txt

	echo "*********************"
	echo "Downloading updates."
	echo "*********************"

	#currently downloaded size
	CURRENT_SIZE=0
	PERCENT=0
	while read -r line; do
		#get the raw filename with md5sum and lzma extension
		RAW_FILENAME=$(echo $line | awk -F, '{print $1}')
		#get the remote size of the lzma file when downloading
		REMOTE_SIZE=$(echo $line | awk -F, '{print $2}' | sed 's/\r//')
		#get the md5 sum from the current line
		MD5SUM=${RAW_FILENAME: -37:-5}
		#convert it to lower case
		MD5SUM=${MD5SUM,,}
		#path to local file currently tested
		LOCAL_FILENAME="${RAW_FILENAME:0:-38}"
		LOCAL_PATH="$EXEPREFIX${LOCAL_FILENAME}"
		#URL where to download the latest file
		DOWNLOAD_URL="http://origin.warframe.com$RAW_FILENAME"
		#path to local file to be downloaded
		LZMA_PATH="$EXEPREFIX${RAW_FILENAME}"
		#path to downloaded and extracted file
		EXTRACTED_PATH="$EXEPREFIX${RAW_FILENAME:0:-5}"

		#variable to specify whether to download current file or not
		do_update=true

		if [ -f "$LOCAL_PATH" ]; then
			#local file exists

			#check md5sum of local file
			OLDMD5SUM=$(md5sum "$LOCAL_PATH" | awk '{print $1}')

			if [ "$OLDMD5SUM" = "$MD5SUM" ]; then
				#nothing to do
				do_update=false
			else
				#md5sum mismatch, download new file
				do_update=true
			fi
		else
			# local file does not exist
			do_update=true
		fi

		if [ -f local_index.txt ]; then
			#remove old local_index entry
			sed -i "\#${LOCAL_FILENAME}.*#,+1 d" local_index.txt

			#also remove blank lines
			sed -i '/^\s*$/d' local_index.txt
		fi

		#do download
		if [ "$do_update" = true ]; then
			#show progress percentage for each downloading file
            echo "Total update progress: $PERCENT% Downloading: ${RAW_FILENAME:0:-38}"
			#download file and replace old file
			
			#skip launcher until we figure out how to get steam to use a different file to launch the game
            #if first run, download all necessary tools and folders except Cache.Windows

                    #if using steam, comment the line below out as steam installs all the tools needed to launch warframe.exe
                    #if [ "$firstrun" = true ]; then
                        if [ ! -d "$(dirname "$LOCAL_PATH")" ]; then
                            mkdir -p "$(dirname "$LOCAL_PATH")"
                        fi
                        mkdir -p "$(dirname "$LOCAL_PATH")"
                        echo $DOWNLOAD_URL
                        curl -A Mozilla/5.0 $DOWNLOAD_URL | unlzma - > "$LOCAL_PATH"
                    #if using steam, comment the line below out as steam installs all the tools needed to launch warframe.exe on first run
                    #fi

		fi

		#update local index
		echo "$line" >> local_index.txt

		#update progress percentage
		(( CURRENT_SIZE+=$REMOTE_SIZE ))
		PERCENT=$(( ${CURRENT_SIZE}*100/${TOTAL_SIZE} ))
	done < updates.txt

	# cleanup
	rm updates.txt
	rm index.*

	# run warframe internal updater
	cp Launcher.exe Launcher-lutris.exe
	"$PROTON" run "$EXEPREFIX$WARFRAME_EXE" -silent -log:/Preprocessing.log -dx10:1 -dx11:1 -threadedworker:1 -cluster:public "$language" -applet:/EE/Types/Framework/ContentUpdate -registry:Steam
	rm Launcher.exe.bak
	mv Launcher.exe Launcher.exe.bak
	mv Launcher-lutris.exe Launcher.exe
fi

#############################################################
# cache optimization
#############################################################
if [ "$do_cache" = true ] ; then
	echo "*********************"
	echo "Optimizing Cache."
	echo "*********************"
	"$PROTON" run "$EXEPREFIX$WARFRAME_EXE" -silent -log:/Preprocessing.log -dx10:1 -dx11:1 -threadedworker:1 -cluster:public "$language" -applet:/EE/Types/Framework/CacheDefraggerAsync /Tools/CachePlan.txt -registry:Steam
fi


#############################################################
# actually start the game
#############################################################
if [ "$start_game" = true ] ; then

	echo "*********************"
	echo "Launching Warframe."
	echo "*********************"
	LD_PRELOAD=/home/$USER/.local/share/Steam/ubuntu12_32/gameoverlayrenderer.so:/home/$USER/.local/share/Steam/ubuntu12_64/gameoverlayrenderer.so \
	"$WINE" cmd /C start /unix "$EXEPREFIX$WARFRAME_EXE" -log:/Preprocessing.log -dx10:1 -dx11:1 -threadedworker:1 -cluster:public "$language" -fullscreen:0 -registry:Steam 2> /dev/null
fi

#comment out to allow window to close
#read
