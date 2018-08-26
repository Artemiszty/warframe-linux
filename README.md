## Installation Instructions  

REQUIREMENTS:  

1. Install some tools you'll need for the script. You'll have to search for these packages yourself as I do not have/know the package names for every distro:  
xz-utils, curl, md5sum  

2. Install the game in steam.  

3. After the game is installed in steam, browse the steam files and open the Tools folder. Make a backup of Launcher.exe, then copy everything to the tools folder.  

4. In steam add --firstrun as a launch option, press play  

5. The game will prepare the prefix, patch wininet, update, defrag the cache, then launch.  

6. Remove the --firstrun option afterwards.  


For the curious -  
Launcher.exe: You can open my Launcher.exe in a text editor. it's a wrapper for Launcher.sh which allows arguments to be passed through it. You can use the same arguments as my standalone script.  

wininet.dll - this is wininet from https://github.com/ValveSoftware/wine which proton uses, patched with https://github.com/wine-staging/wine-staging/tree/master/patches/wininet-InternetCrackUrlW patchset. Despite the name, it is not a "crack" it's just a patch for wininet that fixes this bug in wine:
https://bugs.winehq.org/show_bug.cgi?id=40598   
