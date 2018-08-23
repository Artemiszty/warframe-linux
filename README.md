## Installation Instructions

NOTE: Steam Play support is currently unfinished and currently -not- working. There are changes that need to be made in proton before the game will be able to launch.  

REQUIREMENTS:  

1. Install some tools you'll need for the script. You'll have to search for these packages yourself as I do not have/know the package names for every distro:  
winetricks, tar, lzma/unlzma, curl, wget, md5sum

2. Install the game in steam via lutris or some easy to use wine bottle manager. I will create a prefix install script eventually, but for now here are the winetricks you need:  
```
WINEARCH=win64 WINEPREFIX=/path/to/steam/game/prefix winetricks -q vcrun2015 vcrun2013 devenum xact xinput quartz win7  
```
3. After that finishes and after the game is installed in steam, browse the steam files and open the Tools folder. Make a backup of Launcher.exe, then copy my Launcher.exe and Launcher.sh into the Tools folder.  

4. Close wine-steam, then add the steam library folder containing warframe to your linux steam install. Also make sure beta and steam play are enabled.

5. From here run the game in Steam Play, it should open a terminal (this will have a lot of errors regarding the steam overlay LD_PRELOAD), then two black boxes will run, then the game will attempt to launch.  

STATUS:
Currently the game does not launch in Steam Play/Proton because it thinks it's offline and is unable to download the Cache Manifest.   

For the curious - you can open my Launcher.exe in a text editor. it's a wrapper for Launcher.sh which allows arguments to be passed through it. You can use the same arguments as my standalone script.  
