#!/bin/bash
# exit on first error
set -e

# If we are not already running in a terminal
if [ ! -t 1 ]; then
	# Find a suitable one
	for i in xterm gnome-terminal konsole; do
		if which $i &>/dev/null; then
			# And respawn ourself inside it
			
			# We also need to make sure to use -- to delimit the commands,
			# as newer gnome-terminals have an issue with -e AND the args
			# containing a --, like --debug
			if [ "$i" == "gnome-terminal" ]; then
				exec $i -- "$0" "$@"
			else
				exec $i -e "$0" "$@"
			fi
		fi
	done

	# Couldn't find a terminal to run in. Just continue.
fi

# create folders if they don't exist
if [ ! -d "$WINEPREFIX/drive_c/Program Files/Warframe/Downloaded" ]; then
  mkdir -p "$WINEPREFIX/drive_c/Program Files/Warframe/Downloaded/Public/"
fi

EXEPREFIX="$WINEPREFIX/drive_c/Program Files/Warframe/Downloaded/Public/"

WINE=${WINE:-wine64}
export WINEARCH=${WINEARCH:-win64}
export WINEDEBUG=${WINEDEBUG:--all}
export WINEPREFIX

export __PBA_GEO_HEAP=2048
export PULSE_LATENCY_MSEC=60
export __GL_THREADED_OPTIMIZATIONS=1
export MESA_GLTHREAD=TRUE

#currently we use the 32 bit exe due to this bug with 64 bit xaudio2_7:
#https://bugs.winehq.org/show_bug.cgi?id=38668#c72
WARFRAME_EXE="Warframe.exe"
export WINPATH=Z:$(echo $EXEPREFIX$WARFRAME_EXE | sed 's#/#\\#g')

function print_synopsis {
	echo "$0 [options]"
	echo ""
	echo "options:"
	echo "    --no-update         explicitly disable updating of warframe."
	echo "    --no-cache          explicitly disable cache optimization of warframe cache files."
	echo "    --no-game         explicitly disable launching of warframe."
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

#############################################################
# parse command line arguments
#############################################################
# As long as there is at least one more argument, keep looping
while [[ $# -gt 0 ]]; do
	key="$1"
	case "$key" in
		--no-update)
		do_update=false
		;;
		--no-cache)
		do_cache=false
		;;
		--no-game)
		start_game=false
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


#############################################################
# update game files
#############################################################
if [ "$do_update" = true ] ; then
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
		LOCAL_FILENAME="${RAW_FILENAME:1:-38}"
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
	"$WINE" cmd /C "$WINPATH" -silent -log:/Preprocessing.log -dx10:1 -dx11:1 -threadedworker:1 -cluster:public -language:en -applet:/EE/Types/Framework/ContentUpdate
fi


#############################################################
# cache optimization
#############################################################
if [ "$do_cache" = true ] ; then
	echo "*********************"
	echo "Optimizing Cache."
	echo "*********************"
	"$WINE" cmd /C "$WINPATH"  -silent -log:/Preprocessing.log -dx10:1 -dx11:1 -threadedworker:1 -cluster:public -language:en -applet:/EE/Types/Framework/CacheDefraggerAsync /Tools/CachePlan.txt
fi


#############################################################
# actually start the game
#############################################################
if [ "$start_game" = true ] ; then

	echo "*********************"
	echo "Launching Warframe."
	echo "*********************"

	"$WINE" cmd /C start /b "" "$WINPATH" -log:/Preprocessing.log -dx10:1 -dx11:1 -threadedworker:1 -cluster:public -language:en
fi
