## Currently known bugs:
-You will need to plug in a controller. Proton auto-closes warframe after a few minutes if it does not detect one. You do not have to use the controller to play.  

-Does not work with beta version of proton  

## Installation Instructions  

REQUIREMENTS:  

1. Make sure you are using Proton 3.7 (NOT BETA). The beta version has a lot of problems.

2. Install some tools you'll need for the script. You'll have to search for these packages yourself as I do not have/know the package names for every distro:  
xz-utils, curl, md5sum  

3. Install the game in steam.  

4. After the game is installed in steam, browse the steam files and open the Tools folder. Make a backup of Launcher.exe, then copy everything to the tools folder.  

5. Plug in a controller. For whatever reason the current version of steam forces Warframe closed if it doesn't detect a controller within the first 5 minutes. (You do not have to use a controller to play the game.)

6. In steam add --firstrun as a launch option, press play  

7. The game will prepare the prefix, patch wininet, update, defrag the cache, then launch.  

8. Remove the --firstrun option afterwards.  


For the curious -  
Launcher.exe: You can open my Launcher.exe in a text editor. it's a wrapper for Launcher.sh which allows arguments to be passed through it. You can use the same arguments as my standalone script.  

wininet.dll - this is wininet from https://github.com/ValveSoftware/wine which proton uses, patched with https://github.com/wine-staging/wine-staging/tree/master/patches/wininet-InternetCrackUrlW patchset. Despite the name, it is not a "crack" it's just a patch for wininet that fixes this bug in wine:
https://bugs.winehq.org/show_bug.cgi?id=40598   

dxvk - these are the latest versions of dxvk patched with the Path of Exile anti-stutter patch found here:
https://github.com/jomihaka/dxvk-poe-hack. The dxvk.conf toggles what the patch does on and off, so it only works specifically for this game and won't affect your other games.
