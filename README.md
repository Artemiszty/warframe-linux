DEBIAN IS NOT SUPPORTED.  
USE ANY OTHER MAJOR DISTRO. LITERALLY TAKE YOUR PICK. ANY UBUNTU VARIETY. ANY ARCH VARIETY. ANY RED HAT VARIETY. SOLUS IS FINE TOO.  

[HOW TO REPORT AN ISSUE](https://gitlab.com/GloriousEggroll/warframe-linux/wikis/how-to-report-an-issue)

KNOWN BUGS:  

-Loading screen buzz, occasional odd-sounding effects: FAudio is being used to replace DirectX's XAudio implementation. FAudio is very new, and still has some bugs, however this is currently the only way to play the game as 64 bit XAudio crashes the game.  

-Reverb crashes some missions: Turn reverb off in audio settings, it is not fully implemented  

-Occasional buzzing/cracking: The game seems to have an issue with FAudio currently when losing/regaining window focus, this is the same issue as the loading screen buzz, as it has to do with memory not being initialized before trying to play sound. Turning on the option in game to mute when running in background helps.  


## IMPORTANT:
-You MUST run the game from steam's "Play" button. You CANNOT run the script by itself. Steam passes environment variables to the script that it needs.  
-Proton auto-closes warframe after a few minutes if it does not detect a controller. You can either plug in a controller, OR if you don't have a controller, install xboxdrv: https://gitlab.com/xboxdrv/xboxdrv and run it as a service before running steam.  

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
-Fails to run on first launch:  

Try adding --firstrun to the launch options, then run it again in steam. If this is successful you can remove --firstrun afterwards.  
If not, add --debug to the launch options and report the error.  

-XAudio2 not found:  

FAudio probably didn't symlink correctly. Open Tools/FAudio-wma/build_win64, then run ./wine_setup_native. Repeat the same for the build_win32 folder.  

-Game crashes after a few minutes:  

Make sure either a controller is plugged in, or you have xboxdrv running before running steam. Also make sure the controller is detected in steam by doing the following:  

Open Steam>settings>Controller>General Controller Configuration.  
Check the boxes needed for your controller and make sure your controller is listed under Detected Controllers. Only check the boxes you need, not all of them.  
For xboxdrv the controller will be listed as Unregistered: Xbox 360 Controller.  

