DEBIAN IS NOT SUPPORTED.  
USE ANY OTHER MAJOR DISTRO. LITERALLY TAKE YOUR PICK. ANY UBUNTU VARIETY. ANY ARCH VARIETY. ANY RED HAT VARIETY. SOLUS IS FINE TOO.  

[HOW TO REPORT AN ISSUE](https://gitlab.com/GloriousEggroll/warframe-linux/wikis/how-to-report-an-issue)

KNOWN BUGS:  

-Loading screen buzz, occasional odd-sounding effects: FAudio is being used to replace DirectX's XAudio implementation. FAudio is very new, and still has some bugs, however this is currently the only way to play the game as 64 bit XAudio crashes the game.  

-Reverb crashes some missions: Turn reverb off in audio settings, it is not fully implemented  

-Occasional buzzing/cracking: The game seems to have an issue with FAudio currently when losing/regaining window focus, this is the same issue as the loading screen buzz, as it has to do with memory not being initialized before trying to play sound. Turning on the option in game to mute when running in background helps.  


## Installation Instructions

REQUIREMENTS:  

1. Install wine-staging and wine dependencies (follow guide here for your distro):  
[How to get out of Wine Dependency Hell](https://www.gloriouseggroll.tv/how-to-get-out-of-wine-dependency-hell/)  

2. Install some tools you'll need for the script. You'll have to search for these packages yourself as I do not have/know the package names for every distro:  
winetricks, tar, lzma/unlzma, curl, wget, md5sum

Option A: Download Lutris:  

If you have lutris already, please make sure it is updated to version 0.4.14 or higher, as older versions had problems running batch scripts.  Next, run my Lutris install script for warframe:  
[Lutris 0.4.18](https://lutris.net/downloads/)  
[Warframe Install Script for Lutris](https://lutris.net/games/warframe/)  
Enable DXVK in the configuration options for the game in lutris, then run it from lutris.

Option B: Without Lutris:  

1. Download a copy of my warframe wine wrapper repo and extract it somewhere: [warframe-linux-master](https://github.com/GloriousEggroll/warframe-linux/archive/master.zip)  

2. Open the extracted folder in a terminal and:  

```shell
  chmod a+x install.sh
```

```shell
  ./install.sh
```

An optional parameter may be passed to specify the target installation
directory. Run `./install.sh --help` to see all available options.

3. Launch the game via any of the following methods:  

```
  Applications>Games>Warframe  
  or  
  Warframe desktop shortcut  
  or  
  type "warframe" in a terminal
```

NOTE: The launcher will open and run in a terminal. It will then launch two "black boxes", one after another. This is Warframe.exe double checking for missed updates, and then optimizing the game cache. Once these launch they will close by themselves, and the game will launch.

## Uninstallation/Removal Instructions
This applies to non-lutris only: 

```shell
  ./uninstall.sh
```

