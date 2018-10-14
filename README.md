## Currently known bugs:
-You will need to plug in a controller. Proton auto-closes warframe after a few minutes if it does not detect one. You do not have to use the controller to play.  


## Installation Instructions  

-You will need to be using Proton 3.16-beta or higher.
-You will need to run another game with proton first if you have never done so. This forces steam to install a version of proton, as running my script does not trigger that.  
-You will need to install wine and all of its dependencies, as proton does not come with all of the required packages. Follow instructions here for your distro:  

https://www.gloriouseggroll.tv/how-to-get-out-of-wine-dependency-hell/  

(sorry, I do not have instructions for gentoo or fedora)  

REQUIREMENTS:  

1. Install some tools you'll need for the script. You'll have to search for these packages yourself as I do not have/know the package names for every distro:  
xz-utils, curl, md5sum  

2. Install the game in steam.  

3. After the game is installed in steam, browse the steam files, open the Tools folder and make a backup of the file Launcher.exe.

4. Copy all the files from this repository (unzip/extract) and replace the files in the Tools folder.

5. Plug in a controller. For whatever reason the current version of steam forces Warframe closed if it doesn't detect a controller within the first 5 minutes. (You do not have to use a controller to play the game.)

6. Press Play in Steam.  The game will prepare the prefix, patch wininet, update, defrag the cache, then launch.


For the curious -  
Launcher.exe: You can open my Launcher.exe in a text editor. it's a wrapper for Launcher.sh which allows arguments to be passed through it. You can use the same arguments as my standalone script.  

wininet.dll - this is wininet from https://github.com/ValveSoftware/wine which proton uses, patched with https://github.com/wine-staging/wine-staging/tree/master/patches/wininet-InternetCrackUrlW patchset. Despite the name, it is not a "crack" it's just a patch for wininet that fixes this bug in wine:
https://bugs.winehq.org/show_bug.cgi?id=40598. This has been added to official wine as of 9/7/18 https://github.com/wine-mirror/wine/commit/bfe8510ec0c7bcef0be1f6990c56ad235d8bccd6   

dxvk - these are the latest versions of dxvk patched with the Path of Exile anti-stutter patch found here:
https://github.com/jomihaka/dxvk-poe-hack. The dxvk.conf toggles what the patch does on and off, so it only works specifically for this game and won't affect your other games.


## TROUBLESHOOTING:
If the game fails to run on its first launch for whatever reason, try adding --firstrun to the launch options, then run it again in steam. If this is successful you can remove --firstrun afterwards.  