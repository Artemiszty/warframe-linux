#!/bin/bash

EXEPREFIX="$WINEPREFIX/drive_c/Program Files/Warframe/Downloaded/Public"

curl -s http://content.warframe.com/index.txt.lzma -o "$WINEPREFIX/drive_c/Program Files/Warframe/index.txt.lzma"
unlzma -f index.txt.lzma

echo "*********************"
echo "Checking for updates."
echo "*********************"

find "$EXEPREFIX" -name '*.lzma' -exec rm {} \;

sed -i.bak 's/\.lzma.*/.lzma/' index.txt
if [ -d "$EXEPREFIX" ] && [ ! -f "md5sums.txt" ]; then
    find "$EXEPREFIX" -name '*.*' -type f -exec md5sum {} \; | awk '{print $1}' > md5sums.txt;
fi

echo "*********************"
echo "Downloading updates."
echo "*********************"

PROGRESS=$(wc -l index.txt)
PROGRESS=$((${PROGRESS::-10}/100))
LINECOUNT=0
PERCENT=0

while read line
do
    MD5SUM=${line: -32:-5}
    MD5SUM=${MD5SUM,,}
    if [ -f "md5sums.txt" ] && grep -q "$MD5SUM" "md5sums.txt" && [ -f "$EXEPREFIX${line::-38}" ]; then
        :
    else
        #if new md5sum isn't in old md5sum list,check file for old md5sum, remove it from the list, remove blank lines
        if [ -f "$EXEPREFIX${line::-38}" ]; then
            OLDMD5SUM=$(md5sum "$EXEPREFIX${line::-38}" | awk '{print $1}')
            sed -i "/$OLDMD5SUM/,+1 d" md5sums.txt
            sed -i '/^\s*$/d' md5sums.txt
        fi

        #download new file,unlzma it, move it to correct folder
        curl -s http://content.warframe.com$line --create-dirs -o "$EXEPREFIX$line"
        find "$EXEPREFIX" -name '*.lzma' -exec unlzma -f {} \;
        mv "$EXEPREFIX${line::-5}" "$EXEPREFIX${line::-38}"

        #add new md5sum to md5sums list.
        echo "$MD5SUM" >> "md5sums.txt"
    fi
    (( LINECOUNT+=1 ))
    if (( LINECOUNT > PROGRESS )) && (( PERCENT < 101 )); then
        (( PERCENT+=1 ))
        echo -ne "$PERCENT% Downloading $EXEPREFIX${line::-38}                                   " "\r";
        LINECOUNT=0
    fi
done < index.txt

#cleanup
rm index.*

#copy updater as exe for lutris and allow it to be executed
cp updater.sh "$WINEPREFIX/drive_c/Program Files/Warframe/updater.exe"
chmod a+x updater.exe

if [ "$WINEARCH" = "win64" ]; then

    echo "*********************"
    echo "Launching Warframe."
    echo "*********************"

    wine "$EXEPREFIX/Warframe.x64.exe" -log:/Preprocessing.log -dx10:1 -dx11:1 -threadedworker:1 -cluster:public -language:en -fullscreen:0
else

    echo "*********************"
    echo "Launching Warframe."
    echo "*********************"

    wine "$EXEPREFIX/Warframe.exe" -log:/Preprocessing.log -dx10:1 -dx11:1 -threadedworker:1 -cluster:public -language:en -fullscreen:0
fi
