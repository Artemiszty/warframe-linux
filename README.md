## Installation Instructions

REQUIREMENTS:  

1. Install wine-staging and wine dependencies (follow guide here for your distro):  
[How to get out of Wine Dependency Hell](https://www.gloriouseggroll.tv/how-to-get-out-of-wine-dependency-hell/)  

2. Install some tools you'll need for the script. You'll have to search for these packages yourself as I do not have/know the package names for every distro:  
winetricks,lzma/unlzma, curl, md5sum

3. Install steam via wine into a 64 bit wine prefix. This can be done in Lutris or PlayOnLinux. After that, install the game.

4. Browse to the steamapps/common/Warframe/Tools folder. Make a backup of Launcher.exe, then copy my Launcher.exe and Launcher.sh into the Tools folder.

5. Before running the game for the first time, add the launch option --firstrun to Warframe in steam, then press Play.

From here run the game in steam, it should open a terminal which will proceed to install DirectX on the first run, followed by updating the game, checking the game cache, and then the game will launch with full Tennogen access.

6. After the game successfully launches for the first time, close it and remove the --firstrun option.  

7. Optionally (you probably really want to do this) Install DXVK:

```
wget https://github.com/doitsujin/dxvk/releases/download/v0.70/dxvk-0.70.tar.gz
tar -xvzf dxvk-0.70.tar.gz
cd dxvk-0.70
WINEARCH=win64 WINEPREFIX=/path/to/steam/game/prefix winetricks --force setup_dxvk.verb
cd ..
rm -R dxvk-0.70 dxvk-0.70.tar.gz
```

You should now be able to play the game!
  

For the curious - you can open my Launcher.exe in a text editor. it's a wrapper for Launcher.sh which allows arguments to be passed through it. You can use the same arguments as my standalone script.
