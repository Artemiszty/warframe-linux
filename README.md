## Installation Instructions

REQUIREMENTS:  

1. Install wine-staging and wine dependencies (follow guide here for your distro):  
[How to get out of Wine Dependency Hell](https://www.gloriouseggroll.tv/how-to-get-out-of-wine-dependency-hell/)  

2. Install some tools you'll need for the script. You'll have to search for these packages yourself as I do not have/know the package names for every distro:  
winetricks, tar, lzma/unlzma, curl, wget, md5sum

3. Install the game in steam via lutris or some easy to use wine bottle manager. I will create a prefix install script eventually, but for now here are the winetricks you need:  
```
WINEARCH=win64 WINEPREFIX=/path/to/steam/game/prefix winetricks -q vcrun2015 vcrun2013 devenum xact xinput quartz win7  
```
4. Install DXVK:
```
wget https://github.com/doitsujin/dxvk/releases/download/v0.70/dxvk-0.70.tar.gz
tar -xvzf dxvk-0.70.tar.gz
cd dxvk-0.70
WINEARCH=win64 WINEPREFIX=/path/to/steam/game/prefix winetricks --force setup_dxvk.verb
cd ..
rm -R dxvk-0.70 dxvk-0.70.tar.gz
```

After that finishes and after the game is installed in steam, browse the steam files and open the Tools folder. Make a backup of Launcher.exe, then copy my Launcher.exe and Launcher.sh into the Tools folder.  

From here run the game in steam, it should open a terminal, then two black boxes will run, then the game will launch with full Tennogen access.  

For the curious - you can open my Launcher.exe in a text editor. it's a wrapper for Launcher.sh which allows arguments to be passed through it. You can use the same arguments as my standalone script.
