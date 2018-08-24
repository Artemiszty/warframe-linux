STATUS:
Currently the game does not launch in Steam Play/Proton because it thinks it's offline and is unable to download the Cache Manifest. My launcher is able to update and launch the game as needed, just waiting on this to be fixed in proton.  

## Installation Instructions

REQUIREMENTS:  

1. Install some tools you'll need for the script. You'll have to search for these packages yourself as I do not have/know the package names for every distro:  
winetricks, 7z, xz-utils, curl, md5sum

2. Install the game in steam via lutris or some easy to use wine bottle manager. 

3. After the game is installed in steam, browse the steam files and open the Tools folder. Make a backup of Launcher.exe, then copy my Launcher.exe and Launcher.sh into the Tools folder.  

4. Close wine-steam, then add the steam library folder containing warframe to your linux steam install. 
-Also make sure beta and steam play are enabled.  
-Before you launch the game, add --firstrun as a launch argument for warframe in steam. After the first run you can remove it.  

5. From here run the game in Steam Play, then two black boxes will run, then the game will attempt to launch.  

For the curious - you can open my Launcher.exe in a text editor. it's a wrapper for Launcher.sh which allows arguments to be passed through it. You can use the same arguments as my standalone script.  
